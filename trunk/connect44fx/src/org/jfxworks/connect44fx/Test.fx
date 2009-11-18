/*
 * Test.fx
 *
 * Test code. (How do you test something in JavaFX ?)
 *
 * Created on Nov 18, 2009, 8:44:23 PM
 */

package org.jfxworks.connect44fx;

import junit.framework.*;
import junit.framework.Assert.*;
import junit.textui.TestRunner;
import Model.*;

def ROWS = 6;
def COLUMNS = 7;
def LENGTH = 4;

/**
 * Aaahhh, the good 'ol days of doing this manually all over again...
 */
function run() {
    def runner:TestRunner = TestRunner{};
    def suite = TestSuite{};

    suite.addTest( runner.getTest( "org.jfxworks.connect44fx.Test$GridTest" ) );

    runner.run( suite );
}

public class GridTest extends TestCase {

    var grid:Grid;

    override function setUp() {
        grid = Model.Grid {
            rows: ROWS
            columns: COLUMNS
            minimumCellSequenceLength: LENGTH
        }
    }

    /**
     * Check whether a plain vanilla grid contains the expected data
     */
    function testInitialization() {
        for ( column in [ 0 .. <grid.columns ], row in [ 0 .. <grid.rows ] ) {
            var cell = grid.getCell(column, row);
            assertNotNull(cell);
            assertNull(cell.player);
            assertEquals(row, cell.row);
            assertEquals(column, cell.column);
        }
    }

    /**
     * Check whether the utility methods return what we expect
     */
    function testBasicMethods() {
        // are the rows shaped as expected ?
        for ( row in [ 0 .. <grid.rows ] ) {
            var cells = grid.getRow(row);
            assertEquals( COLUMNS, sizeof cells );
            for ( cell in cells ) {
                assertEquals( row, cell.row );
                assertEquals( indexof cell, cell.column );
            }
        }
        // are the columns shaped as expected ?
        for ( column in [ 0 .. <grid.columns ] ) {
            var cells = grid.getColumn(column);
            assertEquals( ROWS, sizeof cells );
            for ( cell in cells ) {
                assertEquals( column, cell.column );
                assertEquals( indexof cell, cell.row );
            }
        }
    }


}


