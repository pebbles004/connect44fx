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
import javafx.scene.image.*;
import org.jfxworks.connect44fx.GameService;
import java.lang.System;

def WIDTH  = 400;
def HEIGHT = 342;

var stage:Stage;

def game:Game = Game {
    humanPlayer: HumanPlayer {
        name: System.getProperty("user.name");
        imageUrl: "{__DIR__}resources/human.png"
    }
};

def startMessage = View.createMessageNode( WIDTH, HEIGHT, "Click to start the game", initGame );
def boardNode    = View.createBoardNode(WIDTH, HEIGHT, game);
def gameNode:Stack = Stack {
    width: WIDTH
    height: HEIGHT
    content: [ boardNode, startMessage ]
}
def screenNode:org.jfxworks.connect44fx.screen.Main = org.jfxworks.connect44fx.screen.Main{};

// Keep the score in sync
// TODO animate !!!
def score = bind game.humanScore on replace {
    screenNode.scoreLabel.text = "Score {score}";
}

// Keep the round/turn id in sync
def round = bind game.roundId on replace {
    screenNode.turnLabel.text = "Round {round}, {game.currentRound.coinsNeededToWin} coins required";
}

// Keep the names of the players in sync
def aiPlayer = bind game.currentAiPlayer on replace {
    if ( aiPlayer != null ) {
        screenNode.aiName.text = aiPlayer.name;
        screenNode.aiImageView.image = Image {
            url: aiPlayer.imageUrl
            width: 70
            height: 70
            preserveRatio: true
        }
    }
}


public function run() :Void {
    // do some syncing with fixed values
    screenNode.humanName.text = game.humanPlayer.name;
    screenNode.humanImageView.image = Image {
        url: game.humanPlayer.imageUrl
        width: 70
        height: 70
        preserveRatio: true
    }
    GameService.requestHighestScore( setHighScore );

    // set the event listeners
    game.addEventListener( game.EVENT_TYPE_WIN, playerWins );
    game.addEventListener( game.EVENT_TYPE_ROUND_START, initRound );
    game.addEventListener( game.EVENT_TYPE_TURN_START, initTurn );
    game.addEventListener( game.EVENT_TYPE_TURN_END, endTurn );

    // assemble the scene graph
    screenNode.gamePanel.content = gameNode;

    // set the stage
    stage = Stage {
        title : "Connect44FX - the ONLY game you need !"
        scene: screenNode.getDesignScene()
        resizable: true
    }
}

function setHighScore( player:String, score:Integer ) :Void {
    if ( score >= 0 ) {
        screenNode.highestScoreLabel.text = "Highest {score} by {player}";
    }
    else {
        println("Got score {score}");
        screenNode.highestScoreLabel.text = "Highest (server error)";
    }
}


function endTurn( turn:Integer, player:Player, game:Game ) :Void {
    gameNode.cursor = Cursor.DEFAULT;
}

function initTurn( turn:Integer, player:Player, game:Game ) :Void {
    if ( player.isAI() ) {
        gameNode.cursor = Cursor.WAIT;
    }
    else {
        gameNode.cursor = Cursor.HAND;
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
    insert messageNode into gameNode.content;
}

function startRound( event:MouseEvent ) :Void {
    clearBoard();
    game.resume();
}

function submitScore( event:MouseEvent ) :Void {
    clearBoard();
    def messageNode = View.createMessageNode(WIDTH - 100, HEIGHT - 200, "Submitting your score to the server ...", noop );
    insert messageNode into gameNode.content;
    GameService.submitScore( game.humanPlayer, game.humanScore, endTheGame );
}

function endTheGame( success:Boolean ) :Void {
    clearBoard();
    if ( success ) {
        insert View.createMessageNode(WIDTH - 100, HEIGHT - 200, "Score has been submitted", noop ) into gameNode.content;
    }
    else {
        insert View.createMessageNode(WIDTH - 100, HEIGHT - 200, "There was an error submitting your score !", noop ) into gameNode.content;
    }
    FX.exit();
}

function noop( event:MouseEvent ) :Void {
}


function resumeTheGame( event:MouseEvent ) :Void {
    clearBoard();
    game.resume();
}


function playerWins( player:Player, game:Game ) :Void {
    var message = "";
    var exit:function(event:MouseEvent):Void;

    if ( player.isAI() ) {
        message = "SHAME ON YOU !\n\nOutsmarted by a bunch of bytes...\n\nPlayer {player.name} has won.\n\nYour score {game.humanScore} points at round {game.roundId}.\n\n\nClick here to submit your score.";
        exit    = submitScore;
    }
    else {
        game.pause();
        message = "You have won this round !\n\nClick here to continue.";
        exit = resumeTheGame;
    }
    def messageNode = View.createMessageNode(WIDTH - 100, HEIGHT - 200, message, exit );
    insert messageNode into gameNode.content;
}

function clearBoard() :Void {
    gameNode.content = gameNode.content[ node | node == boardNode ];
}


