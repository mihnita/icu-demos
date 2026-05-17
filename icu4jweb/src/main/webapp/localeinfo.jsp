<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java"
 import="com.ibm.icu.util.*,com.ibm.icu.text.*,java.util.*"
 contentType="text/html; charset=utf-8"
 pageEncoding="utf-8"%>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
  <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
  <meta content="Copyright (c) 2024 Unicode, Inc. and others. All Rights Reserved." name="COPYRIGHT" />
  <title>Locale Information</title>
<%@ include file="demohead.jsf" %>
</head>
<body style="margin: 0.5em">
<%@ include file="demolist.jsf" %>

<h2>Locale Information</h2>

<%
request.setCharacterEncoding("UTF-8");
String selectedLocale = request.getParameter("locale");
if (selectedLocale == null || selectedLocale.isEmpty()) {
    selectedLocale = request.getLocale().toString();
}
ULocale uloc = new ULocale(selectedLocale);
ULocale displayLocale = ULocale.getDefault();
%>

<form action='<%= request.getRequestURI() %>' method="get">
<table class='formatTable'>
<tr><th><label for="locale">Select Locale</label></th>
    <td><select id="locale" name="locale" onchange="this.form.submit()">
<%
ULocale[] locales = com.ibm.icu.text.NumberFormat.getAvailableULocales();
// Sort locales by display name
List<ULocale> localeList = new ArrayList<ULocale>(Arrays.asList(locales));
Collections.sort(localeList, new Comparator<ULocale>() {
    public int compare(ULocale o1, ULocale o2) {
        return o1.getDisplayName().compareTo(o2.getDisplayName());
    }
});

for (ULocale currULoc : localeList) {
    String currLocStr = currULoc.toString();
    boolean isSelected = selectedLocale.equals(currLocStr);
    out.print("<option" + (isSelected ? " selected='selected'" : "") + " value='" + currLocStr + "'>");
    out.print(currLocStr + " [" + currULoc.getDisplayName() + "]");
    out.println("</option>");
}
%>
    </select>
    OR enter custom: <input type="text" name="locale" value="<%= escapeString(selectedLocale) %>" />
    <input type="submit" value="Update" />
    </td></tr>
</table>
</form>

<hr/>

<h3>Basic Information</h3>
<table border="1" cellpadding="4" cellspacing="0">
    <tr><th>Property</th><th>Value</th></tr>
    <tr><td>ULocale.toString()</td><td><%= escapeString(uloc.toString()) %></td></tr>
    <tr><td>ULocale.getName()</td><td><%= escapeString(uloc.getName()) %></td></tr>
    <tr><td>ULocale.getBaseName()</td><td><%= escapeString(uloc.getBaseName()) %></td></tr>
    <tr><td>Canonical Locale</td><td><%= escapeString(ULocale.canonicalize(uloc.getName())) %></td></tr>
    <tr><td>Likely Subtags</td><td><%= escapeString(ULocale.addLikelySubtags(uloc).toString()) %></td></tr>
    <tr><td>Display Name</td><td><%= escapeString(uloc.getDisplayName(displayLocale)) %></td></tr>
    <tr><td>Parent Locale</td><td><%= uloc.getFallback() != null ? escapeString(uloc.getFallback().toString()) : "None" %></td></tr>
    <tr><td>Language</td><td><%= escapeString(uloc.getLanguage()) %> (<%= escapeString(uloc.getDisplayLanguage(displayLocale)) %>)</td></tr>
    <tr><td>Script</td><td><%= escapeString(uloc.getScript()) %> (<%= escapeString(uloc.getDisplayScript(displayLocale)) %>)</td></tr>
    <tr><td>Country</td><td><%= escapeString(uloc.getCountry()) %> (<%= escapeString(uloc.getDisplayCountry(displayLocale)) %>)</td></tr>
    <tr><td>Variant</td><td><%= escapeString(uloc.getVariant()) %> (<%= escapeString(uloc.getDisplayVariant(displayLocale)) %>)</td></tr>
    <tr><td>Character Orientation</td><td><%= uloc.getCharacterOrientation() %></td></tr>
    <tr><td>Line Orientation</td><td><%= uloc.getLineOrientation() %></td></tr>
</table>

<h3>Keywords</h3>
<table border="1" cellpadding="4" cellspacing="0">
    <tr><th>Keyword</th><th>Value</th></tr>
<%
Iterator<String> keywords = uloc.getKeywords();
if (keywords != null && keywords.hasNext()) {
    while (keywords.hasNext()) {
        String key = keywords.next();
        String value = uloc.getKeywordValue(key);
        out.println("<tr><td>" + escapeString(key) + "</td><td>" + escapeString(value) + "</td></tr>");
    }
} else {
    out.println("<tr><td colspan='2'>No keywords</td></tr>");
}
%>
</table>

<h3>Formatting Examples</h3>
<table border="1" cellpadding="4" cellspacing="0">
    <tr><th>Type</th><th>Example</th></tr>
    <tr><td>Number</td><td><%= NumberFormat.getInstance(uloc).format(1234567.89) %></td></tr>
    <tr><td>Currency</td><td><%= NumberFormat.getCurrencyInstance(uloc).format(1234567.89) %></td></tr>
    <tr><td>Percent</td><td><%= NumberFormat.getPercentInstance(uloc).format(0.89) %></td></tr>
    <tr><td>Date (Full)</td><td><%= DateFormat.getDateInstance(DateFormat.FULL, uloc).format(new Date()) %></td></tr>
    <tr><td>Time (Full)</td><td><%= DateFormat.getTimeInstance(DateFormat.FULL, uloc).format(new Date()) %></td></tr>
    <tr><td>DateTime (Full)</td><td><%= DateFormat.getDateTimeInstance(DateFormat.FULL, DateFormat.FULL, uloc).format(new Date()) %></td></tr>
</table>

<h3>Exemplar Characters</h3>
<%
try {
    UnicodeSet exemplars = LocaleData.getExemplarSet(uloc, 0);
    out.println("<pre>" + escapeString(exemplars.toString()) + "</pre>");
} catch (Exception e) {
    out.println("Error getting exemplars: " + e.getMessage());
}
%>

<p class='poweredByIcu'>Powered by
<a href="http://www.icu-project.org/">ICU</a> <%= com.ibm.icu.util.VersionInfo.ICU_VERSION.toString() %></p>

</body>
</html>
