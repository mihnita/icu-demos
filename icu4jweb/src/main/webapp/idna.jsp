<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.ibm.icu.text.IDNA" %>
<%@ page import="com.ibm.icu.util.VersionInfo" %>
<%@ page import="java.util.Set" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>IDNA Browser</title>
    <%@ include file="demohead.jsf" %>
    <style type="text/css">
        .idna-form-table { border-collapse: collapse; margin-bottom: 1em; }
        .idna-form-table th { text-align: right; padding: 4px 8px; white-space: nowrap; vertical-align: middle; font-weight: bold; }
        .idna-form-table td { padding: 4px 8px; vertical-align: middle; }

        .idna-result { border-collapse: collapse; width: 100%; margin-top: 1em; font-size: 10.5pt; }
        .idna-result th { background-color: #99CCFF; color: black; text-align: left; padding: 5px 8px; border: 1px solid #aaa; }
        .idna-result td { padding: 6px 8px; border: 1px solid #ddd; font-family: monospace; vertical-align: top; }
        .idna-result tr:nth-child(even) { background-color: #f8f8f8; }
        .idna-result td.mode { font-style: italic; font-family: sans-serif; color: #444; white-space: nowrap; }
        .idna-result td.codepoints { font-size: 9pt; color: #666; word-break: break-all; }

        .idna-labels { border-collapse: collapse; width: 100%; margin-top: 1.5em; font-size: 10.5pt; }
        .idna-labels th { background-color: #99CCFF; color: black; text-align: left; padding: 5px 8px; border: 1px solid #aaa; }
        .idna-labels td { padding: 5px 8px; border: 1px solid #ddd; font-family: monospace; vertical-align: top; }
        .idna-labels tr:nth-child(even) { background-color: #f8f8f8; }
        .idna-labels td.lbl-num { text-align: right; color: #888; font-family: sans-serif; }
        .idna-labels td.lbl-codepoints { font-size: 9pt; color: #666; word-break: break-all; }

        .error-list { color: #cc0000; font-size: 9pt; margin-top: 3px; }
        .error-list span { display: inline-block; background: #ffe0e0; border: 1px solid #cc8888; border-radius: 3px; padding: 1px 5px; margin: 1px 2px; }
        .no-errors { color: #080; font-size: 9pt; }
        .error-box { border: 1px solid red; background-color: #fff2f2; padding: 10px; margin-top: 10px; }
        .note { font-size: 9pt; color: #555; margin-top: 4px; }
        .idna-intro { margin-bottom: 1em; font-size: 10pt; }
        .options-row label { margin-right: 1em; }
    </style>
</head>
<body>

<%@ include file="demolist.jsf" %>

<%!
    private static String parseUnicodeEscapes(String s) {
        if (s == null) return "";
        StringBuilder result = new StringBuilder();
        int i = 0;
        while (i < s.length()) {
            char c = s.charAt(i);
            if (c == '\\' && i + 1 < s.length()) {
                char next = s.charAt(i + 1);
                if (next == 'u' || next == 'U') {
                    int hexLen = (next == 'u') ? 4 : 8;
                    if (i + 2 + hexLen <= s.length()) {
                        String hex = s.substring(i + 2, i + 2 + hexLen);
                        try {
                            int cp = Integer.parseInt(hex, 16);
                            if (Character.isValidCodePoint(cp)) {
                                result.appendCodePoint(cp);
                                i += 2 + hexLen;
                                continue;
                            }
                        } catch (NumberFormatException e) { /* fall through */ }
                    }
                }
            }
            result.append(c);
            i++;
        }
        return result.toString();
    }

    private static String toCodePointStr(String s) {
        if (s == null || s.isEmpty()) return "";
        StringBuilder sb = new StringBuilder();
        int i = 0;
        while (i < s.length()) {
            int cp = s.codePointAt(i);
            if (sb.length() > 0) sb.append(' ');
            sb.append(String.format("U+%04X", cp));
            i += Character.charCount(cp);
        }
        return sb.toString();
    }

    private static String errorsHtml(Set<IDNA.Error> errors, String escapeStringHelper) {
        if (errors == null || errors.isEmpty()) return "<span class=\"no-errors\">✓ no errors</span>";
        StringBuilder sb = new StringBuilder("<div class=\"error-list\">");
        for (IDNA.Error e : errors) {
            sb.append("<span>").append(e.name()).append("</span>");
        }
        sb.append("</div>");
        return sb.toString();
    }
%>

<%
    request.setCharacterEncoding("utf-8");
    String rawInput = request.getParameter("a");
    boolean submitted = rawInput != null;
    if (rawInput == null) rawInput = "";
    String input = parseUnicodeEscapes(rawInput);

    // Checkboxes: default on for std3/bidi/contextj; default off for contexto/transitional.
    // When the form hasn't been submitted yet, use the defaults.
    boolean useStd3      = !submitted || "1".equals(request.getParameter("std3"));
    boolean checkBidi    = !submitted || "1".equals(request.getParameter("bidi"));
    boolean checkContextJ = !submitted || "1".equals(request.getParameter("contextj"));
    boolean checkContextO = "1".equals(request.getParameter("contexto"));
    boolean transitional  = "1".equals(request.getParameter("transitional"));

    int idnaOptions = IDNA.DEFAULT;
    if (useStd3)       idnaOptions |= IDNA.USE_STD3_RULES;
    if (checkBidi)     idnaOptions |= IDNA.CHECK_BIDI;
    if (checkContextJ) idnaOptions |= IDNA.CHECK_CONTEXTJ;
    if (checkContextO) idnaOptions |= IDNA.CHECK_CONTEXTO;
    if (!transitional) {
        idnaOptions |= IDNA.NONTRANSITIONAL_TO_ASCII;
        idnaOptions |= IDNA.NONTRANSITIONAL_TO_UNICODE;
    }

    IDNA idna = IDNA.getUTS46Instance(idnaOptions);

    String toAsciiStr = null;
    String toUnicodeOfAsciiStr = null;
    String toUnicodeStr = null;
    String toAsciiOfUnicodeStr = null;

    Set<IDNA.Error> toAsciiErrors = null;
    Set<IDNA.Error> toUnicodeOfAsciiErrors = null;
    Set<IDNA.Error> toUnicodeErrors = null;
    Set<IDNA.Error> toAsciiOfUnicodeErrors = null;

    String processingError = null;

    if (!input.isEmpty()) {
        try {
            StringBuilder dest;
            IDNA.Info info;

            dest = new StringBuilder(); info = new IDNA.Info();
            idna.nameToASCII(input, dest, info);
            toAsciiStr = dest.toString();
            toAsciiErrors = info.getErrors();

            dest = new StringBuilder(); info = new IDNA.Info();
            idna.nameToUnicode(toAsciiStr, dest, info);
            toUnicodeOfAsciiStr = dest.toString();
            toUnicodeOfAsciiErrors = info.getErrors();

            dest = new StringBuilder(); info = new IDNA.Info();
            idna.nameToUnicode(input, dest, info);
            toUnicodeStr = dest.toString();
            toUnicodeErrors = info.getErrors();

            dest = new StringBuilder(); info = new IDNA.Info();
            idna.nameToASCII(toUnicodeStr, dest, info);
            toAsciiOfUnicodeStr = dest.toString();
            toAsciiOfUnicodeErrors = info.getErrors();
        } catch (Throwable t) {
            java.io.StringWriter sw = new java.io.StringWriter();
            t.printStackTrace(new java.io.PrintWriter(sw));
            processingError = sw.toString();
        }
    }
%>

<h2>IDNA Browser</h2>

<p class="idna-intro">
    Converts domain names between Unicode and
    <a href="https://www.rfc-editor.org/rfc/rfc3492">Punycode / ACE</a> (ASCII Compatible Encoding)
    using <a href="https://www.unicode.org/reports/tr46/">UTS #46</a>
    (Unicode IDNA Compatibility Processing).
    Input may use UTF-8 directly or Unicode escapes (<code>\uXXXX</code> / <code>\UXXXXXXXX</code>).
</p>

<form method="GET" action="<%= request.getContextPath() + request.getServletPath() %>">
<table class="idna-form-table">
    <tr>
        <th>Domain name:</th>
        <td>
            <input type="text" name="a" id="domainInput" value="<%= escapeString(rawInput) %>" size="52" />
            &nbsp;
            <select onchange="document.getElementById('domainInput').value=this.value; this.selectedIndex=0;">
                <option value="">&#8212; Sample domains &#8212;</option>
                <option value="www.&#x65E5;&#x672C;&#x5E73;.jp">www.日本平.jp (Japanese kanji)</option>
                <option value="www.&#x30CF;&#x30F3;&#x30C9;&#x30DC;&#x30FC;&#x30EB;&#x30B5;&#x30E0;&#x30BA;.com">www.ハンドボールサムズ.com (Japanese katakana)</option>
                <option value="&#x3042;&#x30FC;&#x308B;&#x3044;&#x3093;.com">あーるいん.com (Japanese hiragana)</option>
                <option value="&#x7406;&#x5BB9;&#x30CA;&#x30AB;&#x30E0;&#x30E9;.com">理容ナカムラ.com (Japanese)</option>
                <option value="www.&#xC608;&#xBE44;&#xAD50;&#xC0AC;.com">www.예비교사.com (Korean)</option>
                <option value="www.b&#xFC;cher.de">www.bücher.de (German)</option>
                <option value="www.f&#xE4;rgbolaget.nu">www.färgbolaget.nu (Swedish)</option>
                <option value="www.r&#xE4;ksm&#xF6;rg&#xE5;s.se">www.räksmörgås.se (Swedish)</option>
                <option value="www.br&#xE6;ndendek&#xE6;rlighed.com">www.brændendekærlighed.com (Danish)</option>
                <option value="www.m&#xE4;kitorppa.com">www.mäkitorppa.com (Finnish)</option>
                <option value="xn--bcher-kva.de">xn--bcher-kva.de (ACE/Punycode)</option>
                <option value="xn--n3h.ws">xn--n3h.ws (☃.ws ACE/Punycode)</option>
                <option value="ü.example">ü.example (escaped ü)</option>
            </select>
            &nbsp;
            <input type="submit" value=" Convert " />
        </td>
    </tr>
    <tr>
        <th>Options:</th>
        <td class="options-row">
            <label><input type="checkbox" name="std3" value="1" <%= useStd3 ? "checked=\"checked\"" : "" %> /> STD3 rules</label>
            <label><input type="checkbox" name="bidi" value="1" <%= checkBidi ? "checked=\"checked\"" : "" %> /> BiDi check</label>
            <label><input type="checkbox" name="contextj" value="1" <%= checkContextJ ? "checked=\"checked\"" : "" %> /> ContextJ check</label>
            <label><input type="checkbox" name="contexto" value="1" <%= checkContextO ? "checked=\"checked\"" : "" %> /> ContextO check</label>
            <label><input type="checkbox" name="transitional" value="1" <%= transitional ? "checked=\"checked\"" : "" %> /> Transitional (IDNA2003 compat.)</label>
        </td>
    </tr>
</table>
</form>

<% if (processingError != null) { %>
<div class="error-box">
    <b style="color: red;">Processing error:</b>
    <pre style="white-space: pre-wrap; font-size: 9.5pt;"><%= escapeString(processingError) %></pre>
</div>
<% } else if (!input.isEmpty()) { %>

<h3>Name Operations</h3>
<table class="idna-result">
    <thead>
        <tr>
            <th>Mode</th>
            <th>Text</th>
            <th>Code Points</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td class="mode">Input</td>
            <td><%= escapeString(input) %></td>
            <td class="codepoints"><%= escapeString(toCodePointStr(input)) %></td>
        </tr>
        <tr>
            <td class="mode">ToASCII(input)</td>
            <td>
                <%= escapeString(toAsciiStr) %>
                <%= errorsHtml(toAsciiErrors, null) %>
            </td>
            <td class="codepoints"><%= escapeString(toCodePointStr(toAsciiStr)) %></td>
        </tr>
        <tr>
            <td class="mode">ToUnicode(ToASCII(input))</td>
            <td>
                <%= escapeString(toUnicodeOfAsciiStr) %>
                <%= errorsHtml(toUnicodeOfAsciiErrors, null) %>
            </td>
            <td class="codepoints"><%= escapeString(toCodePointStr(toUnicodeOfAsciiStr)) %></td>
        </tr>
        <tr>
            <td class="mode">ToUnicode(input)</td>
            <td>
                <%= escapeString(toUnicodeStr) %>
                <%= errorsHtml(toUnicodeErrors, null) %>
            </td>
            <td class="codepoints"><%= escapeString(toCodePointStr(toUnicodeStr)) %></td>
        </tr>
        <tr>
            <td class="mode">ToASCII(ToUnicode(input))</td>
            <td>
                <%= escapeString(toAsciiOfUnicodeStr) %>
                <%= errorsHtml(toAsciiOfUnicodeErrors, null) %>
            </td>
            <td class="codepoints"><%= escapeString(toCodePointStr(toAsciiOfUnicodeStr)) %></td>
        </tr>
    </tbody>
</table>

<%
    /* Break the input into labels (dot-separated) and process each label individually */
    String[] labels = input.split("\\.", -1);
%>

<h3>Label Details</h3>
<table class="idna-labels">
    <thead>
        <tr>
            <th>#</th>
            <th>Label (Unicode input)</th>
            <th>ToASCII</th>
            <th>ToUnicode</th>
            <th>Code Points (input label)</th>
        </tr>
    </thead>
    <tbody>
<%
    for (int labelIdx = 0; labelIdx < labels.length; labelIdx++) {
        String lbl = labels[labelIdx];
        String lblAscii = "";
        String lblUnicode = "";
        String lblAsciiErr = "";
        String lblUnicodeErr = "";
        try {
            StringBuilder dest = new StringBuilder();
            IDNA.Info info = new IDNA.Info();
            idna.labelToASCII(lbl, dest, info);
            lblAscii = dest.toString();
            if (!info.getErrors().isEmpty()) {
                StringBuilder eb = new StringBuilder();
                for (IDNA.Error e : info.getErrors()) {
                    if (eb.length() > 0) eb.append(", ");
                    eb.append(e.name());
                }
                lblAsciiErr = eb.toString();
            }

            dest = new StringBuilder();
            info = new IDNA.Info();
            idna.labelToUnicode(lbl, dest, info);
            lblUnicode = dest.toString();
            if (!info.getErrors().isEmpty()) {
                StringBuilder eb = new StringBuilder();
                for (IDNA.Error e : info.getErrors()) {
                    if (eb.length() > 0) eb.append(", ");
                    eb.append(e.name());
                }
                lblUnicodeErr = eb.toString();
            }
        } catch (Throwable t) {
            lblAscii = "ERROR: " + t.getMessage();
        }
%>
        <tr>
            <td class="lbl-num"><%= labelIdx + 1 %></td>
            <td><%= escapeString(lbl) %></td>
            <td>
                <%= escapeString(lblAscii) %>
                <% if (!lblAsciiErr.isEmpty()) { %>
                <div class="error-list"><span><%= escapeString(lblAsciiErr) %></span></div>
                <% } %>
            </td>
            <td>
                <%= escapeString(lblUnicode) %>
                <% if (!lblUnicodeErr.isEmpty()) { %>
                <div class="error-list"><span><%= escapeString(lblUnicodeErr) %></span></div>
                <% } %>
            </td>
            <td class="lbl-codepoints"><%= escapeString(toCodePointStr(lbl)) %></td>
        </tr>
<%
    }
%>
    </tbody>
</table>

<p class="note">
    Processing uses <a href="https://www.unicode.org/reports/tr46/">UTS #46</a> (Unicode IDNA Compatibility Processing)
    via <a href="https://unicode-org.github.io/icu-docs/apidoc/dev/icu4j/com/ibm/icu/text/IDNA.html"><code>com.ibm.icu.text.IDNA</code></a>.
    Each label is a dot-separated component of the domain name.
    ToASCII converts a Unicode label to its ACE/Punycode form (xn-- prefix).
    ToUnicode decodes an ACE label back to Unicode.
    Round-trip: ToUnicode(ToASCII(input)) and ToASCII(ToUnicode(input)) show whether the conversion is lossless.
</p>

<% } %>

<p class="poweredByIcu">Powered by
<a href="http://www.icu-project.org/">ICU</a> <%= com.ibm.icu.util.VersionInfo.ICU_VERSION %>
</p>

</body>
</html>
