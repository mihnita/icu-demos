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

    final int codePointCount[] = { 0 };
    StringJoiner utf32Dump = new StringJoiner(", ", "{ ", " }");
    s.codePoints().forEach(cp -> {
        codePointCount[0]++;
        utf32Dump.add("0x" + Integer.toHexString(cp));
    });
    utf32Dump.add("0");

    StringJoiner utf16Dump = new StringJoiner(", ", "{ ", " }");
    s.chars().forEach(ch16 -> utf16Dump.add("0x" + Integer.toHexString(ch16 & 0xffff)));
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

<blockquote><code>
// UTF-8<br>
const uint8_t u8chars[<%= bytes.length + 1 %>] = <%= utf8Dump %>; /* <%= escapeString(s) %> */<br>
// UTF-16<br>
const UChar u16chars[<%= s.length() + 1 %>] = <%= utf16Dump %>; /* <%= escapeString(s) %> */<br>
// UTF-32<br>
const UChar32 u32chars[<%= codePointCount[0] + 1 %>] = <%= utf32Dump %>; /* <%= escapeString(s) %> */<br>
</code></blockquote>

</body>
</html>
