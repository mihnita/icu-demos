<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.ibm.icu.util.ULocale" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.WebUtil" %>
<%@ include file="header.jspf" %>

<%
    String skel = (String) request.getAttribute("skel");
    Date ta = (Date) request.getAttribute("ta");
    Date tb = (Date) request.getAttribute("tb");
    String formattedResult = (String) request.getAttribute("formattedResult");
    ULocale localeAttr = (ULocale) request.getAttribute("locale");
%>

<div class="card">
    <h3>Date Interval Parameters</h3>
    <form method="POST">
        <div class="form-group">
            <label for="skel">Pattern Skeleton (e.g., yMMMdd, yMMMM, d):</label>
            <input class="input-control" type="text" id="skel" name="skel" value="<%= WebUtil.escapeHtml(skel) %>" />
        </div>
        
        <div class="flex-row">
            <div class="form-group flex-col">
                <label for="ta">Date A (Start Date):</label>
                <input class="input-control" type="text" id="ta" name="ta" value="<%= WebUtil.escapeHtml(ta.toString()) %>" />
            </div>
            
            <div class="form-group flex-col">
                <label for="tb">Date B (End Date):</label>
                <input class="input-control" type="text" id="tb" name="tb" value="<%= WebUtil.escapeHtml(tb.toString()) %>" />
            </div>
        </div>
        
        <div class="form-group">
            <label for="_">Formatting Language Locale:</label>
            <input class="input-control" type="text" id="_" name="_" value="<%= WebUtil.escapeHtml(localeAttr.toLanguageTag()) %>" />
            <span style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.25rem; display: block;">
                Resolved locale display: <strong><%= localeAttr.getDisplayName(localeAttr) %></strong>
            </span>
        </div>
        
        <button type="submit" class="btn btn-primary">Calculate Interval</button>
    </form>
</div>

<div class="card result-card">
    <h3>Formatted Date Interval</h3>
    <pre class="code-output"><%= formattedResult %></pre>
</div>

<%@ include file="footer.jspf" %>
