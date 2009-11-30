<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<%@page import="java.util.Enumeration"%><html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml">

<body>
<script src="http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php" type="text/javascript"></script>
<%@ page import="com.google.code.facebookapi.*" %>
<%
String sessionKey = request.getParameter(FacebookParam.SESSION_KEY.toString());
String user = "loggedinuser";
String API_KEY = "48efdf44cf8597c8bd5445c0bbcb1ce6";
String APP_SECRET = "70c267adb7c41b4a27144caa32d07a9f";

sessionKey = request.getParameter("fb_sig_session_key");

if(sessionKey == null) {
	FacebookXmlRestClient client = new FacebookXmlRestClient(API_KEY, APP_SECRET);
	String token = client.auth_createToken();
	
	response.sendRedirect("http://www.facebook.com/tos.php?api_key=" + API_KEY + "&auth_token=" + token + "&next=&v=1.0&canvas");
} else {
	user = request.getParameter("fb_sig_user");
}

%>
<h1>Welcome<fb:name uid="loggedinuser" useyou="false"></fb:name></h1>
<fb:profile-pic uid="loggedinuser" facebook-logo="false" size="thumb"></fb:profile-pic>
<br />
<% if(sessionKey != null) { %>
	<script src="http://dl.javafx.com/1.2/dtfx.js"></script>
	<script>
	    javafx(
	        {
	              archive: "javafx/TestFacebook.jar",
	              draggable: false,
	              width: 720,
	              height: 500,
	              code: "testfacebook.Main",
	              name: "TestFacebook"
	        },
	        {
		          sessionId: "<%=sessionKey%>"
	        }
	    );
	</script>		
<% } %>


<script type="text/javascript"><!--
    
    FB_RequireFeatures(["XFBML"], function()
	{
	  FB.Facebook.init("48efdf44cf8597c8bd5445c0bbcb1ce6", "connect/xd_receiver.htm");
	});

	function render_xfbml()
	{
	    FB.XFBML.Host.parseDomTree();	
	}
</script>

</body>
</html>