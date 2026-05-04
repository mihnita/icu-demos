<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.WebUtil" %>
<%@ include file="header.jspf" %>

<%
    String v = (String) request.getAttribute("v");
    Integer codePointCount = (Integer) request.getAttribute("codePointCount");
    Integer bytesLength = (Integer) request.getAttribute("bytesLength");
    Integer charsLength = (Integer) request.getAttribute("charsLength");
    String utf8Dump = (String) request.getAttribute("utf8Dump");
    String utf16Dump = (String) request.getAttribute("utf16Dump");
    String utf32Dump = (String) request.getAttribute("utf32Dump");
%>

<div class="card">
    <h3>Unicode Hex C-Style Array Escaper</h3>
    <form method="POST">
        <div class="form-group">
            <label for="v">Enter characters to dump:</label>
            <input class="input-control" style="font-size: 1.15rem;" type="text" id="v" name="v" value="<%= WebUtil.escapeHtml(v) %>" />
        </div>
        <button type="submit" class="btn btn-primary">Generate Hex Dumps</button>
    </form>
</div>

<div class="card result-card">
    <h3>C/C++ Code Dumps</h3>
    <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.5rem;">
        Copy and paste the matching code snippet for your target C++ unicode architecture. 
        Text size counts: <strong><%= charsLength %></strong> UTF-16 chars, <strong><%= codePointCount %></strong> Unicode code points, <strong><%= bytesLength %></strong> UTF-8 bytes.
    </p>
    
    <pre class="code-output" style="line-height: 1.6; font-size: 0.95rem; color: #38bdf8;">
// UTF-8
const uint8_t u8chars[<%= bytesLength + 1 %>] = <%= utf8Dump %>; /* <%= WebUtil.escapeHtml(v) %> */

// UTF-16
const UChar u16chars[<%= charsLength + 1 %>] = <%= utf16Dump %>; /* <%= WebUtil.escapeHtml(v) %> */

// UTF-32
const UChar32 u32chars[<%= codePointCount + 1 %>] = <%= utf32Dump %>; /* <%= WebUtil.escapeHtml(v) %> */
    </pre>
</div>

<%@ include file="footer.jspf" %>
