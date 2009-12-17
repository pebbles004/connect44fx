/*
 * Control.fx Logic to run the game
 *
 * Created on 25-nov-2009, 14:43:22
 */

package org.jfxworks.connect44fx;
import org.jfxworks.connect44fx.Model.*;
import org.jfxworks.connect44fx.View.*;
import javafx.stage.Stage;
import javafx.scene.Scene;
import javax.swing.text.View;
import javafx.scene.input.MouseEvent;

public def WIDTH  = 400;
public def HEIGHT = 342;

public function run() :Void {

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

    var currentPlayer = bind game.currentPlayer on replace {
        if ( currentPlayer != null ) {
            println("It's {currentPlayer.name} turn ... ");
        }
    };


    Stage {
        title : "Connect44FX - the ONLY game you need !"
        scene: Scene {
            width: WIDTH
            height: HEIGHT
            content: createBoardNode ( WIDTH, HEIGHT, game );
        }
        resizable: false
    }
}

function playerWins( player:Player ) :Void {
    println("YES ! Player {player.name} wins this round !");
}


