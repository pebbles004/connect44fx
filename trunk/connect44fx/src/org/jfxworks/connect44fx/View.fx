/*
 * View.fx
 *
 * Script containing all visual components of the game. Initially we'll create them with
 * hardcoding in factory methods. But in the end some kind of graphics software should be used to
 * create level-dependend graphics in those same methods.
 *
 * Created on 25-nov-2009, 14:43:38
 */
package org.jfxworks.connect44fx;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import org.jfxworks.connect44fx.Model.*;
import javafx.scene.Group;
import javafx.fxd.Duplicator;
import javafx.scene.Node;
import javafx.scene.effect.DropShadow;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.Panel;
import javafx.scene.layout.Stack;
import javafx.scene.layout.Tile;
import javafx.scene.paint.Color;
import javafx.scene.shape.Ellipse;
import javafx.scene.shape.Rectangle;
import javafx.scene.shape.ShapeSubtract;
import java.lang.Integer;
import java.lang.Void;
import org.jfxworks.connect44fx.Model;
import org.jfxworks.connect44fx.Model.Game;
import org.jfxworks.connect44fx.Model.Player;



// TODO use a resource bundle for this
public function createBoardNode( width:Integer, height:Integer, game: Game): Node {
    boardWidth = width;
    boardHeight = height;
    Board {
        game: game;
    }
}

var boardWidth:Integer;
var boardHeight:Integer;

// TODO use a resource bundle for this
function createCellNode( width:Integer, height:Integer, level:Integer ): Node {
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
function createCoinNode( width:Integer, height:Integer, level:Integer, player:Player ): Node {
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

/**
 * The board class represents the rectangle area with the matrix of holes in it; with coins falling down
 * in the columns the players added a coin into.
 * Typically each "hole" will be one type of node, while the coins will be another.
 */
public class Board extends CustomNode {

    public-init var game: Game;

    def container:Panel = Panel {
        }

    override protected function create(): Node {
        container;
    }

    var currentLevel = bind game.level on replace {
        // level -1 is the default value
        if ( isInitialized( currentLevel ) and currentLevel >= 0 ) {
            rebuildContent( currentLevel );
        }
    }

    var currentPlayer = bind game.nextPlayer;

    var cellWidth:Integer = 0;
    var cellHeight:Integer = 0;

    var coinHumanPlayer:Node;
    var coinAIPlayer:Node;
    var cellNode:Node;

    function rebuildContent( level:Integer ) :Void {
        // cell sizing
        cellWidth  = ( boardWidth  / game.grid.columns ) as Integer;
        cellHeight = ( boardHeight / game.grid.rows ) as Integer;

        // coin nodes
        coinHumanPlayer = createCoinNode(cellWidth, cellHeight, level, game.humanPlayer);
        coinAIPlayer    = createCoinNode(cellWidth, cellHeight, level, game.aiPlayer);
        cellNode        = createCellNode(cellWidth, cellHeight, level);

        // creating content
        container.content = Tile {
            rows: game.grid.rows;
            columns: game.grid.columns;
            content: for ( row in [ 0 .. <game.grid.rows ], column in [ 0 .. <game.grid.columns ] ) {
                var stack:Stack = Stack {

                    layoutInfo: LayoutInfo {
                        width: cellWidth
                        height: cellHeight
                    }

                    content: Duplicator.duplicate( cellNode )

                    def cell = game.grid.getCell( column, row )

                    var player = bind cell.player on replace {
                        if ( player != null ) {//if ( isInitialized( player ) ) {
                            var coin:Node;
                            if ( player.isHuman() ) {
                                coin = Duplicator.duplicate ( coinHumanPlayer );
                            }
                            if ( player.isAI() ) {
                                coin = Duplicator.duplicate ( coinAIPlayer );
                            }
                            insert coin into stack.content;
                        }
                    }

                    onMouseClicked: function( event:MouseEvent ) :Void {
                        if ( currentPlayer.isHuman() ) {
                            (currentPlayer as Model.HumanPlayer).play( cell.column );
                        }
                    }
                }
            }
        }
    }
}

