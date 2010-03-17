package org.jfxworks.connect44fx.facebook;

import facebook.socialnetworkingservice.facebookresponse.*;
import java.net.URL;
import org.netbeans.saas.facebook.FacebookSocialNetworkingService;
import org.netbeans.saas.RestResponse;
import org.netbeans.saas.facebook.FacebookSocialNetworkingServiceAuthenticator;
import java.lang.IllegalStateException;
import java.lang.Exception;
import java.lang.RuntimeException;
import org.jfxworks.connect44fx.facebook.FacebookProfile;

/**
 *
 * @author Jan Goyvaerts @ JFXWorks (http://jfxworks.wordpress.com)
 */
public class FacebookAPI {

    public-init var sessionKey: String on replace {
        FacebookSocialNetworkingServiceAuthenticator.sessionKey = sessionKey;
        println("Facebook session key: {sessionKey}");
    }

    public function getLoggedInUser(): FacebookProfile {
        try {
            def uid = getAPIUser();
            return getUserInfo( uid );
        } catch ( ex: Exception ) {
            throw new RuntimeException( ex );
        }
    }

    function getAPIUser():Long {
        def result = FacebookSocialNetworkingService.usersGetLoggedInUser( "" );

        if ( result.getDataAsObject( UsersGetLoggedInUserResponse.class ) instanceof UsersGetLoggedInUserResponse ) {

            def resultObj = result.getDataAsObject( UsersGetLoggedInUserResponse.class );
            return resultObj.getValue();

        } else if ( result.getDataAsObject( ErrorResponse.class ) instanceof ErrorResponse ) {

            def resultObj = result.getDataAsObject( ErrorResponse.class );
            throw new IllegalStateException( "Error from Facebook API : {resultObj.getErrorMsg()}" );

        }
        throw new IllegalStateException( "The Facebook API returned an object of unexpected type: {result.getDataAsString()}" );
    }

    public function getUserInfo( uid: Long ): FacebookProfile {
        def uids = "{uid}";
        def fields = "uid,name,pic_small";
        def format = "";

        def result = FacebookSocialNetworkingService.usersGetinfo( uids, fields, format );
        if ( result.getDataAsObject( UsersGetinfoResponse.class ) instanceof UsersGetinfoResponse ) {
            def resultObj = result.getDataAsObject( UsersGetinfoResponse.class );
            def user = resultObj.getUser().get( 0 );
            
            return FacebookProfile {
                id: user.getUid()
                name: user.getName()
                picture: user.getPicSmall().getValue()
            }

        } else if ( result.getDataAsObject( ErrorResponse.class ) instanceof ErrorResponse ) {
            def resultObj = result.getDataAsObject( ErrorResponse.class );
            throw new IllegalStateException( "Error from Facebook API : {resultObj.getErrorMsg()}" );
        }
        throw new IllegalStateException( "The Facebook API returned an object of unexpected type: {result.getDataAsString()}" );
    }
}
