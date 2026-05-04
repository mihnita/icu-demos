<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="com.ibm.icu.util.ULocale" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.WebUtil" %>
<%@ include file="header.jspf" %>

<%
    Double n = (Double) request.getAttribute("n");
    String spelledOutResult = (String) request.getAttribute("spelledOutResult");
    ULocale localeAttr = (ULocale) request.getAttribute("locale");
%>

<div class="card">
    <h3>Spellout Numeric Values (Numero)</h3>
    <form method="POST">
        <div class="flex-row">
            <div class="form-group flex-col">
                <label for="n">Number to spell out (floating-point double):</label>
                <input class="input-control" style="font-size: 1.1rem; font-weight: 600;" type="text" id="n" name="n" value="<%= n %>" />
            </div>
            
            <div class="form-group flex-col">
                <label for="_">Target Language Locale:</label>
                <input class="input-control" type="text" id="_" name="_" value="<%= WebUtil.escapeHtml(localeAttr.toLanguageTag()) %>" />
                <span style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.25rem; display: block;">
                    Resolved locale: <strong><%= localeAttr.getDisplayName(localeAttr) %></strong>
                </span>
            </div>
        </div>
        
        <button type="submit" class="btn btn-primary">Spellout Number</button>
    </form>
</div>

<div class="card result-card">
    <h3>RuleBasedNumberFormat Spelled-out Output</h3>
    <p style="font-size: 1.3rem; font-weight: 500; line-height: 1.6; color: var(--text-main); font-family: var(--font-sans);">
        <%= WebUtil.escapeHtml(spelledOutResult) %>
    </p>
</div>

<%@ include file="footer.jspf" %>
