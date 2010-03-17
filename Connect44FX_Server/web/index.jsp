<%-- 
    Document   : index
    Created on : Feb 4, 2010, 2:48:53 PM
    Author     : Jan Goyvaerts @ JFXWorks (http://jfxworks.wordpress.com)
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<%
    // get the session key from Facebook. The applet will need it to get
    // the user- and friends details.
    String sessionKey = request.getParameter("fb_sig_session_key");
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>Connect44FX Alpha 1</title>
    </head>
    <body>
        <h1>Connect44FX Alpha 2</h1>
        <h3>Brought to you by the (not yet so) famous JFXWorks !</h3>


        <% if(sessionKey == null) { %>
             <h3>IF you would have invoked this page via Facebook that is ...</h3>
             <h3>Please log in into Facebook and run the game from there.</h3>
        <% return;
           } %>

        <script src="http://dl.javafx.com/1.2/dtfx.js"></script>
        <script>
            javafx(
            {
                archive: "Connect44FX.jar",
                draggable: true,
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
    </body>
</html>
