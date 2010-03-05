/*
 * View.fx
 *
 * Created on Dec 18, 2009, 11:14:52 AM
 */
package org.jfxworks.connect44fx;

import javafx.scene.Node;
import javafx.scene.layout.Stack;
import javafx.scene.shape.Rectangle;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.Color;
import javafx.scene.Group;
import javafx.scene.shape.Ellipse;
import org.jfxworks.connect44fx.Model.*;
import org.jfxworks.connect44fx.Behavior.Game;
import javafx.animation.Interpolator;
import javafx.animation.Timeline;
import javafx.fxd.Duplicator;
import javafx.scene.CustomNode;
import javafx.scene.layout.Panel;
import javafx.scene.layout.Tile;
import javafx.scene.effect.DropShadow;
import javafx.scene.shape.ShapeSubtract;
import org.jfxworks.connect44fx.templates.Level1Cell;
import javafx.scene.layout.VBox;
import org.jfxworks.connect44fx.screen.MessagePopup;
import org.jfxworks.connect44fx.screen.IconMessagePopup;
import javafx.scene.image.*;
import org.jfxworks.connect44fx.ResourceLocator;
import org.jfxworks.connect44fx.resources.Ok;


// EXPERIMENTAL : Set this to false to for generated classes of InkScape.
def USE_DEFAULT_SKINS = true;

public function createIconPopupMEssageNode( width:Integer, height:Integer, message:String, onClick: function(: MouseEvent): Void): Node {
    def popup = IconMessagePopup{};
    // set the message
    popup.message.content = message;
//    popup.icon.content = ImageView {
//        image: Image {
//            url: ResourceLocator.locate("ok.png")
//            width: 80
//            height: 80
//            preserveRatio: true
//        }
//    }

    popup.icon.content = Ok{};

    // scale to the demanded size
    def node = popup.getDesignRootNodes()[0];
    node.scaleX = 1.0 * width/node.boundsInLocal.width;
    node.scaleY = 1.0 * height/node.boundsInLocal.height;
    
    return node;

}

public function createMessageNode(width: Integer, height: Integer, message: String, onClick: function(: MouseEvent): Void): Node {
    // configure the message
    def popup = MessagePopup {}
    popup.message.content = message;
    popup.rectangle.width = width;
    popup.rectangle.height = height;

    // transfer the nodes of the message to another container
    var nodes = popup.getDesignRootNodes();
    // this is needed to avoid the warning about a node being at two places in the scene graph
    delete (popup.getDesignScene().content[0] as Panel).content; // <== Beats me why this is needed. Simply erasing the scene content is not enough
    delete popup.getDesignScene().content;

    // pack & send
    Stack {
        blocksMouse: true // otherwise the mouse event propagates to the board !
        onMouseClicked: onClick;
        content: nodes
    }
}

public function createRoundStartMessageNode(width: Integer, height: Integer, game: Game, onClick: function(: MouseEvent): Void) {
    var message = "Round {game.roundId}\nBoard is {game.currentGrid.columns} by {game.currentGrid.rows}\nAligned coins needed {game.currentRound.coinsNeededToWin}\nYour opponent {game.currentAiPlayer.name}\nStarting player: {game.currentPlayer.name}";
    createMessageNode(width, height, message, onClick);
}

// TODO use a resource bundle for this
public public function createBoardNode(width: Integer, height: Integer, game: Game): Node {
    Board {
        width: width;
        height: height;
        game: game;
    }
}

// TODO use a resource bundle for this
function createCellNode(width: Integer, height: Integer, round: Integer, cell: Cell, humanCoin:Node, aiCoin:Node ): Node {
    CellNode {
        width: width
        height: height
        cell: cell
        aiCoin: aiCoin
        humanCoin: humanCoin
    }
}

// TODO use a resource bundle for this
function createCoinNode(width: Integer, height: Integer, round: Integer, player: Player): Node {
    var coin: Node;

    if (player.isHuman()) {
        /*
        coin = Ellipse {
            radiusX: width / 2 - 8
            radiusY: height / 2 - 8
            centerX: width / 2
            centerY: height / 2
            fill: Color.INDIANRED
        }
        */
        coin = ImageView {
            image: Image {
                url: ResourceLocator.locate("happyduck.png");
                width: width - 16
                height: height - 16
            }
            smooth: true
        }

    }

    if (player.isAI()) {
        /*
        coin = Ellipse {
            radiusX: width / 2 - 8
            radiusY: height / 2 - 8
            centerX: width / 2
            centerY: height / 2
            fill: Color.DARKCYAN
        }
        */
        coin = ImageView {
            image: Image {
                url: ResourceLocator.locate("devilduck.png");
                width: width - 16
                height: height - 16
            }
            smooth: true
        }
    }

    return coin;
}

/**
 * The board class represents the rectangle area with the matrix of holes in it; with coins falling down
 * in the columns the players added a coin into.
 * Typically each "hole" will be one type of node, while the coins will be another.
 */
class Board extends CustomNode {

    public-init var game: Game;
    public-init var width: Integer;
    public-init var height: Integer;

    def container: Panel = Panel {};

    override protected function create(): Node {
        container;
    }

    postinit {
        game.addEventListener(game.EVENT_TYPE_ROUND_START, rebuildContent );
        game.addEventListener(game.EVENT_TYPE_TURN_START, turnStart );
    }

    var currentPlayer:Player;
    var currentTurn:Integer = 0;

    function turnStart( turn:Integer, player:Player, game:Game ) :Void {
        currentPlayer = player;
        currentTurn   = turn;
    }


    function rebuildContent(round: Integer, game:Game): Void {
        // cell sizing
        var cellWidth = (width / game.currentGrid.columns) as Integer;
        var cellHeight = (height / game.currentGrid.rows) as Integer;

        // coin nodes
        var coinHumanPlayer = createCoinNode(cellWidth, cellHeight, round, game.humanPlayer);
        var coinAIPlayer = createCoinNode(cellWidth, cellHeight, round, game.currentAiPlayer);

        // creating content
        container.content = Tile {
            rows: game.currentGrid.rows;
            columns: game.currentGrid.columns;
            hgap: 0
            vgap: 0
            tileHeight: cellHeight
            tileWidth: cellWidth
            clip: Rectangle {
                height: game.currentGrid.rows * cellHeight
                width:  game.currentGrid.columns * cellWidth
                arcHeight: 25
                arcWidth: 25
            }
            content: for (row in [0..<game.currentGrid.rows], column in [0..<game.currentGrid.columns]) {
                def cell = game.currentGrid.getCell(column, row);
                def node = createCellNode(cellWidth, cellHeight, round, cell, coinHumanPlayer, coinAIPlayer);

                node.onMouseClicked = function( event:MouseEvent ) :Void {
                                            if ( currentPlayer.isHuman() ) {
                                                (currentPlayer as HumanPlayer).play( cell.column );
                                            }
                                      };

                // return this node instance
                node
            }
        }
    }
}

class CellNode extends CustomNode {

    public-init var cell: Cell;

    public-init var width: Integer;

    public-init var height: Integer;

    public-init var aiCoin: Node;

    public-init var humanCoin: Node;

    var content:Group;

    def player = bind cell.player on replace {
        if (player != null) {//if ( isInitialized( player ) ) {
            if (player.isHuman()) {
                insert Duplicator.duplicate( humanCoin ) after content.content[0];
            }
            if (player.isAI()) {
                insert Duplicator.duplicate( aiCoin ) after content.content[0];
            }
        }
    }

    def winning = bind cell.winning on replace {
        if ( winning ) {
            def coin = content.content[1];
            Timeline {
                repeatCount: 5
                autoReverse: true
                keyFrames: [
                               at (0s) {
                                   coin.scaleX => 1.0 tween Interpolator.EASEBOTH
                               }
                               at (500ms) {
                                   coin.scaleX => 0.0 tween Interpolator.EASEBOTH
                               }
                               at (1s) {
                                   coin.scaleX => -1.0 tween Interpolator.EASEBOTH
                               }
                           ]
            }.play();
        }
    }

    public override function create(): Node {

        var cell:Node;

        if ( USE_DEFAULT_SKINS ) {
            cell = ShapeSubtract {
                    a: Rectangle {
                        width: width
                        height: height
                        fill: Color.ALICEBLUE
                    }
                    b: Ellipse {
                        radiusX: width / 2 - 5
                        radiusY: height / 2 - 5
                        centerX: width / 2
                        centerY: height / 2
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
        }
        else {
            cell = Level1Cell{};
            normalizeNode(width, height, cell);
        }

        content = Stack {
            width: width
            height: height
            content: [
                // a background rectangle is needed to make sure the mouse click event is caught.
                // the basic shape is a hollow rectangle. Clicking in the hole doesn't trigger
                // the mouse click handler !!!
                Rectangle {
                    width: width
                    height: height
                    fill: Color.IVORY
                }

                cell
            ]
        }
    }
}

function normalizeNode( width:Integer, height:Integer, node:Node ) :Void {
//    def transformations = [
//            Translate {
//                x: -node.layoutBounds.minX
//                y: -node.layoutBounds.minY
//            }
//            Scale {
//                x: 1.0 * width / node.layoutBounds.width
//                y: 1.0 * height / node.layoutBounds.height
//            }
//        ];
//
//    insert transformations into node.transforms;
    node.scaleX = 1.0 * width / node.layoutBounds.width;
    node.scaleY = 1.0 * height / node.layoutBounds.height;
//    node.translateX = -node.layoutBounds.minX;
//    node.translateY = -node.layoutBounds.minY;
}





class PlayerNode extends CustomNode {

    public-init var player:Player;

    override protected function create () : Node {
        VBox {
            content: []
        }
    }
}
