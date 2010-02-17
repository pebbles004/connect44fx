/*
 * ResourceLocator.fx
 *
 * Created on Feb 16, 2010, 5:17:07 PM
 */

package org.jfxworks.connect44fx;

def THIS = "{__DIR__}";

public function locate( resource:String ) :String {
    return "{THIS.substring( 0, THIS.indexOf("!") + 1)}/org/jfxworks/connect44fx/resources/{resource}";
}

