/*
 * Control.fx Logic to run the game
 *
 * Created on 25-nov-2009, 14:43:22
 */

package org.jfxworks.connect44fx;
import org.jfxworks.connect44fx.Model.*;
import org.jfxworks.connect44fx.Behavior.Game;
import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.Cursor;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.Stack;

def WIDTH  = 400;
def HEIGHT = 342;

var stage:Stage;

def game:Game = Game {
    humanPlayer: HumanPlayer {
        name: "The CPU Grinder"
    }
};

def startMessage = View.createMessageNode( WIDTH, HEIGHT, "Click to start the game", initGame );
def boardNode    = View.createBoardNode(WIDTH, HEIGHT, game);
def stack:Stack = Stack {
    width: WIDTH
    height: HEIGHT
    content: [ boardNode, startMessage ]
}

public function run() :Void {
    game.addEventListener( game.EVENT_TYPE_WIN, playerWins );
    game.addEventListener( game.EVENT_TYPE_ROUND_START, initRound );
    game.addEventListener( game.EVENT_TYPE_TURN_START, initTurn );
    game.addEventListener( game.EVENT_TYPE_TURN_END, endTurn );

    stage = Stage {
        title : "Connect44FX - the ONLY game you need !"
        scene: Scene {
            width: WIDTH
            height: HEIGHT
            content: stack
        }
        resizable: false
    }
}

function endTurn( turn:Integer, player:Player, game:Game ) :Void {
    stack.cursor = Cursor.DEFAULT;
}

function initTurn( turn:Integer, player:Player, game:Game ) :Void {
    if ( player.isAI() ) {
        stack.cursor = Cursor.WAIT;
    }
    else {
        stack.cursor = Cursor.HAND;
    }
}


function initGame( event:MouseEvent ) :Void {
    game.start();
}


function initRound( round:Integer, game:Game ) :Void {
    // tell the game NOT to transit to the next state
    game.pause();
    
    // show the start of round message and wait for the click to resume the game
    clearBoard();
    def messageNode = View.createRoundStartMessageNode(WIDTH - 100, HEIGHT - 200, game, startRound );
    insert messageNode into stack.content;
}

function startRound( event:MouseEvent ) :Void {
    clearBoard();
    game.resume();
}

function endTheGame( event:MouseEvent ) :Void {
    FX.exit();
}

function resumeTheGame( event:MouseEvent ) :Void {
    clearBoard();
    game.resume();
}


function playerWins( player:Player, game:Game ) :Void {
    var message = "";
    var exit:function(event:MouseEvent):Void;

    if ( player.isAI() ) {
        message = "SHAME ON YOU !\n\nOutsmarted by a bunch of bytes...\n\nPlayer {player.name} has won.\n\nYour score {game.humanScore} points at round {game.roundId}.\n\n\nClick here to exit the game.";
        exit    = endTheGame;
    }
    else {
        game.pause();
        message = "You have won this round !\n\nYour score is now {game.humanScore} points.\n\nClick here to continue.";
        exit = resumeTheGame;
    }
    def messageNode = View.createMessageNode(WIDTH - 100, HEIGHT - 200, message, exit );
    insert messageNode into stack.content;
}

function clearBoard() :Void {
    stack.content = stack.content[ node | node == boardNode ];
}


