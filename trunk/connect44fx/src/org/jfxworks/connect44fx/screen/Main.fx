/*
 * Main.fx
 *
 * Created on Feb 12, 2010, 9:41:24 AM
 */

package org.jfxworks.connect44fx.screen;

/**
 * @author jan
 */
public class Main {

    public-read var humanImageView: javafx.scene.image.ImageView;//GEN-BEGIN:main
    public-read var stack: javafx.scene.layout.Stack;
    public-read var scoreLabel: javafx.scene.control.Label;
    public-read var highestScoreLabel: javafx.scene.control.Label;
    public-read var turnLabel: javafx.scene.control.Label;
    public-read var vbox3: javafx.scene.layout.VBox;
    public-read var aiImageView: javafx.scene.image.ImageView;
    public-read var stack2: javafx.scene.layout.Stack;
    public-read var hbox: javafx.scene.layout.HBox;
    public-read var humanName: javafx.scene.control.Label;
    public-read var aiName: javafx.scene.control.Label;
    public-read var tile: javafx.scene.layout.Tile;
    public-read var vbox5: javafx.scene.layout.VBox;
    public-read var bannerPanel: javafx.scene.layout.HBox;
    public-read var gamePanel: javafx.scene.layout.Stack;
    public-read var vbox: javafx.scene.layout.VBox;
    public-read var scene: javafx.scene.Scene;
    public-read var big: javafx.scene.text.Font;
    public-read var moderate: javafx.scene.text.Font;
    public-read var default: javafx.scene.text.Font;
    
    public-read var currentState: org.netbeans.javafx.design.DesignState;
    
    // <editor-fold defaultstate="collapsed" desc="Generated Init Block">
    init {
        humanImageView = javafx.scene.image.ImageView {
        };
        stack = javafx.scene.layout.Stack {
            width: 94.0
            height: 75.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind stack.width
                height: bind stack.height
            }
            content: [ humanImageView, ]
        };
        highestScoreLabel = javafx.scene.control.Label {
            width: 212.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind highestScoreLabel.width
                height: bind highestScoreLabel.height
            }
            text: "Highest (checking...)"
            hpos: javafx.geometry.HPos.CENTER
        };
        aiImageView = javafx.scene.image.ImageView {
        };
        stack2 = javafx.scene.layout.Stack {
            width: 94.0
            height: 75.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind stack2.width
                height: bind stack2.height
            }
            content: [ aiImageView, ]
        };
        gamePanel = javafx.scene.layout.Stack {
            width: 400.0
            height: 342.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind gamePanel.width
                height: bind gamePanel.height
                minWidth: 0.0
                minHeight: 0.0
                maxWidth: 0.0
                maxHeight: 0.0
            }
            content: [ ]
        };
        big = javafx.scene.text.Font {
            embolden: true
            size: 25.0
        };
        scoreLabel = javafx.scene.control.Label {
            width: 212.0
            height: 30.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind scoreLabel.width
                height: bind scoreLabel.height
            }
            text: "Score"
            font: big
            hpos: javafx.geometry.HPos.CENTER
            vpos: javafx.geometry.VPos.CENTER
        };
        moderate = javafx.scene.text.Font {
            oblique: true
            size: 15.0
        };
        turnLabel = javafx.scene.control.Label {
            width: 212.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind turnLabel.width
                height: bind turnLabel.height
            }
            text: ""
            font: moderate
            hpos: javafx.geometry.HPos.CENTER
            vpos: javafx.geometry.VPos.CENTER
        };
        vbox3 = javafx.scene.layout.VBox {
            width: 212.0
            height: 0.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind vbox3.width
                height: bind vbox3.height
            }
            content: [ scoreLabel, highestScoreLabel, turnLabel, ]
            spacing: 4.0
        };
        hbox = javafx.scene.layout.HBox {
            width: 400.0
            height: 75.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind hbox.width
                height: bind hbox.height
            }
            content: [ stack, vbox3, stack2, ]
            spacing: 0.0
        };
        default = javafx.scene.text.Font {
            embolden: true
            oblique: true
        };
        aiName = javafx.scene.control.Label {
            width: 180.0
            height: 0.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind aiName.width
                height: bind aiName.height
                vpos: javafx.geometry.VPos.TOP
            }
            text: "AI Player"
            font: default
            hpos: javafx.geometry.HPos.RIGHT
        };
        humanName = javafx.scene.control.Label {
            layoutX: 0.0
            width: 180.0
            height: 0.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind humanName.width
                height: bind humanName.height
                vpos: javafx.geometry.VPos.TOP
            }
            text: "Human Player"
            font: default
            hpos: javafx.geometry.HPos.LEFT
        };
        tile = javafx.scene.layout.Tile {
            width: 400.0
            height: 20.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind tile.width
                height: bind tile.height
            }
            content: [ humanName, aiName, ]
            columns: 2
            rows: 1
            hgap: 6.0
            vgap: 0.0
            hpos: javafx.geometry.HPos.CENTER
        };
        vbox5 = javafx.scene.layout.VBox {
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind vbox5.width
                height: bind vbox5.height
                hpos: javafx.geometry.HPos.CENTER
                vpos: javafx.geometry.VPos.BASELINE
            }
            content: [ hbox, tile, ]
            spacing: 6.0
        };
        bannerPanel = javafx.scene.layout.HBox {
            id: "scorePanel"
            width: 400.0
            height: 94.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind bannerPanel.width
                height: bind bannerPanel.height
                minWidth: 0.0
                minHeight: 0.0
                maxWidth: 0.0
                maxHeight: 0.0
            }
            content: [ vbox5, ]
            spacing: 0.0
        };
        vbox = javafx.scene.layout.VBox {
            layoutX: 0.0
            layoutY: 0.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind vbox.width
                height: bind vbox.height
                minWidth: 0.0
                minHeight: 0.0
                maxWidth: 0.0
                maxHeight: 0.0
            }
            content: [ bannerPanel, gamePanel, ]
            spacing: 6.0
        };
        scene = javafx.scene.Scene {
            width: 400.0
            height: 450.0
            content: javafx.scene.layout.Panel {
                content: getDesignRootNodes ()
            }
            cursor: javafx.scene.Cursor.DEFAULT
            fill: javafx.scene.paint.Color.color(0.7529412,0.7529412,0.7529412,1.0)
        };
        
        currentState = org.netbeans.javafx.design.DesignState {
            names: [ ]
            stateChangeType: org.netbeans.javafx.design.DesignStateChangeType.PAUSE_AND_PLAY_FROM_START
            timelines: [
            ]
        }
    }// </editor-fold>
    
    // <editor-fold defaultstate="collapsed" desc="Generated Design Functions">
    public function getDesignRootNodes () : javafx.scene.Node[] {
        [ vbox, ]
    }
    
    public function getDesignScene (): javafx.scene.Scene {
        scene
    }// </editor-fold>//GEN-END:main

}
