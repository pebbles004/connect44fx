/*
 * IconMessagePopup.fx
 *
 * Created on Feb 16, 2010, 3:27:24 PM
 */

package org.jfxworks.connect44fx.screen;

import org.jfxworks.connect44fx.ResourceLocator;

/**
 * @author jan
 */
public class IconMessagePopup {

    public-read var rectangle: javafx.scene.shape.Rectangle;//GEN-BEGIN:main
    public-read var icon: javafx.scene.layout.Stack;
    public-read var message: javafx.scene.text.Text;
    public-read var panel: javafx.scene.layout.Panel;
    public-read var scene: javafx.scene.Scene;
    public-read var linearGradient: javafx.scene.paint.LinearGradient;
    public-read var dropShadowEffect: javafx.scene.effect.DropShadow;
    
    public-read var currentState: org.netbeans.javafx.design.DesignState;
    
    // <editor-fold defaultstate="collapsed" desc="Generated Init Block">
    init {
        icon = javafx.scene.layout.Stack {
            layoutX: 12.0
            layoutY: 14.0
            width: 63.0
            height: 60.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind icon.width
                height: bind icon.height
                maxWidth: 70.0
                maxHeight: 70.0
            }
            content: [ ]
        };
        message = javafx.scene.text.Text {
            layoutX: 84.0
            layoutY: 33.0
            content: "Text"
        };
        linearGradient = javafx.scene.paint.LinearGradient {
            stops: [ javafx.scene.paint.Stop { offset: 0.0, color: javafx.scene.paint.Color.web ("#FFFFFF") }, javafx.scene.paint.Stop { offset: 1.0, color: javafx.scene.paint.Color.web ("#DDDDDD") }, ]
        };
        dropShadowEffect = javafx.scene.effect.DropShadow {
        };
        rectangle = javafx.scene.shape.Rectangle {
            effect: dropShadowEffect
            fill: linearGradient
            width: 250.0
            height: 100.0
        };
        panel = javafx.scene.layout.Panel {
            width: 250.0
            height: 100.0
            layoutInfo: javafx.scene.layout.LayoutInfo {
                width: bind panel.width
                height: bind panel.height
            }
            content: [ rectangle, icon, message, ]
        };
        scene = javafx.scene.Scene {
            content: javafx.scene.layout.Panel {
                content: getDesignRootNodes ()
            }
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
        [ panel, ]
    }
    
    public function getDesignScene (): javafx.scene.Scene {
        scene
    }// </editor-fold>//GEN-END:main

    var okImageImageURL: String = ResourceLocator.locate( "ok.png" );
}
