/*
 * View.fx
 *
 * Script containing all visual components of the game. Initially we'll create them with
 * hardcoding in factory methods. But in the end some kind of graphics software should be used to
 * create round-dependend graphics in those same methods.
 *
 * Created on 25-nov-2009, 14:43:38
 */
package org.jfxworks.connect44fx;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import org.jfxworks.connect44fx.Model.*;
import javafx.fxd.Duplicator;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.Panel;
import javafx.scene.layout.Stack;
import javafx.scene.layout.Tile;
import java.lang.Integer;
import java.lang.Void;
import org.jfxworks.connect44fx.Model;
import javafx.animation.*;

/**
 * The board class represents the rectangle area with the matrix of holes in it; with coins falling down
 * in the columns the players added a coin into.
 * Typically each "hole" will be one type of node, while the coins will be another.
 */
public class Board extends CustomNode {

    public-init var game: Game;

    public-init var width:Integer;

    public-init var height:Integer;

    def container:Panel = Panel {};

    override protected function create(): Node {
        container;
    }

    var currentRound = bind game.round on replace {
        if ( currentRound > 0 ) {
            rebuildContent( currentRound );
        }
    }

    var currentPlayer = bind game.currentPlayer;

    var cellWidth:Integer = 0;
    var cellHeight:Integer = 0;

    var coinHumanPlayer:Node;
    var coinAIPlayer:Node;
    var cellNode:Node;

    function rebuildContent( round:Integer ) :Void {
        // cell sizing
        cellWidth  = ( width  / game.grid.columns ) as Integer;
        cellHeight = ( height / game.grid.rows ) as Integer;

        // coin nodes
        coinHumanPlayer = NodeFactory.createCoinNode(cellWidth, cellHeight, round, game.humanPlayer);
        coinAIPlayer    = NodeFactory.createCoinNode(cellWidth, cellHeight, round, game.aiPlayer);
        cellNode        = NodeFactory.createCellNode(cellWidth, cellHeight, round);

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

                    // TODO Why isn't the binding always working ? In Grid a player is assigned to
                    //      to the cell but sometimes the binding doesn't fire at all.
                    def player = bind cell.player on replace {
                        println("Cell player changes ! {cell} {player}");
                        if ( player != null ) {//if ( isInitialized( player ) ) {
                            var coin:Node;
                            if ( player.isHuman() ) {
                                coin = Duplicator.duplicate ( coinHumanPlayer );
                            }
                            if ( player.isAI() ) {
                                coin = Duplicator.duplicate ( coinAIPlayer );
                            }
                            println("Adding coin {coin} to game");
                            insert coin into stack.content;
                        }
                    }

                    def win = bind cell.winning on replace {
                        if ( win ) {
                            def coin = stack.content[sizeof stack.content - 1];
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


                    onMouseClicked: function( event:MouseEvent ) :Void {
                        // only humans can click on the board to play WHILE the game is ongoing !!!
                        if ( currentPlayer.isHuman() and game.turn > 0 ) {
                            (currentPlayer as Model.HumanPlayer).play( cell.column );
                        }
                    }
                }
            }
        }
    }
}

