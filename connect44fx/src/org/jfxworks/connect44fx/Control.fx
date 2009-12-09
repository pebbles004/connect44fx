/*
 * Control.fx Logic to run the game
 *
 * Created on 25-nov-2009, 14:43:22
 */

package org.jfxworks.connect44fx;
import org.jfxworks.connect44fx.Model.*;
import org.jfxworks.connect44fx.View.Board;
import javafx.stage.Stage;
import javafx.scene.Scene;

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
            width: View.WIDTH
            height: View.HEIGHT
            content: View.Board {
                game: game
            }
        }
        resizable: false
    }

    game.start();
}

