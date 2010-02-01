/*
 * Model.fx
 *
 * Script containing all model classes of Connect44FX.
 *
 * Created on Nov 18, 2009, 2:23:28 PM
 */

package org.jfxworks.connect44fx;

import java.util.Random;
import javafx.util.Sequences;
import javafx.util.Properties;
import java.lang.Comparable;
import javafx.util.Math;
import java.lang.System;

def RANDOM = Random{};

// we're using a fixed seed to make sure the generator 
// creates the same numbers for every player
def ROUND_RANDOM = new Random( 123456789 );

public def PLAYER_TYPE_HUMAN = "H";

public def PLAYER_TYPE_AI    = "A";

/**
 * Class describing the conceptual game.
 *
 * The aim is to allow visual components to bind with the various state variables of this object.
 */
public class Game extends EventDispatcher {

    public def EVENT_TYPE_GAME_INIT   = "gameInitialized";
    public def EVENT_TYPE_ROUND_START = "roundStarted";
    public def EVENT_TYPE_TURN_START  = "turnStarted";
    public def EVENT_TYPE_TURN_END    = "turnEnded";
    public def EVENT_TYPE_GAME_END    = "gameTerminated";
    public def EVENT_TYPE_SPEAKING    = "playerIsSpeaking";
    public def EVENT_TYPE_WIN         = "playerIsWinning";
    public def EVENT_TYPE_DRAW        = "gameDraw";

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
     * Current round of the game
     */
    var rounds: Round[];
    public-read var currentRound:Round;

    /**
     * Current turn in the current round of the game - 1 for the first turn. Can not be larger
     * than columns & rows product.
     *
     * Reset to 0 at each new round.
     */
    var turn = 0;

    /**
     * The conceptual grid that's behind the game. Reintialized at each new round
     */
    public-read var grid:Grid;

    /**
     * Flag to indicate the next turn needs to reinitialize the next round
     */
    var needsInitialisation = true;

    /**
     * Score so far by the human player
     */
    public-read var humanScore = 0;

    postinit {
        // redirect human speach
        addEventListener(EVENT_TYPE_SPEAKING, humanPlayer.onSpeak);

        // initialize the rounds sequence
        def inputStream = this.getClass().getResourceAsStream("resources/rounds.properties");
        def properties  = Properties {};
        properties.load(inputStream);

        var round = 0;
        while( properties.get("round.{round}") != null ) {
            def values = properties.get("round.{round}").split(",");
            insert Round {
                round: round;
                aiPlayerName: values[0];
                imageUrl: "{__DIR__}resources/{values[1]}";
                rows: Integer.parseInt(values[2]);
                columns: Integer.parseInt(values[3]);
                coinsNeededToWin: Integer.parseInt(values[4]);
            } into rounds;
            round++;
        }

        dispatch(EVENT_TYPE_GAME_INIT, this);
    }

    public function prepareNextRound() :Void {
        def index = if ( currentRound == null ) 0 else currentRound.round + 1;
        var round = rounds[ index ];

        // We ran out of defined rounds !
        // These humans ... we'll make it a bit harder then... :-)
        if ( round == null ) {
            // 10% chance the grid will increase in size
            var modifyGridSize = ( ROUND_RANDOM.nextInt( 100 ) <= 5 );
            // 3% chance to increase the number of coins needed to win
            var increaseCoins  = ( ROUND_RANDOM.nextInt( 100 ) <= 3 );

            // Generate a new round.
            // TODO Choose a name and picture at random
            round = Round {
                round: index
                aiPlayerName: generateName( ROUND_RANDOM );
                rows: Math.min(20, if ( modifyGridSize ) currentRound.rows+1 else currentRound.rows );
                columns: Math.min(21, if ( modifyGridSize ) currentRound.columns+1 else currentRound.columns );
                coinsNeededToWin: Math.min(10, if ( increaseCoins ) currentRound.coinsNeededToWin+1 else currentRound.coinsNeededToWin );
            }
        }

        resetToRound(round);
    }

    // TODO Find a better naming sceme.
    //      Isn't there a list of "tough" names somewhere ?
    function generateName( random:Random ) :String {
        var name = "";
        for ( index in [ 1 .. 3 ] ) {
            name = "{name}{generateCharacter(random)}";
        }
        name = "{name}-{1000 + random.nextInt(8999)}";

        return name;
    }

    function generateCharacter( random:Random ) :String {
        var char:Character = 65 + random.nextInt(26);
        return char.toString();
    }


    public function startRound() :Void {
        dispatch(EVENT_TYPE_ROUND_START, currentRound.round, this);
        if ( turn == 0 ) {
            nextTurn();
        }
    }

    /**
     * Prepare the game to start the given round. But don't start it just yet. It's always
     * the human player who kicks off a round. Even if the AI player is starting
     */
    function resetToRound( round:Round ) :Void {
    // select new AI player
        if ( aiPlayer != null ) {
            removeEventListener(EVENT_TYPE_SPEAKING, aiPlayer.onSpeak );
        }
        aiPlayer = AI.createAIPlayer( round );
        addEventListener(EVENT_TYPE_SPEAKING, aiPlayer.onSpeak);
        
    // create new grid
        def tempGrid = Grid {
            rows: round.rows;
            columns: round.columns;
            minimumCellSequenceLength: round.coinsNeededToWin
        }
        grid = tempGrid;
        
    // reset various vars
        if ( RANDOM.nextBoolean() ) {
            currentPlayer = humanPlayer;
        }
        else {
            currentPlayer = aiPlayer;
        }
    // says the round is initialized
        turn = 0;
        currentRound = round;
        needsInitialisation = false;
    }

   /**
    * Advance the game into the next turn. Tell the next player to think about his
    * next move.
    */
    function nextTurn() :Void {
        // reset to the next round
        if ( needsInitialisation ) {
            prepareNextRound();
        }

        // start a new turn
        turn++;
        dispatch(EVENT_TYPE_TURN_START, turn, currentPlayer, this );
        if ( currentPlayer.isHuman() ) {
            currentRound.humanStartTime = System.currentTimeMillis();
        }

        // ask the next player to choose a column
        if ( sizeof grid.availableColumns() > 0 ) {
            currentPlayer.thinkAboutNextMove( this, playerChoses );
        }
        else {
            dispatch(EVENT_TYPE_DRAW, this);
            needsInitialisation = true;
        }
    }

    /**
     * Function callback for when a player selects a column to insert a coin into
     */
    function playerChoses( column:Integer ) {
        // keep track of the score
        if ( currentPlayer.isHuman() ) {
            currentRound.humanTimeSpend += (System.currentTimeMillis() - currentRound.humanStartTime);
            humanScore += (200 - (currentRound.humanTimeSpend/1000) );
        }

        // tell the game the next coin coming into the selected column
        if ( grid.addCoinIntoColumn(column, currentPlayer) ) {
            if ( winningSequenceFound() ) {
                dispatch( EVENT_TYPE_WIN, currentPlayer, this );
                if ( currentPlayer.isAI() ) {
                    dispatch( EVENT_TYPE_GAME_END, this );
                }
                else {
                    dispatch( EVENT_TYPE_TURN_END, turn, currentPlayer, this );
                }

                needsInitialisation = true;
            }
            else {
                dispatch( EVENT_TYPE_TURN_END, turn, currentPlayer, this );
                // select the other player
                currentPlayer = if ( currentPlayer instanceof HumanPlayer ) aiPlayer else humanPlayer;
                // asks the player to make his next move
                nextTurn();
            }
        }
    }

    function winningSequenceFound() :Boolean {
        var winningSequence = "";
        for ( x in [ 1 .. currentRound.coinsNeededToWin ] ) {
            winningSequence = "{winningSequence}{currentPlayer.type}";
        }
        def patterns = grid.findPattern(winningSequence);

        if ( sizeof patterns > 0 ) {
            for ( cell in patterns[0].cells ) {
                cell.winning = true;
            }
        }

        return (sizeof patterns > 0);
    }

}

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

    public function test() :Void {
        println("Testing grid...");
        for ( seq in cellSequences ) {
            println("  sequence {indexof seq}");
            for ( cell in seq.cells ) {
                cell.testing = true;
            }
        }
    }
}

public class Cell extends Comparable {
    public-init var player:Player;
    public-init var column:Integer;
    public-init var row:Integer;

    public-read var winning:Boolean = false;
    public      var testing:Boolean = false;

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
