/*
 * AI.fx Container for AI ( sort of at least ) stuff of this game.
 *
 * Modus Operandi : Add a new instance of AIPlayer in the AI_PLAYER sequence.
 *                  The AI player's level corresponds to its position in the sequence.
 *
 * Created on 24-nov-2009, 18:35:01
 */

package org.jfxworks.connect44fx;

import java.util.Random;
import org.jfxworks.connect44fx.Tactics.*;
import org.jfxworks.connect44fx.Model.*;
import org.jfxworks.connect44fx.Behavior.Game;
import org.jfxtras.async.JFXWorker;

def RANDOM:Random = Random{};

var AI_PLAYERS:AIPlayer[] = [];

public function createAIPlayer( round:Round ) :Player {
    if ( sizeof AI_PLAYERS == 0 ) {
        initializeAIPlayers();
    }

    var player:AIPlayer;

    if ( AI_PLAYERS[ round.round ] == null ) {
        player = AI_PLAYERS[ sizeof AI_PLAYERS - 1 ];
    }
    else {
        player = AI_PLAYERS[ round.round ];
    }

    player.name = round.aiPlayerName;
    player.imageUrl = round.imageUrl;

    return player;
}

function initializeAIPlayers() :Void {

// AI making random choices
    insert AIPlayer {
    } into AI_PLAYERS;
    insert AIPlayer {
        tactics: SearchForDirectWin {
            applicationProbability: .5
        }
    } into AI_PLAYERS;

// AI are actively blocking direct wins of the opponent
    insert AIPlayer {
        tactics: [ Tactics.SearchForOpponentDirectWin{ applicationProbability: .7 }, SearchForDirectWin { applicationProbability: 1.0 } ]
    } into AI_PLAYERS;
    insert AIPlayer {
        tactics: [ Tactics.SearchForOpponentDirectWin{ applicationProbability: 1 }, SearchForDirectWin { applicationProbability: 1.0 } ]
    } into AI_PLAYERS;

// AI are trying to score a direct hit
    insert AIPlayer {
        tactics: SearchForDirectWin {
            applicationProbability: 1.0
        }
    } into AI_PLAYERS;
    insert AIPlayer {
        tactics: SearchForDirectWin {
            applicationProbability: 1.0
        }
    } into AI_PLAYERS;

// AI players are looking for a hole of two cells in order to prepare for a direct hit
    insert AIPlayer {
        tactics: [ SearchForOpponentDirectWin {
                        applicationProbability: 1
                   }
                   SearchForDirectWin {
                        applicationProbability: 1
                   }
                   SearchForIndirectWin {
                        applicationProbability: .5
                        movesToMake: 2
                   }
                 ]
    } into AI_PLAYERS;
    insert AIPlayer {
        tactics: [ SearchForOpponentDirectWin {
                        applicationProbability: 1
                   }
                   SearchForDirectWin {
                        applicationProbability: 1
                   }
                   SearchForIndirectWin {
                        applicationProbability: 1
                        movesToMake: 2
                   }
                 ]
    } into AI_PLAYERS;
}

/**
 * Base class for all AI players. This class has the very basic functionality of a player
 * who's chosing a random column to put his coin into.
 */
class AIPlayer extends Player {
    public-init var tactics:Tactics[];

    def fallbackTactic = RandomChoice{};

    override public function thinkAboutNextMove( game:Game, onChose:function( :Integer ) :Void ) :Void  {
        def choiceCallback = onChose;

        def worker = JFXWorker{
                         inBackground: function() {
                            // Run each tactic after each other. Once a tactic has chosen a
                            // column the search is interrupted.
                            var choice = Tactics.NO_CHOICE;
                            for ( tactic in tactics ) {
                                if ( choice == Tactics.NO_CHOICE ) {
                                    choice = tactic.run(game);
                                }
                            }

                            // Fallback to the elementary tactic as all other tactics have failed.
                            if ( choice == Tactics.NO_CHOICE ) {
                                choice = fallbackTactic.run( game );
                            }

                            return choice;
                         }
                         onDone: function(result) {
                             choiceCallback ( result as Integer );
                         }
                     };
    }
}

