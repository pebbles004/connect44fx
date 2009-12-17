/*
 * AI.fx Container for AI ( sort of at least ) stuff of this game.
 *
 * Modus Operandi : Add a new instance of AIPlayer in the AI_PLAYER sequence.
 *                  The AI player's level corresponds to its position in the sequence.
 *
 * Created on 24-nov-2009, 18:35:01
 */

package org.jfxworks.connect44fx;

import org.jfxworks.connect44fx.Model.Player;
import java.lang.UnsupportedOperationException;
import org.jfxworks.connect44fx.Model.Game;
import java.util.Random;
import java.lang.Thread;

def RANDOM:Random = Random{};

var AI_PLAYERS:AIPlayer[] = [];

public function createAIPlayer( level:Integer ) :Player {
    if ( sizeof AI_PLAYERS == 0 ) {
        initializeAIPlayers();
    }

    if ( AI_PLAYERS[ level ] == null ) {
        return AI_PLAYERS[ sizeof AI_PLAYERS - 1 ];
    }

    return AI_PLAYERS[ level ];
}

function initializeAIPlayers() :Void {
    // level 0
    insert CarelessAI {
        name: "Sinclair ZX81 1KB"
    } into AI_PLAYERS;
    // level 1
    insert CarelessAI {
        name: "Sinclair ZX Spectrum 48KB"
        pretendThinkingTimeVariation: 500ms
    } into AI_PLAYERS;
    // level 2
    insert CarelessAI {
        name: "Sinclair QL 128MB"
        pretendThinkingTime: 2s
        pretendThinkingTimeVariation: 500ms
    } into AI_PLAYERS;
}

/**
 * Base class for all AI players. This class has the very basic functionality of a player
 * who's chosing a random column to put his coin into.
 */
abstract class AIPlayer extends Player {

    public-init var pretendThinkingTime = 5s;

    public-init var pretendThinkingTimeVariation = 1s;

    override public function thinkAboutNextMove( game:Game, onChose:function( :Integer ) :Void ) :Void  {
        // TODO ASYNCHRONOUS !!!!!!!

// TODO Enable in real game
//        if ( pretendThinkingTime.gt( 0s ) ) {
//            def variation = pretendThinkingTimeVariation.toMillis();
//            def sleep = pretendThinkingTime.toMillis() + RANDOM.nextInt( variation * 2 ) - variation;
//            Thread.currentThread().sleep( sleep );
//        }

        // select a random column
        def choices = game.grid.availableColumns();
        if ( sizeof choices > 0 ) {
            onChose( choices [ RANDOM.nextInt( sizeof choices ) ] );
        }
        else {
            onSpeak( this, "Hey ! There's nowhere I can play ! Cheater !!!!" );
            onChose( -1 );
        }
    }
}

/**
 * This is a kind of player who doesn't care about tactics. Just pretend it's thinking
 * and drop a coin in a random column where there's still space left.
 */
class CarelessAI extends AIPlayer {
}
