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
import org.jfxtras.async.*;
import java.lang.Exception;

def RANDOM = Random{};

public var DEBUG = true;

/**
 * Class describing the conceptual game.
 */
public class Game {


    def rows = 6;

    def columns = 7;

    def coinsNeededToWin = 4;

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
    public-read var nextPlayer:Player;

    /**
     * Who's winning ?
     */
    public-read var winningPlayer:Player;

    /**
     * Current level of the game - 0 is the first level. To each level corresponds one
     * specific AI player.
     */
    public-read var level = -1;

    /**
     * Indicates whether the current level has finished (ie there is a winning combination of coins 
     * in the game.
     */
    public-read var levelFinished = true;

   /**
    * indicates whether the current level has ended in a draw - nobody won. 
    */
    public-read var levelDraw = false;

    /**
     * Current turn in the current level of the game - 0 for the first turn. Can not be larger
     * than columns x rows product.
     *
     * Reset to 0 at each new level.
     */
    public-read var turn = -1;

   /**
    * Indicates whether the game has ended
    */
    public-read var gameFinished:Boolean = false;

    public-read var grid:Grid;

    public-init var onSpeak:function (:Player, :String) :Void;
    public-init var onDraw:function():Void;

   /**
    * public function to start the game.
    */
    public function start() {
        // players should be set
        if ( humanPlayer == null ) {
            throw new IllegalStateException("The players are not set yet");
        }
        humanPlayer.onSpeak = onSpeak;

        // do not restart a game
        if ( level == -1 ) {
            // reset the game to the first turn in the next level
            nextLevel();
        }
    }

   /**
    * Stopping the game - it's over. Restarting won't work.
    */
    public function stop() {
        gameFinished = true;
    }

    /**
     * Advance the game into the next level. Reset the turns, select the next player.
     */
    function nextLevel() :Void {
        // reset the game
        level++;
        if ( DEBUG ) {
            println("LEVEL {level} BEGINS")
        }

        aiPlayer = AI.createAIPlayer( level );
        aiPlayer.onSpeak = onSpeak;
        
        levelDraw = false;
        levelFinished = false;
        grid = Grid {
            rows: rows;
            columns: columns;
        }

        // select the player to make the first move
        winningPlayer = null;
        if ( RANDOM.nextBoolean() ) {
            nextPlayer = humanPlayer;
        }
        else {
            nextPlayer = aiPlayer;
        }

        // start the first of turns
        turn = -1;
        nextTurn();
    }

   /**
    * Advance the game into the next turn. Tell the next player to think about his
    * next move.
    */
    function nextTurn() :Void {
        turn++;
        if ( DEBUG ) {
            println("TURN {turn} BEGINS")
        }

        if ( turn < rows * columns ) {
            println("Thinking...");
            nextPlayer.thinkAboutNextMove( this, playerChoses );
        }
        else {
            levelDraw = true;
            onDraw();
            nextLevel();
        }
    }

    /**
     * Function callback for when a player selects a column to insert a coin into
     */
    function playerChoses( column:Integer ) {
        if ( DEBUG ) {
            println(" inserting coin into column {column}")
        }

        // tell the game the next coin coming into the selected column
        insertCoinInto ( column );
        // select the other player
        nextPlayer = if ( nextPlayer == humanPlayer ) aiPlayer else humanPlayer;
        // asks the player to make his next move
        nextTurn();
    }

    function insertCoinInto( column:Integer ) {
        if ( winningSequenceFound() ) {
            winningPlayer = nextPlayer;
            levelFinished = true;
        }
        else {
            def freeCells = grid.getColumn( column )[ x | x.player == null ];
            if ( sizeof freeCells > 0 ) {
                freeCells[ sizeof freeCells - 1 ].player = nextPlayer;
            }
        }
    }

    function winningSequenceFound() :Boolean {
        // TODO scan for x consecutive coins
        return false;
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
        for ( y in [ 0 .. <rows ] ) {
            insert CellSequence{ cells: getRow( y ) } into cellSequences;
        }
        for ( x in [ 0 .. <columns ] ) {
            insert CellSequence{ cells: getColumn( x ) } into cellSequences;
        }

        // diagonal top/left to bottom/right
        for ( x in [ -rows .. columns ] ) {
            var cells = for ( delta in [ 0 .. rows ] ) {
                getCell( x + delta, x + delta );
            }
            delete null from cells;
            if ( sizeof cells >= minimumCellSequenceLength ) {
                insert CellSequence{ cells: cells } into cellSequences;
            }
        }

        // diagonal top/right to bottom/left
        for ( x in [ columns + rows .. 0 step -1 ] ) {
            var cells = for ( delta in [ 0 .. rows ] ) {
                getCell( x - delta, x - delta );
            }
            delete null from cells;
            if ( sizeof cells >= minimumCellSequenceLength ) {
                insert CellSequence{ cells: cells } into cellSequences;
            }
        }
    }

   /**
    * Assign a player to the last free cell in the given column
    */
    public function addCoinIntoColumn( column:Integer, player:Player ) {
        if ( Sequences.indexOf(availableColumns(), column) != -1 ) {
            var freeCellsInColumn = getColumn( column )[ x | x.player == null ];
            freeCellsInColumn[ sizeof freeCellsInColumn - 1 ].player = player;
        }
    }

    protected function getCell( column:Integer, row:Integer ) :Cell {
        return cells[ cell | cell.column == column and cell.row == row ][0];
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
    protected function containsPattern( pattern:String ) :Cell[] {
        for ( sequence in cellSequences ) {
            var pos = sequence.toPattern().indexOf( pattern );
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
    public-init var cells:Cell[];

    //TODO should be done with binding in some way...
    function toPattern() :String {
        var pattern = "";
        for ( cell in cells ) {
            if ( cell.player != null ) {
                pattern = "{pattern}{cell.player.type}";
            }
            else {
                pattern = "{pattern} ";
            }

        }

        return pattern;
    }
}

public def PLAYER_TYPE_HUMAN = "H";

public def PLAYER_TYPE_AI    = "A";

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
    public-init var type = "?";

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

}

/**
 * A human player does all the thinking outside the application. :-)
 */
public class HumanPlayer extends Player {
    override public function thinkAboutNextMove( game:Game, onChose:function( :Integer ) :Void ) :Void {
    }
}
