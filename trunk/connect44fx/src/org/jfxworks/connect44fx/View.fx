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
import javafx.scene.layout.*;
import javafx.scene.effect.DropShadow;
import javafx.fxd.Duplicator;
import javafx.geometry.HPos;
import javafx.scene.input.MouseEvent;

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

    def content = Panel {
            width: WIDTH
            height: HEIGHT
        }

    var coinHumanPlayer:Node;
    var coinAIPlayer:Node;

    def grid = bind game.grid on replace {
        println("Grid changes !");
        if ( grid != null ) {
            content.content = getContent( grid );
        }
    }


    override protected function create(): Node {
        content;
    }

    function getContent( grid:Grid ) :Node[] {
        // calculate the size of an individual cell
        def cellWidth = WIDTH / grid.columns;
        def cellHeight = HEIGHT / grid.rows;

        // generate the coin nodes
        // TODO grab this from a resource bundle
        coinHumanPlayer = Ellipse {
            radiusX: cellWidth/2 - 8
            radiusY: cellHeight/2 - 8
            fill: Color.DARKCYAN
        }

        coinAIPlayer = Ellipse {
            radiusX: cellWidth/2 - 8
            radiusY: cellHeight/2 - 8
            fill: Color.INDIANRED
        }


        // generate the visual cells of the grid
        def cells = for (x in [1..grid.columns], y in [1..grid.rows]) {
            
             // COOL !!! An object can INDIVIDUALLY be extended for specific circumstances
             ShapeSubtract {

                // The model cell this shape is associated with
                // TODO find out why this expression has to be bound ??
                def cell = bind grid.getCell( x, y );

                // catch the event of a coin being inserted
                def player = bind cell.player on replace {
                    if ( player != null ) {
                        println("Player move: {player.name} on {cell.column}x{cell.row}");


                        var coin:Ellipse = Duplicator.duplicate(coinHumanPlayer) as Ellipse;
                        if ( player.isAI() ) {
                            coin = Duplicator.duplicate(coinAIPlayer) as Ellipse;
                        }

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

                onMouseClicked: function ( event:MouseEvent ) :Void {
                                    if ( game.nextPlayer.isHuman() ) {
                                        (game.nextPlayer as Model.HumanPlayer).play( cell.column );
                                    }
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
                    columns: grid.columns
                    rows: grid.rows
                    content: cells
                    hgap: 0
                    vgap: 0
                }]
    }

}

