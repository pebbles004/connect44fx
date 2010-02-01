/*
 * RandomTests.fx
 *
 * Created on Feb 1, 2010, 12:47:28 PM
 */

package org.jfxworks.connect44fx.testing;
import java.util.Random;
import java.lang.IllegalArgumentException;

/**
 * @author jan
 */

def tests = RandomTests{};
tests.test();

class RandomTests {

    var rounds:Round[] = [];

    postinit {
        for ( index in [ 1 .. 1000 ] ) {
            def random = new Random(123456789);
            insert Round {
                rows: random.nextInt( 1000 );
                aiPlayerName: generateName( random );
                columns: random.nextInt( 1500 );
                coinsNeededToWin: random.nextInt( 20 );
            } into rounds;
        }
    }

    function generateName( random:Random ) :String {
        var name = "";
        for ( index in [ 1 .. 4 ] ) {
            name = "{name}{generateCharacter(random)}";
        }
        name = "{name} {1000 + random.nextInt(8999)}";

        return name;
    }

    function generateCharacter( random:Random ) :String {
        var char:Character = 65 + random.nextInt(26);
        return char.toString();
    }


    public function test() {
        def round0 = rounds[0];
        delete rounds[0];
        for ( round in rounds ) {
            if ( round != round0 ) {
                throw new IllegalArgumentException("{round} != {round0}");
            }
            println(round);
        }
    }
}

class Round {
    var rows = 0;
    var columns = 0;
    var aiPlayerName = "";
    var coinsNeededToWin = 0;

    override function equals ( other:Object ) :Boolean {
        if ( other == null ) {
            return false;
        }

        if ( not ( other instanceof Round ) ) {
            return false;
        }



        if ( FX.isSameObject( this, other ) ) {
            return true;
        }

        def oRound = (other as Round);

        if ( oRound.aiPlayerName != this.aiPlayerName or oRound.rows != this.rows or oRound.columns != this.columns or oRound.coinsNeededToWin != this.coinsNeededToWin) {
            return false;
        }
        return true;
    }

    override public function toString() :String {
        return "name: { aiPlayerName } rows: {rows} columns: {columns} coins: {coinsNeededToWin}";
    }
}
