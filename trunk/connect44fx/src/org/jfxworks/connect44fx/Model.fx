/*
 * Model.fx
 *
 * Script containing all model classes of Connect44FX.
 *
 * Created on Nov 18, 2009, 2:23:28 PM
 */

package org.jfxworks.connect44fx;

import java.lang.IllegalStateException;
import java.util.Random;
import javafx.util.Sequences;
import org.jfxworks.connect44fx.Model.*;
import java.lang.Exception;

def RANDOM = Random{};

public def PLAYER_TYPE_HUMAN = "H";

public def PLAYER_TYPE_AI    = "A";

/**
 * Class describing the conceptual game.
 *
 * The aim is to allow visual components to bind with the various state variables of this object.
 */
public class Game {

    //TODO get this data from from a resource bundle
    public-read var rows = 6;

    //TODO get this data from from a resource bundle
    public-read var columns = 7;

    //TODO get this data from from a resource bundle
    public-read var coinsNeededToWin = 4;

    /**
     * Who's the human player - settable at initialization time
     */
    public-init var humanPlayer:Player;

    /**
     * Who's the AI player - set by the game
     */
    public-read var aiPlayer:Player;

   /**
    * Who's next ?
    */
    public-read var currentPlayer:Player;

    /**
     * Who's winning ?
     */
    public-read var winningPlayer:Player;

   /**
    * indicates whether the current round has ended in a draw - nobody won.
    */
    public-read var draw = false;

   /**
    * Indicates whether the game has ended - the human player was beaten
    */
    public-read var gameFinished:Boolean = false;

    /**
     * Current round of the game - 1 is the first round.
     */
    public-read var round = 0;

    /**
     * Current turn in the current round of the game - 1 for the first turn. Can not be larger
     * than columns & rows product.
     *
     * Reset to 0 at each new round.
     */
    public-read var turn = 0;

    /**
     * The conceptual grid that's behind the game. Reintialized at each new round
     */
    public-read var grid:Grid;

    /**
     * Callback function in case a player says something
     */
    public-init var onSpeak:function (:Player, :String) :Void;

    /**
     * Callback function in case the game communicates something
     */
    public-init var onMessage:function ( :String ):Void;

    /**
     * Flag to indicate the next turn needs to reinitialize the next round
     */
    var needsInitialisation = true;

    postinit {
        // redirect human speach
        humanPlayer.onSpeak = onSpeak;
    }

    public function startRound() :Void {
        if ( turn == 0 ) {
            nextTurn();
        }
    }

    /**
     * Prepare the game to start the given round. But don't start it just yet. It's always
     * the human player who kicks off a round. Even if the AI player is starting
     */
    function resetToRound( round:Integer ) :Void {
        println("Reset game to round {round}");
    // TODO get this from a resource bundle of some kind
        rows = 6;
        columns = 7;
        coinsNeededToWin = 4;
    // select new AI player
        aiPlayer = AI.createAIPlayer( round );
        aiPlayer.onSpeak = onSpeak;
    // create new grid
        def tempGrid = Grid {
            rows: rows;
            columns: columns;
            minimumCellSequenceLength: coinsNeededToWin
        }
        grid = tempGrid;
        
    // reset various vars
        winningPlayer = null;
        draw = false;
        if ( RANDOM.nextBoolean() ) {
            currentPlayer = humanPlayer;
        }
        else {
            currentPlayer = aiPlayer;
        }
        println("Current player: {currentPlayer.name}");
    // says the round is initialized
        turn = 0;
        needsInitialisation = false;
    }

   /**
    * Advance the game into the next turn. Tell the next player to think about his
    * next move.
    */
    function nextTurn() :Void {
        // reset to the next round
        if ( needsInitialisation ) {
            resetToRound( round + 1 );
            round++;
        }

        // start a new turn
        turn++;
        if ( turn < rows * columns ) {
            currentPlayer.thinkAboutNextMove( this, playerChoses );
        }
        else {
            draw = true;
            needsInitialisation = true;
        }
    }

    /**
     * Function callback for when a player selects a column to insert a coin into
     */
    function playerChoses( column:Integer ) {
        // tell the game the next coin coming into the selected column
        if ( grid.addCoinIntoColumn(column, currentPlayer) ) {
            if ( winningSequenceFound() ) {
                winningPlayer = currentPlayer;
                needsInitialisation = true;
            }
            else {
                // select the other player
                currentPlayer = if ( currentPlayer instanceof HumanPlayer ) aiPlayer else humanPlayer;
                println("Player is now {currentPlayer} {currentPlayer.name}");
                // asks the player to make his next move
                nextTurn();
            }
        }
    }

    function winningSequenceFound() :Boolean {
        var winningSequence = "";
        for ( x in [ 1 .. coinsNeededToWin ] ) {
            winningSequence = "{winningSequence}{currentPlayer.type}";
        }
        var pattern = grid.findPattern(winningSequence);

        if ( pattern != null ) {
            for ( cell in pattern ) {
                cell.winning = true;
            }
            winningPlayer = pattern[0].player;
        }

        return pattern != null;
    }

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
            var diag1 =  for ( row in [ 0 .. <rows ] ) {
                getCell( column + row, row );
            };
            insert CellSequence{ cells:diag1 } into cellSequences;
            // bottom/left to top/right
            var diag2 = for ( row in [ (rows-1) .. 0 step -1 ] ) {
                getCell( column + row, row );
            };
            insert CellSequence{ cells:diag2 } into cellSequences;
        }

        // eliminate invalid sequences - a sequence must be at least the minimum number of coins long
        for ( sequence in cellSequences ) {
            // eliminate cells with null values (as a consequence of the diagonals)
            delete null from sequence.cells;
        }
        cellSequences = cellSequences[ seq | sizeof seq.cells >= minimumCellSequenceLength ];
    }

   /**
    * Assign a player to the last free cell in the given column
    */
    public function addCoinIntoColumn( column:Integer, player:Player ) :Boolean {
        // valid move
        if ( Sequences.indexOf(availableColumns(), column) != -1 ) {
            var freeCellsInColumn = getColumn( column )[ x | x.player == null ];
            freeCellsInColumn[ sizeof freeCellsInColumn - 1 ].player = player;
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

    // TODO extend the patterns to wildcards
    protected function findPattern( pattern:String ) :Cell[] {
        for ( sequence in cellSequences ) {
            var pos = sequence.pattern.indexOf( pattern );
            if ( pos != -1 ) {
                return sequence.cells[ pos .. pos + pattern.length() - 1 ];
            }
        }
        return null;
    }
}

public class Cell {
    public-init var player:Player;
    public-init var column:Integer;
    public-init var row:Integer;

    public-read var winning:Boolean = false;
}

class CellSequence {
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
    public-init var name;

   /**
    * A one-character label indicating what type of player this is.
    * H : Human
    * A : AI
    */
    public-read var type = PLAYER_TYPE_AI;

    /**
     * URL to the image of the player.
     */
    public-init var imageUrl = "?";

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
