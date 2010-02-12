/*
 * States.fx
 *
 * An attempt to implement the game states into the State design pattern. Still
 * looking for a way to implement the game behavior in a structured way.
 *
 * Created on Feb 11, 2010, 11:34:51 AM
 */

package org.jfxworks.connect44fx;

import java.lang.UnsupportedOperationException;
import javafx.util.Sequences;
import java.lang.IllegalStateException;
import org.jfxworks.connect44fx.Model.*;
import javafx.util.Properties;
import javafx.util.Math;
import java.util.Random;
import java.lang.System;

// we're using a fixed seed to make sure the generator
// creates the same numbers for every player
def ROUND_RANDOM = new Random( 123456789 );

// random number generator for really random events
def RANDOM = new Random();

/**
 * Public interface with the game state machine
 */
 public class Game extends EventDispatcher {

    public def EVENT_TYPE_GAME_START  = "gameInitialized";
    public def EVENT_TYPE_ROUND_START = "roundStarted";
    public def EVENT_TYPE_TURN_START  = "turnStarted";
    public def EVENT_TYPE_TURN_END    = "turnEnded";
    public def EVENT_TYPE_GAME_END    = "gameTerminated";
    public def EVENT_TYPE_WIN         = "gameWon";
    public def EVENT_TYPE_DRAW        = "roundDraw";

   /**
    * Implement the enter/leave behavior by means of a trigger.
    * This is actually neat ! Simply assign a new state and the methods are executed.
    */
    var currentState:State on replace previousState {
        if ( previousState != null ) {
            previousState.leave();
        }
        if ( currentState != null ) {
            currentState.enter();
        }
    }

    var startGameState:State;
    var endGameState:State;
    var startRoundState:State;
    var endRoundState:State;
    var aiTurnState:State;
    var humanTurnState:State;
    var endTurnState:State;

    // players
    public-init var humanPlayer:Player;
    public-read var currentAiPlayer:Player;
    public-read var currentPlayer:Player;
    public-read var winningPlayer:Player;
    public-read var humanScore:Integer = 0;

    // round related data - a round is one sequence of turns
    var rounds:Round[];
    public-read var currentRound:Round;
    public-read var roundId = 0;
    public-read var turnId  = 0;

    // current grid
    public-read var currentGrid:Grid;

    postinit {
        // initializing the states; this must be done here because 'this' is not known before
        startGameState = GameStarted {
            game: this
        }
        endGameState = GameEnded {
            game: this
        }
        startRoundState = RoundStarted {
            game: this
        }
        endRoundState = RoundEnded {
            game: this
        }
        aiTurnState = AITurnStarted {
            game: this
        }
        humanTurnState = HumanTurnStarted {
            game: this
        }
        endTurnState = TurnEnded {
            game: this
        }

        // state the allowed transitions; this must be done separtly from the initialization because there are
        // 'downward' dependencies.
        startGameState.allowedTransitions  = [ startRoundState, endGameState ];
        startRoundState.allowedTransitions = [ aiTurnState, humanTurnState, endGameState ];
        aiTurnState.allowedTransitions     = [ endTurnState, endGameState ];
        humanTurnState.allowedTransitions  = [ endTurnState, endGameState ];
        endTurnState.allowedTransitions    = [ endRoundState, aiTurnState, humanTurnState, endGameState ];
        endRoundState.allowedTransitions   = [ startRoundState, endGameState ];
    }


   /**
    * Start the game.
    */
    public function start() {
        currentState = startGameState;
    }

    public function pause() {
        if ( currentState != null ) {
            currentState.pause();
        }
    }

    public function resume() {
        if ( currentState != null ) {
            currentState.resume();
        }
    }

   /**
    * End the game override. The game is supposed to end by behavior alone.
    */
    public function stop() {
        currentState = endGameState;
    }

    protected function nextPlayerState():State {
        if ( currentPlayer.isHuman() ) {
            aiTurnState;
        }
        else {
            humanTurnState;
        }
    }


   /**
    * Does the grid contain a winning sequence of coins ?
    */
    function winningSequenceFound() :Boolean {
        var winningSequence = "";
        for ( x in [ 1 .. currentRound.coinsNeededToWin ] ) {
            winningSequence = "{winningSequence}{currentPlayer.type}";
        }
        def patterns = currentGrid.findPattern(winningSequence);

        if ( sizeof patterns > 0 ) {
            for ( cell in patterns[0].cells ) {
                cell.winning = true;
            }
        }

        return (sizeof patterns > 0);
    }
 }

/**
 * Ancestor of all possible states.
 */
abstract class State {

    var game:Game;
    var allowedTransitions:State[];
    var paused = false;
    var pausedState:State;

    function enter() :Void {}

    function leave() :Void {};

    function pause() :Void {
        paused = true;
    }

    function resume() :Void {
        paused = false;
        if ( pausedState != null ) {
            transitTo( pausedState );
            pausedState = null;
        }
    }


    function transitTo( nextState:State ) :Void {
        // is the transition legal ?
        if ( sizeof allowedTransitions > 0 ) {
            if ( Sequences.indexOf(allowedTransitions, nextState) == -1 ) {
                throw new IllegalStateException("Can not transit from {this} to {nextState}.");
            }
        }

        // is the current stated paused ?
        if ( paused ) {
            pausedState = nextState;
        }
        else {
           game.currentState = nextState;
        }
    };
}

/**
 * State for starting the game
 */
class GameStarted extends State {

    /**
     * Read the rounds.properties file to allow pre-configured round configuration.
     */
    override function enter () : Void {
        println("ENTER --> {this}");

        // initialize the rounds sequence with pre-configured settings.
        // when these are exhausted the game will add ad-infinitum rounds to it
        // with ever increasing difficulty
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
            } into game.rounds;
            round++;
        }

        // execute listeners
        game.dispatch( game.EVENT_TYPE_GAME_START, game );

        // transit to the start of the round
        transitTo( game.startRoundState );
    }
}

/**
 * State for ending the game
 */
class GameEnded extends State {
    override function enter () : Void {
        println("ENTER --> {this}");
        game.dispatch( game.EVENT_TYPE_GAME_END, game );
    }
}

/**
 * State for starting a round
 */
class RoundStarted extends State {
   /**
    * A round starts with
    * - Picking a pre-configured round for the next round. If none exists, generate a new one.
    * - Get the AI player that matches the next round.
    * - Select at random who the first player is of the round.
    * - Generate a new grid based on the round
    */
    override function enter () : Void {
        println("\nENTER --> {this}");
        // any pre-configured rounds left on the stack ?
        var round:Round;

        // no => generate a new one
        if ( sizeof game.rounds == 0 ) {
            // 5% chance the grid will increase in size
            var modifyGridSize = ( ROUND_RANDOM.nextInt( 100 ) <= 5 );
            // 3% chance to increase the number of coins needed to win
            var increaseCoins  = ( ROUND_RANDOM.nextInt( 100 ) <= 3 );

            // Generate a new round.
            // TODO Choose a name and picture at random
            round = Round {
                round: ++game.roundId
                aiPlayerName: generateName( ROUND_RANDOM );
                rows: Math.min(20, if ( modifyGridSize ) game.currentRound.rows+1 else game.currentRound.rows );
                columns: Math.min(21, if ( modifyGridSize ) game.currentRound.columns+1 else game.currentRound.columns );
                coinsNeededToWin: Math.min(10, if ( increaseCoins ) game.currentRound.coinsNeededToWin+1 else game.currentRound.coinsNeededToWin );
            }
        }
        // yes => pick the first one
        else {
            round = game.rounds[0];
            delete game.rounds[0];
        }
        game.roundId++;
        game.currentRound    = round;
        game.currentAiPlayer = AI.createAIPlayer( game.currentRound );
        game.turnId          = 0;

    // select the first player at random
        if ( RANDOM.nextBoolean() ) {
            game.currentPlayer = game.humanPlayer;
        }
        else {
            game.currentPlayer = game.currentAiPlayer;
        }
        game.winningPlayer = null;
        
    // create new grid
        game.currentGrid = Grid {
            rows: round.rows;
            columns: round.columns;
            minimumCellSequenceLength: round.coinsNeededToWin
        }

    // tell listeners we're ready to start the round
        game.dispatch(game.EVENT_TYPE_ROUND_START, game.currentRound.round, game);

    // kick-in the first turn
        if ( game.currentPlayer.isAI() ) {
            transitTo( game.aiTurnState );
        }
        else {
            transitTo( game.humanTurnState );
        }
    }

    // TODO Find a better naming sceme.
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
}

/**
 * State for ending a round
 */
class RoundEnded extends State {
    override function enter() :Void {
        println("ENTER --> {this}");
        if ( game.winningPlayer != null ) {
            game.dispatch( game.EVENT_TYPE_WIN, game.currentPlayer, game );
            if ( game.winningPlayer.isAI() ) {
                transitTo( game.endGameState );
            }
            else {
                transitTo( game.startRoundState );
            }
        }
        else {
            if ( sizeof game.currentGrid.availableColumns() == 0 ) {

            }
        }
    }
}

/**
 * State class for starting turns - is abstract because it's different for AI and humans
 */
abstract class TurnStarted extends State {

    override function enter () : Void {
        println("ENTER --> {this}");
        // select the next player - in the very first turn the initial player is already known
        if ( game.turnId > 0 ) {
            if ( game.currentPlayer.isAI() ) {
                game.currentPlayer = game.humanPlayer;
            }
            else {
                game.currentPlayer = game.currentAiPlayer;
            }
        }

        // tell the listeners we're entering a new turn
        game.dispatch(game.EVENT_TYPE_TURN_START, ++game.turnId, game.currentPlayer, game );
        
        // tell the AI player to think about its next move
        game.currentPlayer.thinkAboutNextMove( game, onChoice );
    }

    function onChoice( column:Integer ) :Void {
        def grid = game.currentGrid;
        def currentPlayer = game.currentPlayer;

        // the ai is trying to play while it's not its turn ???
        if ( currentPlayer.isAI() and game.currentState != game.aiTurnState ) {
            throw new IllegalStateException( "It's not the AI's turn !" );
        }
        // ignore this case - because it means the user is clicking around
        if ( currentPlayer.isHuman() and game.currentState != game.humanTurnState ) {
            println("Human player is not allowed to play now");
            return;
        }

        // tell the game the next coin coming into the selected column
        if ( grid.addCoinIntoColumn(column, currentPlayer) ) {
            transitTo( game.endTurnState );
        }
        else {
            throw new IllegalStateException("Coin could not be added into grid");
        }
    }
}

/**
 * State for starting a turn played by an AI
 */
class AITurnStarted extends TurnStarted {
}

/**
 * State for starting a turn played by a human
 */
class HumanTurnStarted extends TurnStarted {

    var startChrono:Long = 0;
    var stopChrono:Long  = 0;

    override function enter () : Void {
        super.enter();
        startChrono = System.currentTimeMillis();
    }

    override function onChoice( column:Integer ) :Void {
        stopChrono = System.currentTimeMillis();
        super.onChoice(column);
    }


    override function leave () : Void {
        println("LEAVE --> {this}");
        game.humanScore += 200 - (( stopChrono - startChrono )/1000);
    }
}

/**
 * State for ending a turn
 */
class TurnEnded extends State {
    override function enter () : Void {
        println("ENTER --> {this}");
        game.dispatch( game.EVENT_TYPE_TURN_END, game.turnId, game.currentPlayer, game );

        if ( game.winningSequenceFound() ) {
            game.winningPlayer = game.currentPlayer;
            transitTo( game.endRoundState );
        }
        else {
            if ( sizeof game.currentGrid.availableColumns() == 0 ) {
                game.dispatch( game.EVENT_TYPE_DRAW, game );
                transitTo( game.endRoundState );
            }
            else {
                transitTo( game.nextPlayerState() );
            }
        }
    }
}