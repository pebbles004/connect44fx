/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.netbeans.saas.facebook;

import java.io.IOException;
import org.netbeans.saas.RestConnection;
import org.netbeans.saas.RestResponse;

/**
 * FacebookSocialNetworkingService Service
 *
 * @author jan
 */

public class FacebookSocialNetworkingService {

    /** Creates a new instance of FacebookSocialNetworkingService */
    public FacebookSocialNetworkingService() {
    }

    private static void sleep(long millis) {
        try {
            Thread.sleep(millis);
        } catch(Throwable th) {}
    }

    /**
     *
     * @param format
     * @return an instance of RestResponse
     */
    public static RestResponse usersGetLoggedInUser( String format ) throws IOException {
        String v = "1.0";
        String method = "facebook.users.getLoggedInUser";
        FacebookSocialNetworkingServiceAuthenticator.login();
        String callId = String.valueOf( System.currentTimeMillis() );
        String apiKey = FacebookSocialNetworkingServiceAuthenticator.getApiKey();
        String sessionKey = FacebookSocialNetworkingServiceAuthenticator.getSessionKey();
        String sig = FacebookSocialNetworkingServiceAuthenticator.sign( new String[ ][ ]{ { "api_key", apiKey }, { "session_key", sessionKey }, { "call_id", callId }, { "v", v }, { "format", format }, { "method", method } } );
        String[][] pathParams = new String[ ][ ]{  };
        String[][] queryParams = new String[ ][ ]{ { "api_key", "" + apiKey + "" }, { "session_key", sessionKey }, { "call_id", callId }, { "sig", sig }, { "v", v }, { "format", format }, { "method", method } };
        RestConnection conn = new RestConnection( "http://api.facebook.com/restserver.php", pathParams, queryParams );
        sleep( 1000 );
        return conn.get( null );
    }

    /**
     *
     * @param uids
     * @param fields
     * @param format
     * @return an instance of RestResponse
     */
    public static RestResponse usersGetinfo( String uids, String fields, String format ) throws IOException {
        String v = "1.0";
        String method = "facebook.users.getinfo";
        FacebookSocialNetworkingServiceAuthenticator.login();
        String callId = String.valueOf( System.currentTimeMillis() );
        String apiKey = FacebookSocialNetworkingServiceAuthenticator.getApiKey();
        String sessionKey = FacebookSocialNetworkingServiceAuthenticator.getSessionKey();
        String sig = FacebookSocialNetworkingServiceAuthenticator.sign( new String[ ][ ]{ { "api_key", apiKey }, { "session_key", sessionKey }, { "call_id", callId }, { "v", v }, { "uids", uids }, { "fields", fields }, { "format", format }, { "method", method } } );
        String[][] pathParams = new String[ ][ ]{  };
        String[][] queryParams = new String[ ][ ]{ { "api_key", "" + apiKey + "" }, { "session_key", sessionKey }, { "call_id", callId }, { "sig", sig }, { "v", v }, { "uids", uids }, { "fields", fields }, { "format", format }, { "method", method } };
        RestConnection conn = new RestConnection( "http://api.facebook.com/restserver.php", pathParams, queryParams );
        sleep( 1000 );
        return conn.get( null );
    }
}
