<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.ibm.icu.util.ULocale" %>
<%@ page import="com.ibm.icu.text.BreakIterator" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta content="Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved." name="COPYRIGHT" />
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>ICU4J Segmentation Demo</title>
    <%@ include file="demohead.jsf" %>
    <style type="text/css">
        .seg-form-table { border-collapse: collapse; margin-bottom: 0.5em; }
        .seg-form-table th { text-align: right; padding: 4px 8px; white-space: nowrap; vertical-align: middle; font-weight: bold; }
        .seg-form-table td { padding: 4px 8px; vertical-align: middle; }

        .segmented-text {
            font-size: 14pt;
            line-height: 2.2em;
            padding: 12px;
            border: 1px solid #ccc;
            background: #fff;
            font-family: Georgia, 'Times New Roman', serif;
            white-space: pre-wrap;
            word-break: break-all;
        }

        /* Word segment colors */
        .seg-word-0  { background-color: #cce5ff; border-bottom: 2px solid #5588bb; border-right: 1px solid red; }
        .seg-word-1  { background-color: #99ccff; border-bottom: 2px solid #5588bb; border-right: 1px solid red; }
        .seg-num-0   { background-color: #ccffcc; border-bottom: 2px solid #44aa44; border-right: 1px solid red; }
        .seg-num-1   { background-color: #99ee99; border-bottom: 2px solid #44aa44; border-right: 1px solid red; }
        .seg-kana-0  { background-color: #ffeecc; border-bottom: 2px solid #cc8844; border-right: 1px solid red; }
        .seg-kana-1  { background-color: #ffdd99; border-bottom: 2px solid #cc8844; border-right: 1px solid red; }
        .seg-ideo-0  { background-color: #ffccee; border-bottom: 2px solid #cc4488; border-right: 1px solid red; }
        .seg-ideo-1  { background-color: #ffaadd; border-bottom: 2px solid #cc4488; border-right: 1px solid red; }
        .seg-none-0  { background-color: #f0f0f0; border-right: 1px solid red; }
        .seg-none-1  { background-color: #e0e0e0; border-right: 1px solid red; }

        /* Sentence colors */
        .seg-sent-0  { background-color: #ffffcc; border-right: 1px solid red; }
        .seg-sent-1  { background-color: #ccf0ff; border-right: 1px solid red; }

        /* Character (grapheme cluster) colors */
        .seg-char-0  { background-color: #ffe8cc; border: 1px solid #cc9966; border-right: 1px solid red; }
        .seg-char-1  { background-color: #ccf0cc; border: 1px solid #66aa66; border-right: 1px solid red; }

        /* Line break colors */
        .seg-line-soft-0 { background-color: #f0f0f0; border-right: 1px solid red; }
        .seg-line-soft-1 { background-color: #e2e2e2; border-right: 1px solid red; }
        .seg-line-hard   { background-color: #ffcccc; border-right: 1px solid red; }

        /* Segment list table */
        .seg-list { border-collapse: collapse; width: 100%; margin-top: 10px; font-size: 10.5pt; }
        .seg-list th { background-color: #99CCFF; color: black; text-align: left; padding: 5px 8px; border: 1px solid #aaa; }
        .seg-list td { padding: 4px 8px; border: 1px solid #ddd; }
        .seg-list td.mono { font-family: monospace; }
        .seg-list tr:nth-child(even) { background-color: #f8f8f8; }
        .seg-list td.num { text-align: right; color: #666; }

        /* Status label colors */
        .st-letter  { color: #0044cc; font-weight: bold; }
        .st-number  { color: #007700; font-weight: bold; }
        .st-kana    { color: #cc6600; font-weight: bold; }
        .st-ideo    { color: #aa0088; font-weight: bold; }
        .st-none    { color: #888; }
        .st-hard    { color: #cc0000; font-weight: bold; }
        .st-soft    { color: #555; }
        .st-term    { color: #0000aa; font-weight: bold; }
        .st-sep     { color: #667; }

        .legend-box { margin-top: 1.5em; background-color: #f5f5f5; padding: 10px; border: 1px solid #ddd; font-size: 9pt; }
        .legend-box h4 { margin: 0 0 6px 0; }
        .legend-swatch { display: inline-block; width: 20px; height: 12px; border: 1px solid #999; margin-right: 3px; vertical-align: middle; }
        .error-box { border: 1px solid red; background-color: #fff2f2; padding: 10px; margin-top: 10px; }

        .note { font-size: 9pt; color: #555; margin-top: 4px; }
    </style>
</head>
<body>

<%@ include file="demolist.jsf" %>

<%
    request.setCharacterEncoding("utf-8");

    String locale = request.getParameter("locale");
    if (locale == null || locale.trim().isEmpty()) locale = "en";

    String type = request.getParameter("type");
    if (type == null || type.isEmpty()) type = "word";

    String text = request.getParameter("text");
    if (text == null) {
        text = "Of these, and also his commission, it pleased him to let the Governor here take a copy. "
             + "And by this the colony was to have their trading commodities from the adventurers, "
             + "for which they were to pay—1800 at the end of 7 years. "
             + "Don't you think that's interesting?\n"
             + "Thai: สวัสดีชาวโลก\n"
             + "Emoji: 👨‍👩‍👧‍👦 "
             + "🏳️‍🌈";
    }
%>

<%!
    private static String wordTypeLabel(int status) {
        if (status >= BreakIterator.WORD_IDEO   && status < BreakIterator.WORD_IDEO_LIMIT)   return "ideo";
        if (status >= BreakIterator.WORD_KANA   && status < BreakIterator.WORD_KANA_LIMIT)   return "kana";
        if (status >= BreakIterator.WORD_LETTER && status < BreakIterator.WORD_LETTER_LIMIT) return "letter";
        if (status >= BreakIterator.WORD_NUMBER && status < BreakIterator.WORD_NUMBER_LIMIT) return "number";
        return "none";
    }

    private static String wordTypeCss(int status, int idx) {
        String alt = (idx % 2 == 0) ? "-0" : "-1";
        if (status >= BreakIterator.WORD_IDEO   && status < BreakIterator.WORD_IDEO_LIMIT)   return "seg-ideo" + alt;
        if (status >= BreakIterator.WORD_KANA   && status < BreakIterator.WORD_KANA_LIMIT)   return "seg-kana" + alt;
        if (status >= BreakIterator.WORD_LETTER && status < BreakIterator.WORD_LETTER_LIMIT) return "seg-word" + alt;
        if (status >= BreakIterator.WORD_NUMBER && status < BreakIterator.WORD_NUMBER_LIMIT) return "seg-num"  + alt;
        return "seg-none" + alt;
    }

    private static String wordTypeStatusClass(int status) {
        if (status >= BreakIterator.WORD_IDEO   && status < BreakIterator.WORD_IDEO_LIMIT)   return "st-ideo";
        if (status >= BreakIterator.WORD_KANA   && status < BreakIterator.WORD_KANA_LIMIT)   return "st-kana";
        if (status >= BreakIterator.WORD_LETTER && status < BreakIterator.WORD_LETTER_LIMIT) return "st-letter";
        if (status >= BreakIterator.WORD_NUMBER && status < BreakIterator.WORD_NUMBER_LIMIT) return "st-number";
        return "st-none";
    }

    // Render a code point as a Unicode escape for the hover title
    private static String toCodePoints(String s) {
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
%>

<h2>ICU4J Segmentation Demo</h2>

<form action="<%= request.getContextPath() + request.getServletPath() %>" method="post">
<table class="seg-form-table">
    <tr>
        <th>Locale:</th>
        <td>
            <input type="text" name="locale" value="<%= escapeString(locale) %>" size="12" />
            <span class="note">&nbsp;e.g. <tt>en</tt>, <tt>th</tt>, <tt>ja</tt>, <tt>zh</tt>, <tt>de</tt>, <tt>el</tt></span>
        </td>
    </tr>
    <tr>
        <th>Type:</th>
        <td>
            <label><input type="radio" name="type" value="character" <%= "character".equals(type) ? "checked=\"checked\"" : "" %>/> Character (grapheme clusters)</label>
            &nbsp;&nbsp;
            <label><input type="radio" name="type" value="word" <%= "word".equals(type) ? "checked=\"checked\"" : "" %>/> Word</label>
            &nbsp;&nbsp;
            <label><input type="radio" name="type" value="line" <%= "line".equals(type) ? "checked=\"checked\"" : "" %>/> Line</label>
            &nbsp;&nbsp;
            <label><input type="radio" name="type" value="sentence" <%= "sentence".equals(type) ? "checked=\"checked\"" : "" %>/> Sentence</label>
        </td>
    </tr>
    <tr>
        <th>Text:</th>
        <td>
            <textarea name="text" rows="5" style="width: 60em; max-width: 100%; font-family: monospace; font-size: 10pt;"><%= escapeString(text) %></textarea>
        </td>
    </tr>
    <tr>
        <th></th>
        <td>
            <input type="submit" value=" Segment " style="font-size: 11pt; padding: 3px 14px; cursor: pointer;" />
        </td>
    </tr>
</table>
</form>

<%
try {
    ULocale ulocale = new ULocale(locale);

    BreakIterator bi;
    if ("character".equals(type)) {
        bi = BreakIterator.getCharacterInstance(ulocale);
    } else if ("line".equals(type)) {
        bi = BreakIterator.getLineInstance(ulocale);
    } else if ("sentence".equals(type)) {
        bi = BreakIterator.getSentenceInstance(ulocale);
    } else {
        bi = BreakIterator.getWordInstance(ulocale);
    }

    bi.setText(text);

    // Collect segments as [start, end, ruleStatus]
    List<int[]> segments = new ArrayList<int[]>();
    int pos = bi.first();
    int next = bi.next();
    while (next != BreakIterator.DONE) {
        segments.add(new int[]{ pos, next, bi.getRuleStatus() });
        pos = next;
        next = bi.next();
    }
%>

<h3>Segmented</h3>
<div class="segmented-text"><%
    int idx = 0;
    for (int[] seg : segments) {
        String segText = text.substring(seg[0], seg[1]);
        int status = seg[2];
        String css;

        if ("word".equals(type)) {
            css = wordTypeCss(status, idx);
        } else if ("character".equals(type)) {
            css = (idx % 2 == 0) ? "seg-char-0" : "seg-char-1";
        } else if ("sentence".equals(type)) {
            css = (idx % 2 == 0) ? "seg-sent-0" : "seg-sent-1";
        } else { // line
            boolean isHard = (status >= 100);
            css = isHard ? "seg-line-hard" : ((idx % 2 == 0) ? "seg-line-soft-0" : "seg-line-soft-1");
        }

        String codepoints = toCodePoints(segText);
        String spanTitle = "[" + seg[0] + "," + seg[1] + ") len=" + (seg[1]-seg[0])
                         + " status=" + status + (codepoints.isEmpty() ? "" : " | " + codepoints);
        out.print("<span class=\"" + css + "\" title=\"" + escapeString(spanTitle) + "\">");
        out.print(escapeString(segText));
        out.print("</span>");
        idx++;
    }
%></div>

<p class="note">Hover over a segment to see its offsets, status value, and code points.</p>

<h3>Segment List</h3>
<table class="seg-list">
    <thead>
        <tr>
            <th>#</th>
            <th>Start</th>
            <th>End</th>
            <th>Length</th>
            <th>Segment</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody>
<%
    int n = 0;
    for (int[] seg : segments) {
        n++;
        String segText = text.substring(seg[0], seg[1]);
        int status = seg[2];
        String statusLabel;
        String statusCss;

        if ("word".equals(type)) {
            statusLabel = wordTypeLabel(status);
            statusCss = wordTypeStatusClass(status);
        } else if ("line".equals(type)) {
            boolean isHard = (status >= 100);
            statusLabel = isHard ? "hard" : "soft";
            statusCss = isHard ? "st-hard" : "st-soft";
        } else if ("sentence".equals(type)) {
            boolean isTerm = (status < 100);
            statusLabel = isTerm ? "term" : "sep";
            statusCss = isTerm ? "st-term" : "st-sep";
        } else {
            statusLabel = "";
            statusCss = "";
        }
%>
        <tr>
            <td class="num"><%= n %></td>
            <td class="num"><%= seg[0] %></td>
            <td class="num"><%= seg[1] %></td>
            <td class="num"><%= seg[1] - seg[0] %></td>
            <td class="mono"><%= escapeString(segText) %></td>
            <td class="mono <%= statusCss %>">
                <%= statusLabel.isEmpty() ? "" : statusLabel + " " %>(<%= status %>)
            </td>
        </tr>
<%
    }
%>
    </tbody>
</table>

<div class="legend-box">
    <h4>Legend</h4>
<%  if ("word".equals(type)) { %>
    <p>
        <span class="legend-swatch" style="background:#cce5ff;border-bottom:2px solid #5588bb;"></span> letter &nbsp;
        <span class="legend-swatch" style="background:#ccffcc;border-bottom:2px solid #44aa44;"></span> number &nbsp;
        <span class="legend-swatch" style="background:#ffeecc;border-bottom:2px solid #cc8844;"></span> kana &nbsp;
        <span class="legend-swatch" style="background:#ffccee;border-bottom:2px solid #cc4488;"></span> ideographic &nbsp;
        <span class="legend-swatch" style="background:#f0f0f0;"></span> none (spaces, punctuation)
    </p>
    <p><b>Word status ranges:</b>
        none&nbsp;=&nbsp;0&#8211;99,
        number&nbsp;=&nbsp;100&#8211;199,
        letter&nbsp;=&nbsp;200&#8211;299,
        kana&nbsp;=&nbsp;300&#8211;399,
        ideo&nbsp;=&nbsp;400&#8211;499</p>
<%  } else if ("line".equals(type)) { %>
    <p>
        <span class="legend-swatch" style="background:#ffcccc;"></span> hard / mandatory break (status&nbsp;&#8805;&nbsp;100) &nbsp;
        <span class="legend-swatch" style="background:#f0f0f0;"></span> soft / optional break opportunity (status&nbsp;0&#8211;99)
    </p>
    <p>Each segment ends at a position where a line break is <em>permitted</em> (soft) or <em>required</em> (hard).</p>
<%  } else if ("sentence".equals(type)) { %>
    <p>
        <span class="legend-swatch" style="background:#ffffcc;"></span> terminated by sentence terminator (status&nbsp;0&#8211;99) &nbsp;
        <span class="legend-swatch" style="background:#ccf0ff;"></span> terminated by paragraph separator (status&nbsp;&#8805;&nbsp;100)
    </p>
<%  } else { %>
    <p>
        <span class="legend-swatch" style="background:#ffe8cc;border:1px solid #cc9966;"></span>
        <span class="legend-swatch" style="background:#ccf0cc;border:1px solid #66aa66;"></span>
        alternating colors show individual grapheme clusters (user-perceived characters).
        Note that multi-codepoint sequences such as emoji with ZWJ and combining characters
        form a single grapheme cluster.
    </p>
<%  } %>
</div>

<%
} catch (Throwable t) {
    java.io.StringWriter sw = new java.io.StringWriter();
    t.printStackTrace(new java.io.PrintWriter(sw));
%>
<div class="error-box">
    <b style="color: red;">Error:</b>
    <pre style="white-space: pre-wrap; font-size: 9.5pt;"><%= escapeString(sw.toString()) %></pre>
</div>
<%
}
%>

<p class="poweredByIcu">Powered by
<a href="http://www.icu-project.org/">ICU</a> <%= com.ibm.icu.util.VersionInfo.ICU_VERSION %>
</p>

</body>
</html>
