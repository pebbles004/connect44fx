<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<%@page import="org.jfxworks.connect44fx.FacebookUserFilter"%><html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml">

<body>
<script src="http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php" type="text/javascript"></script>
<%@ page import="com.google.code.facebookapi.*" %>
<%
String user = "loggedinuser";
//FacebookXmlRestClient client = (FacebookXmlRestClient) session.getAttribute("facebook.user.client");
//FacebookXmlRestClient client = (FacebookXmlRestClient) FacebookUserFilter.userClient;
//String sessionKey = client.getCacheSessionKey();
//String sessionKey = (String) session.getAttribute("facebook.sessionid");


String sessionKey = request.getParameter("fb_sig_session_key");
%>

<h3>Welcome&nbsp;<fb:name uid="loggedinuser" useyou="false"></fb:name></h3>
<fb:profile-pic uid="loggedinuser" facebook-logo="false" size="thumb"></fb:profile-pic>
<br />

<% if(sessionKey != null) { %>	
	Your session key is <%=sessionKey%>

	<script src="http://dl.javafx.com/1.2/dtfx.js"></script>
	<script>
	    javafx(
	        {
	              archive: "connect4/Connect44FX.jar",
	              draggable: false,
	              width: 400,
	              height: 450,
	              code: "org.jfxworks.connect44fx.Main",
	              name: "Connect44FX"
	        },
	        {
		          sessionId: "<%=sessionKey%>"
	        }
	    );
	</script>		
<% } %>
<% if(sessionKey == null) { %>
	Your session key is missing
<% } %>

<script type="text/javascript">
<!--
    
    FB_RequireFeatures(["XFBML"], function()
	{
		FB.Facebook.init("48efdf44cf8597c8bd5445c0bbcb1ce6", "connect/xd_receiver.htm");
	});

	function render_xfbml()
	{
	    FB.XFBML.Host.parseDomTree();	
	}
//-->
</script>
</body>
</html>