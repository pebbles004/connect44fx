/*
 * View.fx
 *
 * Created on 25-nov-2009, 14:43:38
 */
package org.jfxworks.connect44fx;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import java.lang.IllegalStateException;
import javafx.scene.shape.ShapeSubtract;
import javafx.scene.paint.Color;
import javafx.scene.shape.*;
import org.jfxworks.connect44fx.Model.*;
import javafx.scene.image.ImageView;
import javafx.scene.effect.Shadow;
import javafx.scene.layout.Stack;
import javafx.scene.layout.Tile;

public function createBoard(game: Game): Board {
    // select on the level of the game a new board
    Board {
        game: game;
    }
}

public class Board extends CustomNode {

    public-init var game: Game;

    init {
        if (game == null or game.grid == null) {
            throw new IllegalStateException("Board should have a Game and Grid !");
        }
    }

    override protected function create(): Node {
        // calculate the size of an individual cell
        def cellWidth = layoutBounds.width / game.grid.columns;
        def cellHeight = layoutBounds.height / game.grid.rows;

        // generate the visual cells of the grid
        def cells = for (y in [1..game.grid.columns], x in [1..game.grid.rows]) {
             // COOL !!! An object can INDIVIDUALLY be extended for specific circumstances
             ShapeSubtract {
                // The model cell this shape is associated with
                def cell = game.grid.getCell( x, y );

                // catch the event of a coin being inserted
                def player = bind cell.player on replace {
                    if ( player != null ) {
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
                    radiusX: cellWidth - 10
                    radiusY: cellWidth - 10
                }

                effect: Shadow{}
            }
        }

        //TODO : this has to be a shape from a resource bundle
        def background = Rectangle {
            x: 0
            y: 0
            width: layoutBounds.width
            height: layoutBounds.height
            fill: Color.ANTIQUEWHITE
        }

        // Assemble the various components into the board component
        Stack {
            width: layoutBounds.width
            height: layoutBounds.height
            content: [
                background,
                Tile {
                    content: cells
                    hgap: 0
                    vgap: 0
                }
            ]
        }
    }
}

