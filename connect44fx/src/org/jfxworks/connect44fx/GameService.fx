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
import com.google.code.facebookapi.FacebookXmlRestClient;
import com.google.code.facebookapi.schema.User;
import com.google.code.facebookapi.FacebookJaxbRestClient;
import com.google.code.facebookapi.schema.FriendsGetResponse;
import com.google.code.facebookapi.ProfileField;
import java.util.ArrayList;
import java.util.List;
import com.google.code.facebookapi.schema.UsersGetInfoResponse;

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


public function getFacebookProfile(callback: function(:FacebookProfile)): Void {
    def API_KEY = "48efdf44cf8597c8bd5445c0bbcb1ce6";
    def SECRET_KEY = "70c267adb7c41b4a27144caa32d07a9f";
    def session: String = FX.getArgument("sessionId") as String;

    println("SessionId = {session}");

    var client: FacebookJaxbRestClient = new FacebookJaxbRestClient(API_KEY, SECRET_KEY, session);

    var userIds:List = new ArrayList();
    userIds.add(client.users_getLoggedInUser());

    def profileFields:List = new ArrayList();
    profileFields.add(ProfileField.UID);
    profileFields.add(ProfileField.NAME);
    profileFields.add(ProfileField.PIC_SMALL);

    def userInfo:UsersGetInfoResponse = client.users_getInfo(userIds, profileFields);
    var user:User = userInfo.getUser().get(0);
    
    println(user.getPicSmall());

    var profile = FacebookProfile {
        id: user.getUid();
        name: user.getName();
        picture: user.getPicSmall();
    };

    println("Logged in user is {profile.id}");
    callback(profile);
}



