/*
 * AI.fx Container for AI ( sort of at least ) stuff of this game.
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

def AI_PLAYERS:AIPlayer[] = [];

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
}


/**
 * Base class for all AI players. This class has the very basic functionality of a player
 * who's chosing a random column to put his coin into.
 */
abstract class AIPlayer extends Player {

    public-init var pretendThinkingTime = 5s;

    public-init var pretendThinkingTimeVariation = 1s;

    override public function thinkAboutNextMove( game:Game, onChose:function( :Integer ) :Void ) :Void  {
        // do we pretend thinking really hard ?
        if ( pretendThinkingTime.gt( 0s ) ) {
            def variation = pretendThinkingTimeVariation.toMillis();
            def sleep = pretendThinkingTime.toMillis() + RANDOM.nextInt( variation * 2 ) - variation;
            Thread.currentThread().sleep( sleep );
        }

        // select a random column
        def choices = game.grid.availableColumns();
        if ( sizeof choices > 0 ) {
            onChose( choices [ RANDOM.nextInt( sizeof choices ) ] );
        }
        else {
            onSpeak( "Hey ! There nowhere I can play ! Cheater !!!!" );
            onChose( -1 );
        }
    }
}

