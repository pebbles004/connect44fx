/*
 * JFXTestCase.fx
 *
 * Adapter class to use a TestCase in JavaFX.
 *
 * Created on Feb 19, 2010, 4:19:20 PM
 * Jan Goyvaerts @ JFXWorks (http://jfxworks.wordpress.com)
 */

package org.jfxworks.test;

import junit.framework.TestCase;

public class JFXTestCase extends TestCase {
    public-init var testFunction:String;
    postinit {
        setName( testFunction );
    }
}
