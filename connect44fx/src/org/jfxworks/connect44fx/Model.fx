/*
 * Model.fx
 *
 * Script containing all model classes of Connect44FX.
 *
 * Created on Nov 18, 2009, 2:23:28 PM
 */

package org.jfxworks.connect44fx;

import javafx.util.Sequences;
import java.lang.Comparable;
import org.jfxworks.connect44fx.Behavior.Game;

protected def PLAYER_TYPE_HUMAN = "H";
protected def PLAYER_TYPE_AI    = "A";

/**
 * Contains the meta-data of one Round in the game. Each round opposes the human player 
 * against an AI player of a certain level and a grid with a certain size.
 */
public class Round {
    public-init var round:Integer;
    public-init var aiPlayerName:String;
    public-init var imageUrl:String;
    public-init var rows:Integer;
    public-init var columns:Integer;
    public-init var coinsNeededToWin:Integer;
    public-read var humanStartTime = 0;
    public-read var humanTimeSpend = 0;
}


/**
 * Represents the grid of the game.
 */
public class Grid {

    public-init var rows:Integer;

    public-init var columns:Integer;

    public-init var minimumCellSequenceLength:Integer;

    var cells:Cell[];

    var cellSequences:CellSequence[];

    postinit {
        // initialize the grid
        cells = for ( column in [ 0 .. <columns ], row in [ 0 .. <rows ] ) {
            Cell {
                row:row;
                column:column;
            }
        }

        // initialize sequences of cells in which consecutive coins can occur.
        for ( row in [ 0 .. <rows ] ) {
            insert CellSequence{ cells: getRow( row ) } into cellSequences;
        }
        for ( column in [ 0 .. <columns ] ) {
            insert CellSequence{ cells: getColumn( column ) } into cellSequences;
        }

        // diagonals
        for ( column in [ (-rows-1) .. <columns ] ) {
            // top/left to bottom/right
            var diag1 =  for (row in [ 0 .. <rows ]) {
                getCell( column + row, row );
            };
            insert CellSequence{ cells:diag1 } into cellSequences;
            // bottom/left to top/right
            var diag2 = for (row in [ 0 .. <rows ]) {
                getCell( column + row, rows - row - 1 );
            };
            insert CellSequence{ cells:diag2 } into cellSequences;
        }

        // eliminate invalid sequences - a sequence must be at least the minimum number of coins long
        for ( sequence in cellSequences ) {
            // eliminate cells with null values (as a consequence of the diagonals)
            delete null from sequence.cells;
        }
        cellSequences = cellSequences[ seq | sizeof seq.cells >= minimumCellSequenceLength ];

        for ( sequence in cellSequences ) {
            sequence.cells = (Sequences.sort( sequence.cells ) as Cell[]);
        }
    }

   /**
    * Assign a player to the last free cell in the given column
    */
    public function addCoinIntoColumn( column:Integer, player:Player ) :Boolean {
        // valid move
        if ( Sequences.indexOf(availableColumns(), column) != -1 ) {
            var freeCellsInColumn = getColumn( column )[ x | x.player == null ];
            def firstCell = freeCellsInColumn[ sizeof freeCellsInColumn - 1 ];
            if ( firstCell.player == null ) {
                firstCell.player = player;
            }
            else {
                println("????");
            }
            return true;
        }
        // invalid move
        return false;
    }

    protected bound function getCell( column:Integer, row:Integer ) :Cell {
        var temp:Cell = cells[ cell | cell.column == column and cell.row == row ][0];
        return temp;
    }


   /**
    * Return a sequence of cells (top-down) representing the column
    */
    protected function getColumn( column:Integer ) :Cell[] {
        cells[ x | x.column == column ];
    }

    protected function getRow( row:Integer ) :Cell[] {
        cells[ y | y.row == row ];
    }

   /**
    * Which columns are available to insert a coin into. The function is bound
    * because any bound objects are likely to listen to this.
    */
    public bound function availableColumns() :Integer[] {
        for ( index in [ 0 .. <columns ] where getColumn( index )[0].player == null ) {
            index;
        }
    }

    /**
     * Perform pattern matching on the contents of the grid. This is used to find a winning sequence
     * and to allow AI players to look for specific situations.
     *
     * H       : Coin of the human player
     * A       : Coin of the AI player
     * <blank> : No coin just yet / Must be empty
     */
    protected function findPattern( pattern:String ) :CellSequence[] {

        var sequences:CellSequence[] = [];

        for ( sequence in cellSequences ) {
            var pos = sequence.pattern.indexOf( pattern );
            while ( pos != -1 ) {
                insert CellSequence {
                    cells: sequence.cells[ pos .. pos + pattern.length() - 1 ];
                } into sequences;
                pos = sequence.pattern.indexOf( pattern, pos + pattern.length() );
            }
        }

        return sequences;
    }
}

public class Cell extends Comparable {
    public-init var player:Player;
    public-init var column:Integer;
    public-init var row:Integer;

    protected var winning:Boolean = false;

    override public function compareTo ( _other : Object ) : Integer {
        def other = _other as Cell;
        if ( column > other.column ) {
            return 1;
        }
        if ( column < other.column ) {
            return -1;
        }
        if ( row < other.row ) {
            return 1;
        }
        if ( row > other.row ) {
            return -1;
        }
        return 0;
    }
}

public class CellSequence {
    public-read var cells:Cell[] on replace {
                                    buildPatternString();
                                 };

    var patternSeq = bind for ( cell in cells ) {
                             if ( cell.player != null ) cell.player.type else " ";
                          } on replace {
                             buildPatternString();
                          };

    public-read var pattern:String;

    function buildPatternString() :Void {
        pattern = "";
        for ( type in patternSeq ) {
            pattern = "{pattern}{type}";
        }
    }
}

/**
 * Class describing a player in the game. This class is abstract 
 * essentially because there are two types of players : human and AI.
 */
public abstract class Player {

    /**
     * Name of the player
     */
    public var name;

   /**
    * A one-character label indicating what type of player this is.
    * H : Human
    * A : AI
    */
    public-read var type = PLAYER_TYPE_AI;

    /**
     * URL to the image of the player.
     */
    public var imageUrl = "?";

   /**
    * Callback to handle comments of players.
    */
    public-init var onSpeak:function(:Player, :String):Void;

   /**
    * Telling whether the player is thinking about the next move or not
    */
    public-read var thinking:Boolean = false;

    /**
     * Ask the player to start thinking about the next move. And when the thinking is done
     * the player should call the callback function with the column number (0 .. n) to
     * tell in which column he puts a coin in.
     *
     * @param game Game to select a column from
     * @param onChose callback function to call using the column number as argument
     */
    public abstract function thinkAboutNextMove( game:Game, onChose:function( :Integer ) :Void ) :Void;

    public function isHuman() {
        return type == PLAYER_TYPE_HUMAN;
    }

    public function isAI() {
        return type == PLAYER_TYPE_AI;
    }
}

/**
 * A human player does all the thinking outside the application. :-)
 */
public class HumanPlayer extends Player {
    var playCallback:function(:Integer):Void;

    postinit {
        type = PLAYER_TYPE_HUMAN;
    }

    override public function thinkAboutNextMove( game:Game, onChose:function( :Integer ) :Void ) :Void {
        playCallback = onChose;
    }

    package function play( column:Integer ) {
        playCallback ( column );
    }
}
