package org.jfxworks.connect44fx;

import java.util.Random;
import org.jfxworks.connect44fx.Model.*;

def RANDOM = Random{};
public def NO_CHOICE = -1;

/**
 * Describe a specific tactic to apply when playing the game of four on row.
 */
public abstract class Tactics {

    /**
     * How much probability (0 -> 1) the tactic will actually
     * be executed. Typically to be used when the player has a choice
     * between different tactics.
     */
    public-init var applicationProbability:Double = 1.0;

    /**
     * Execute the tactic IF the probability became reality. Otherwise
     * Tactics.NO_CHOICE is returned.
     */
    public function run( game:Game ) :Integer {
        if ( RANDOM.nextDouble() <= applicationProbability ) {
            return makeChoice( game );
        }

        return NO_CHOICE;
    }

    /**
     * The actual execution of the tactic. This function should return
     * a column number in the grid that's still free.
     */
    public abstract function makeChoice( game:Game ) :Integer;
}

/**
 * Faily simple tactic where a random column is chosen.
 */
public class RandomChoice extends Tactics {
    override public function makeChoice (game : Game) : Integer {
        def choices = game.grid.availableColumns();
        return choices[ RANDOM.nextInt( sizeof choices ) ];
    }
}

/**
 * A somewhat harder technique where the player looks for a cell
 * where to put a coin to have a direct win.
 *
 * The very same tactic is used to hinder the opponent. Check whether
 * he/she can make a direct score and block it.
 */
public class SearchForDirectWin extends Tactics {

    var playerType = Model.PLAYER_TYPE_AI;

    protected var holeWidth = 1;

    var holeSpaces = " ";

    postinit {
        for ( index in [ 1 .. <holeWidth ] ) {
            holeSpaces = "{holeSpaces} ";
        }
    }

    override public function makeChoice (game : Game) : Integer {
        // generate list of possible patterns
        var patterns:String[];
        def length = game.currentRound.coinsNeededToWin;
        for ( pattern in [ 0 .. <length ] ) {
            var temp = "";
            for ( index in [ 0 .. <length ] ) {
                if ( pattern == index ) {
                    temp = "{temp}{holeSpaces}";
                }
                else {
                    temp = "{temp}{playerType}";
                }
            }
            temp = temp.substring( length );
            insert temp into patterns;
        }

        // match those patterns to the board
        for ( pattern in patterns ) {
            for ( match in game.grid.findPattern( pattern ) ) {
            // where's the hole ?
                def hole = match.cells[ x | x.player == null ][0];
            // WINNER : if the hole is already at the bottom row OR a player has already played the cell underneath
                if ( hole.row == (game.grid.rows-1) or game.grid.getCell( hole.column, hole.row+1 ).player != null ) {
                    return hole.column;
                }
            }
        }

        return NO_CHOICE;
    }
}

public class SearchForOpponentDirectWin extends SearchForDirectWin {
    init {
        playerType = Model.PLAYER_TYPE_HUMAN;
    }
}


/**
 * The technique is about to look for a sequence with a hole of N cells.
 * The practical use is to look for a probable place to put a coin into.
 */
public class SearchForIndirectWin extends SearchForDirectWin {

    public-init var movesToMake = 2;

    init {
        holeWidth = movesToMake;
    }
}

