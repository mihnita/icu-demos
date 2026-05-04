<html>
<head>
  <meta content="Copyright (c) 2008-2013 IBM Corporation and others. All Rights Reserved." name="COPYRIGHT" />
<title>Escaper</title>
<%@ page contentType="text/html; charset=utf-8" import="java.net.URI" %>
<%@ include file="demohead.jsf" %>

</head>
<body>

<%@ page import="java.util.StringJoiner" %>
<%@ page import="java.nio.charset.StandardCharsets" %>

<%@ include file="demolist.jsf"  %>

<h1>Escaper</h1>

<%
    request.setCharacterEncoding("utf-8");
    String s = request.getParameter("v");
    if(s==null) s="";

    StringJoiner utf16Dump = new StringJoiner(", ", "{ ", " }");
    for (int i = 0; i < s.length(); i++) {
        utf16Dump.add("0x" + Integer.toHexString(((int) s.charAt(i)) & 0xFFFF));
    }
    utf16Dump.add("0");

    StringJoiner utf8Dump = new StringJoiner(", ", "{ ", " }");
    byte[] bytes = s.getBytes(StandardCharsets.UTF_8);
    for (byte b : bytes) {
        utf8Dump.add("0x" + Integer.toHexString(((int) b) & 0xff));
    }
    utf8Dump.add("0");
%>

<h2>Type some stuff:</h2>
<form method="GET">
<input value="<%= s %>" name="v">
<input type="submit">
</form>

<hr>

<tt>const UChar u16chars[<%= s.length() + 1 %>] = <%= utf16Dump %>; /* <%= escapeString(s) %> */</tt><br>
<tt>const uint8_t u8chars[<%= bytes.length + 1 %>] = <%= utf8Dump %>; /* <%= escapeString(s) %> */</tt>

</body>
</html>
