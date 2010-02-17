<%-- 
    Document   : index
    Created on : Feb 4, 2010, 2:48:53 PM
    Author     : jan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>Connect44FX Alpha 1</title>
    </head>
    <body>
        <h1>Connect44FX Alpha 1</h1>
        <h3>Brought to you by the (not yet so) famous JFXWorks !</h3>
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
            }
        );
        </script>
    </body>
</html>
