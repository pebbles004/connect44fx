/*
 * View.fx
 *
 * Created on 25-nov-2009, 14:43:38
 */
package org.jfxworks.connect44fx;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import javafx.scene.shape.ShapeSubtract;
import javafx.scene.paint.Color;
import javafx.scene.shape.*;
import org.jfxworks.connect44fx.Model.*;
import javafx.scene.effect.Shadow;
import javafx.scene.layout.Stack;
import javafx.scene.layout.Tile;
import javafx.scene.effect.DropShadow;
import javafx.fxd.Duplicator;
import javafx.geometry.HPos;

public def WIDTH  = 400;
public def HEIGHT = 342;

public function createBoard(game: Game): Board {
    // select on the level of the game a new board
    Board {
        game: game;
    }
}

public class Board extends CustomNode {

    public-init var game: Game;

    def content = Stack {
            width: WIDTH
            height: HEIGHT
        }

    var coinHumanPlayer:Node;
    var coinAIPlayer:Node;

    def grid = bind game.grid on replace {
        if ( grid != null ) {
            content.content = getContent();
        }
    }


    override protected function create(): Node {
        content;
    }

    function getContent() :Node[] {
        // calculate the size of an individual cell
        def cellWidth = WIDTH / game.grid.columns;
        def cellHeight = HEIGHT / game.grid.rows;

        // generate the coin nodes
        // TODO grab this from a resource bundle
        coinHumanPlayer = Ellipse {
            radiusX: cellWidth/2 - 6
            radiusY: cellHeight/2 - 6
            fill: Color.DARKCYAN
        }

        coinAIPlayer = Ellipse {
            radiusX: cellWidth/2 - 6
            radiusY: cellHeight/2 - 6
            fill: Color.INDIANRED
        }


        // generate the visual cells of the grid
        def cells = for (y in [1..game.grid.columns], x in [1..game.grid.rows]) {
            
             // COOL !!! An object can INDIVIDUALLY be extended for specific circumstances
             ShapeSubtract {
                // The model cell this shape is associated with
                def cell = game.grid.getCell( x, y );

                // catch the event of a coin being inserted
                def player = bind cell.player on replace {
                    if ( player != null ) {
                        println("Player move: {player.name} on {cell.column}x{cell.row}");
                        def coin = Duplicator.duplicate(coinHumanPlayer) as Ellipse;
                        coin.layoutX = cellWidth * cell.column;
                        coin.layoutY = cellHeight * cell.row;
                        coin.centerX = cellWidth/2;
                        coin.centerY = cellHeight/2;
                        insert coin into content.content;
                        
                       //TODO a player has inserted a coin in this cell  ...
                       // (1) Create a new coin
                       // (2) Animate it falling down from the top to this cell
                    }
                }

                // catch the event of this cell being part of the winning sequence of coins
                def winning = bind cell.winning on replace {
                    if ( winning ) {
                        //TODO apply effect/paint/animation on cell because it's part
                        //     of the winning sequence of cells
                    }
                }

                //TODO : this has to be a shape from a resource bundle
                a: Rectangle {
                    width: cellWidth
                    height: cellHeight
                    fill: Color.ALICEBLUE
                }

                //TODO : this has to be a shape from a resource bundle
                b: Ellipse {
                    radiusX: cellWidth/2 - 5
                    radiusY: cellHeight/2 - 5
                    centerX: cellWidth/2
                    centerY: cellHeight/2
                }

                effect: DropShadow {
                            offsetX: 5
                            offsetY: 5
                        }
            }
        }

        //TODO : this has to be a shape from a resource bundle
        def background = Rectangle {
            x: 0
            y: 0
            width: WIDTH
            height: HEIGHT
            fill: Color.ANTIQUEWHITE
        }

        // Assemble the various components into the board component
        return [background,
                Tile {
                    content: cells
                    hgap: 0
                    vgap: 0
                }]
    }
}

