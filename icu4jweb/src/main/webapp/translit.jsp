<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ include file="demohead.jsf" %>
<title>ICU Transliterator Demo</title>
<style type="text/css">
    .translitTable { border: 1px solid #ccc; background-color: #f9f9f9; width: 100%; }
    .translitTable th { text-align: right; vertical-align: top; padding: 5px; background-color: #eee; width: 150px; }
    .translitTable td { padding: 5px; }
    .rulesText { font-family: monospace; width: 100%; }
    .availableIds { font-size: small; column-count: 4; }
    .error { color: red; font-weight: bold; }
    .result { border: 1px inset #ccc; padding: 5px; background-color: #fff; min-height: 1em; white-space: pre-wrap; }
</style>
<script type="text/javascript">
    function setId(id) {
        document.getElementById('idInput').value = id;
    }
</script>
</head>
<body>

<%@ include file="demolist.jsf"  %>

<%@ page import="com.ibm.icu.text.Transliterator" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.TreeSet" %>

<h2>Transliterator Demo</h2>

<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");
    String text = request.getParameter("text");
    String rules = request.getParameter("rules");
    String action = request.getParameter("action");
    
    if (id == null) id = "Any-Hex";
    if (text == null) text = "";
    if (rules == null) rules = "";
    if (action == null) action = "transliterate";

    String result = "";
    String error = null;
    String showRulesResult = null;

    if ("transliterate".equals(action) && (!text.isEmpty())) {
        try {
            Transliterator t;
            if (rules != null && !rules.trim().isEmpty()) {
                t = Transliterator.createFromRules(id, rules, Transliterator.FORWARD);
            } else {
                t = Transliterator.getInstance(id);
            }
            result = t.transliterate(text);
        } catch (Exception e) {
            error = e.getMessage();
        }
    } else if ("transliterateInverse".equals(action) && (!text.isEmpty())) {
        try {
            Transliterator t = Transliterator.getInstance(id).getInverse();
            result = t.transliterate(text);
        } catch (Exception e) {
            error = e.getMessage();
        }
    } else if ("showRules".equals(action)) {
        try {
            Transliterator t = Transliterator.getInstance(id);
            showRulesResult = t.toRules(true);
        } catch (Exception e) {
            error = e.getMessage();
        }
    } else if ("inverseId".equals(action)) {
        try {
            Transliterator t = Transliterator.getInstance(id);
            id = t.getInverse().getID();
        } catch (Exception e) {
            error = e.getMessage();
        }
    }
%>

<form action="translit.jsp" method="post">
    <table class="translitTable">
        <tr>
            <th><label for="idInput">Compound ID or Filter</label></th>
            <td>
                <input type="text" id="idInput" name="id" value="<%= escapeString(id) %>" style="width: 50%;" />
                <select onchange="setId(this.value)">
                    <option value="">-- Common IDs --</option>
                    <option value="Any-Hex">Any-Hex</option>
                    <option value="Hex-Any">Hex-Any</option>
                    <option value="Any-Latin">Any-Latin</option>
                    <option value="Latin-ASCII">Latin-ASCII</option>
                    <option value="Any-Name">Any-Name</option>
                    <option value="Name-Any">Name-Any</option>
                    <option value="Any-Upper">Any-Upper</option>
                    <option value="Any-Lower">Any-Lower</option>
                    <option value="Any-Title">Any-Title</option>
                    <option value="Any-NFC">Any-NFC</option>
                    <option value="Any-NFD">Any-NFD</option>
                    <option value="Greek-Latin">Greek-Latin</option>
                    <option value="Cyrillic-Latin">Cyrillic-Latin</option>
                    <option value="Devanagari-Latin">Devanagari-Latin</option>
                    <option value="Katakana-Latin">Katakana-Latin</option>
                    <option value="Hiragana-Latin">Hiragana-Latin</option>
                    <option value="Simplified-Traditional">Simplified-Traditional</option>
                    <option value="Traditional-Simplified">Traditional-Simplified</option>
                </select>
                <button type="submit" name="action" value="inverseId">Inverse ID</button>
            </td>
        </tr>
        <tr>
            <th><label for="rulesInput">Custom Rules (optional)</label></th>
            <td>
                <textarea id="rulesInput" name="rules" rows="5" class="rulesText"><%= escapeString(rules) %></textarea>
                <br/><small>If rules are provided, they will be used to create a custom transliterator with the given ID.</small>
            </td>
        </tr>
        <tr>
            <th><label for="textInput">Input Text</label></th>
            <td>
                <textarea id="textInput" name="text" rows="10" style="width: 100%;"><%= escapeString(text) %></textarea>
            </td>
        </tr>
        <tr>
            <th></th>
            <td>
                <button type="submit" name="action" value="transliterate">Transliterate</button>
                <button type="submit" name="action" value="transliterateInverse">Transliterate Inverse</button>
                <button type="submit" name="action" value="showRules">Show Rules for ID</button>
                <button type="button" onclick="document.getElementById('textInput').value=''; document.getElementById('resultArea').innerHTML='';">Clear</button>
            </td>
        </tr>
    </table>
</form>

<% if (error != null) { %>
    <p class="error">Error: <%= escapeString(error) %></p>
<% } %>

<% if (!result.isEmpty()) { %>
    <h3>Result</h3>
    <div id="resultArea" class="result"><%= escapeString(result) %></div>
<% } %>

<% if (showRulesResult != null) { %>
    <h3>Rules for <%= escapeString(id) %></h3>
    <textarea rows="15" class="rulesText" readonly="readonly"><%= escapeString(showRulesResult) %></textarea>
<% } %>

<hr/>
<h3>Available System IDs</h3>
<div class="availableIds">
<%
    TreeSet<String> sortedIds = new TreeSet<String>();
    Enumeration<String> ids = Transliterator.getAvailableIDs();
    while (ids.hasMoreElements()) {
        sortedIds.add(ids.nextElement());
    }
    for (String availableId : sortedIds) {
%>
    <div><a href="javascript:setId('<%= availableId %>')"><%= availableId %></a></div>
<%
    }
%>
</div>

<p class='poweredByIcu'>Powered by
<a href="http://www.icu-project.org/">ICU</a> <%= com.ibm.icu.util.VersionInfo.ICU_VERSION %></p>

</body>
</html>
