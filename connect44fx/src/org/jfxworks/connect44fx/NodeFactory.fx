/*
 * NodeFactory.fx
 *
 * Created on Dec 18, 2009, 11:14:52 AM
 */

package org.jfxworks.connect44fx;

import javafx.scene.Node;
import javafx.scene.layout.Stack;
import javafx.scene.shape.Rectangle;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.Color;
import javafx.scene.text.Text;
import javafx.scene.Group;
import javafx.scene.effect.DropShadow;
import javafx.scene.shape.Ellipse;
import javafx.scene.shape.ShapeSubtract;
import org.jfxworks.connect44fx.Model.*;
import org.jfxworks.connect44fx.View.*;
import org.jfxworks.connect44fx.resources.Level1Cell;

/**
 * @author jan
 */

public function createMessageNode( width:Integer, height:Integer, message:String, onClick:function(:MouseEvent):Void ) :Node {
    Stack {
        blocksMouse: true // otherwise the mouse event propagates to the board !
        width: width
        height: height
        content: [
                   Rectangle {
                       width: width
                       height: height
                       fill: Color.LAVENDERBLUSH
                       onMouseClicked: onClick
                   }
                   Text {
                       content: message
                   }
                 ]
    }
}

public function createRoundStartMessageNode(  width:Integer, height:Integer, game:Game, onClick:function(:MouseEvent):Void ) {
    var message = "Round {game.round}\nBoard is {game.grid.columns} by {game.grid.rows}\nAligned coins needed {game.coinsNeededToWin}\nYour opponent {game.aiPlayer.name}\nStarting player: {game.currentPlayer.name}";
    createMessageNode(width, height, message, onClick);
}

// TODO use a resource bundle for this
public public function createBoardNode( width:Integer, height:Integer, game: Model.Game): Node {
    Board {
        width: width;
        height: height;
        game: game;
    }
}

// TODO use a resource bundle for this
public function createCellNode( width:Integer, height:Integer, round:Integer ): Node {
    Group {
      content: [
        // a background rectangle is needed to make sure the mouse click event is caught.
        // the basic shape is a hollow rectangle. Clicking in the hole doesn't trigger
        // the mouse click handler !!!
        Rectangle {
            width: width
            height: height
            fill: Color.IVORY
        }

        ShapeSubtract {
            a: Rectangle {
                width: width
                height: height
                fill: Color.ALICEBLUE
            }

            b: Ellipse {
                radiusX: width/2 - 5
                radiusY: height/2 - 5
                centerX: width/2
                centerY: height/2
            }

            // Otherwise the special effect will shift the whole grid by 5x5 pixels !
            clip: Rectangle {
                width: width
                height: height
            }

            effect: DropShadow {
                        offsetX: 5
                        offsetY: 5
                    }
        }
        ]
    }
}

// TODO use a resource bundle for this
public function createCoinNode( width:Integer, height:Integer, round:Integer, player:Player ): Node {
    var coin:Node;

    if ( player.isHuman() ) {
        coin = Ellipse {
                radiusX: width/2 - 8
                radiusY: height/2 - 8
                centerX: width/2
                centerY: height/2
                fill: Color.INDIANRED
            }
    }

    if ( player.isAI() ) {
        coin = Ellipse {
                radiusX: width/2 - 8
                radiusY: height/2 - 8
                centerX: width/2
                centerY: height/2
                fill: Color.DARKCYAN
            }
    }

    return coin;
}
