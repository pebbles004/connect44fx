/*
 * Control.fx Logic to run the game
 *
 * Created on 25-nov-2009, 14:43:22
 */

package org.jfxworks.connect44fx;
import org.jfxworks.connect44fx.Model.*;
import org.jfxworks.connect44fx.View.Board;

public function run() :Void {
    def humanPlayer = HumanPlayer {
        name: "Name from facebook"
        type: PLAYER_TYPE_HUMAN
    }


    def game = Game {
        humanPlayer: humanPlayer
    }

    View.Board {
        game: game
    }
}

