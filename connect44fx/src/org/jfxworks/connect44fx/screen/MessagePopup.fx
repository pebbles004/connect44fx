/*
 * MessagePopup.fx
 *
 * Created on Feb 16, 2010, 2:28:12 PM
 */

package org.jfxworks.connect44fx.screen;

/**
 * @author jan
 */
public class MessagePopup {

    public-read var rectangle: javafx.scene.shape.Rectangle;//GEN-BEGIN:main
    public-read var message: javafx.scene.text.Text;
    public-read var scene: javafx.scene.Scene;
    public-read var linearGradient: javafx.scene.paint.LinearGradient;
    public-read var dropShadowEffect: javafx.scene.effect.DropShadow;
    
    public-read var currentState: org.netbeans.javafx.design.DesignState;
    
    // <editor-fold defaultstate="collapsed" desc="Generated Init Block">
    init {
        message = javafx.scene.text.Text {
            layoutX: 9.0
            layoutY: 18.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: 0.0
                height: 0.0
                maxWidth: 180.0
                maxHeight: 80.0
            }
            x: 0.0
            y: 0.0
            content: "Text"
        };
        linearGradient = javafx.scene.paint.LinearGradient {
            stops: [ javafx.scene.paint.Stop { offset: 0.0, color: javafx.scene.paint.Color.web ("#FFFFFF") }, javafx.scene.paint.Stop { offset: 1.0, color: javafx.scene.paint.Color.web ("#DDDDDD") }, ]
        };
        dropShadowEffect = javafx.scene.effect.DropShadow {
        };
        rectangle = javafx.scene.shape.Rectangle {
            opacity: 1.0
            layoutX: 2.0
            layoutY: 2.0
            effect: dropShadowEffect
            fill: linearGradient
            stroke: null
            width: 200.0
            height: 100.0
            arcWidth: 5.0
            arcHeight: 5.0
        };
        scene = javafx.scene.Scene {
            content: javafx.scene.layout.Panel {
                content: getDesignRootNodes ()
            }
            cursor: javafx.scene.Cursor.HAND
        };
        
        currentState = org.netbeans.javafx.design.DesignState {
            names: [ ]
            stateChangeType: org.netbeans.javafx.design.DesignStateChangeType.PAUSE_AND_PLAY_FROM_START
            createTimeline: function (actual) {
                null
            }
        }
    }// </editor-fold>
    
    // <editor-fold defaultstate="collapsed" desc="Generated Design Functions">
    public function getDesignRootNodes () : javafx.scene.Node[] {
        [ rectangle, message, ]
    }
    
    public function getDesignScene (): javafx.scene.Scene {
        scene
    }// </editor-fold>//GEN-END:main

}
