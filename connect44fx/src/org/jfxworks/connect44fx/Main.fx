/*
 * Control.fx Logic to run the game
 *
 * Created on 25-nov-2009, 14:43:22
 */

package org.jfxworks.connect44fx;
import org.jfxworks.connect44fx.Model.*;
import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.Stack;

def WIDTH  = 400;
def HEIGHT = 342;

var stage:Stage;

def game = Game {
    humanPlayer: HumanPlayer {
        name: "The CPU Grinder"
    }
};

def winningPlayer = bind game.winningPlayer on replace {
    if ( winningPlayer != null ) {
        playerWins(winningPlayer);
    }
};

def startMessage = NodeFactory.createMessageNode( WIDTH, HEIGHT, "Click to start the game", initRound );
def boardNode    = NodeFactory.createBoardNode(WIDTH, HEIGHT, game);
def stack:Stack = Stack {
    width: WIDTH
    height: HEIGHT
    content: [ boardNode, startMessage ]
}

public function run() :Void {
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

function initRound( event:MouseEvent ) :Void {
    clearBoard();
    game.prepareNextRound();
    def messageNode = NodeFactory.createRoundStartMessageNode(WIDTH - 100, HEIGHT - 200, game, startRound );
    insert messageNode into stack.content;
}

function startRound( event:MouseEvent ) :Void {
    clearBoard();
    game.startRound();
}

function playerWins( player:Player ) :Void {
    def messageNode = NodeFactory.createMessageNode(WIDTH - 100, HEIGHT - 200, "Player {player.name} wins this round !", initRound );
    insert messageNode into stack.content;
}

function clearBoard() :Void {
    stack.content = stack.content[ node | node == boardNode ];
}


