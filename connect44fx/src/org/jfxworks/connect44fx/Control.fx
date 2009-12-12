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

public def WIDTH  = 400;
public def HEIGHT = 342;

public function run() :Void {
    def humanPlayer = HumanPlayer {
        name: "Name from facebook"
    }


    def game = Game {
        humanPlayer: humanPlayer
    }
    
    Stage {
        title : "Connect44FX - the ONLY game you need !"
        scene: Scene {
            width: WIDTH
            height: HEIGHT
            content: createBoardNode ( WIDTH, HEIGHT, game );
        }
        resizable: false
    }

    game.start();
}

