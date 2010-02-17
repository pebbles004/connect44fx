/*
 * GameService.fx
 *
 * The various backend services needed for this game. Note that ALL
 * these services are working ASYNCHRONOUSLY. That's the reason
 * all methods accept a callback function value.
 *
 * Created on Feb 12, 2010, 11:47:14 AM
 */

package org.jfxworks.connect44fx;

import javafx.io.http.HttpRequest;
import java.io.InputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.lang.Exception;
import org.jfxworks.connect44fx.Model.Player;

// TODO Put into configuration
def scoreServiceURL = "http://atlantik-applications.appspot.com/scores/connect44fx";

/**
 * Request the highest score for this game, for the specified player.
 * Once the server has sent the score the callback function is called
 * with the score.
 */
public function requestHighestScore( playerId:String, callback:function(:Integer):Void ) :Void {
    var score = -1;
    HttpRequest {
        location: "{scoreServiceURL}/{playerId}/highest";
        method: HttpRequest.GET
        onInput: function ( input:InputStream ):Void {
            score = Integer.parseInt( getStringFromStream( input ) );
        }
        onConnecting: function() :Void {
            println("Getting highest score");
        }
       onError: function( input:InputStream ) {
            score = -2;
        }
        onException: function ( ex:Exception ) {
            ex.printStackTrace();
            score = -3;
        }
        onDone: function() :Void {
            callback( score );
        }
    }.start();
}

public function requestHighestScore( callback:function(:String,:Integer):Void ) :Void {
    var score = -1;
    var player = "";

    HttpRequest {
        location: "{scoreServiceURL}/highest";
        method: HttpRequest.GET
        onInput: function ( input:InputStream ):Void {
            def result = getStringFromStream( input );
            println("High Score result '{result}'");
            player = result.split(",")[0];
            score  = Integer.parseInt( result.split(",")[1] );
        }
        onConnecting: function() :Void {
            println("Getting highest score");
        }
       onError: function( input:InputStream ) {
            score = -2;
        }
        onException: function ( ex:Exception ) {
            ex.printStackTrace();
            score = -3;
        }
        onDone: function() :Void {
            callback( player, score );
        }
    }.start();
}

public function submitScore( player:Player, score:Integer, onDone:function(:Boolean):Void ) :Void {
    var result = true;
    HttpRequest {
        location: "{scoreServiceURL}/add?name={player.name}&score={score}";
        method: HttpRequest.GET
        onConnecting: function() :Void {
            println("Submitting score ...");
        }
        onInput: function ( input:InputStream ):Void {
            result = Boolean.parseBoolean( getStringFromStream( input ) );
        }
        onError: function( input:InputStream ) {
            println("Error while submitting score");
            result = false;
        }
        onException: function ( ex:Exception ) {
            println("Error while submitting score");
            ex.printStackTrace();
            result = false;
        }
        onDone: function() :Void {
            println("Score is submitted");
            onDone( result );
        }
    }.start();
}


function getStringFromStream( input:InputStream ) :String {
    var reader:BufferedReader = null;
    try {
        reader = new BufferedReader(new InputStreamReader(input));
        def result = reader.readLine();
        return result;
    } finally {
        reader.close();
    }
}


