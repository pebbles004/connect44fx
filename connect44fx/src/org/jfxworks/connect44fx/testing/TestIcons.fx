/*
 * TestIcons.fx
 *
 * Created on Feb 16, 2010, 4:11:10 PM
 */
package org.jfxworks.connect44fx.testing;

import javafx.stage.Stage;
import org.jfxworks.connect44fx.screen.IconMessagePopup;

import javafx.scene.layout.Stack;
import javafx.scene.layout.HBox;
import javafx.scene.image.ImageView;
import javafx.scene.image.Image;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.Scene;
import org.jfxworks.connect44fx.ResourceLocator;

/**
 * @author jan
 */
def popup = IconMessagePopup { };
def url = ResourceLocator.locate("ok.png");

popup.getDesignScene();

//
//println("{__FILE__}");
//println(url);
//
//Stage {
//    scene: Scene {
//        width: 200
//        height: 200
//        content: Stack {
//            content: HBox {
//                content: ImageView {
//                    image: Image {
//                        url: url
//                        width: 100
//                        height: 100
//                    }
//                    layoutInfo: LayoutInfo {
//                        height: 100
//                        width: 100
//                    }
//                }
//                width: 100
//                height: 100
//            }
//            width: 100
//            height: 100
//        }
//    }
//}
//
