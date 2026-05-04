<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.ibm.icu.util.ULocale" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.WebUtil" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.servlet.FlexTestServlet.AppendItem" %>
<%@ include file="header.jspf" %>

<%
    String pat = (String) request.getAttribute("pat");
    String bestPattern = (String) request.getAttribute("bestPattern");
    String formattedExample = (String) request.getAttribute("formattedExample");
    String errorMsg = (String) request.getAttribute("errorMsg");
    List<AppendItem> appendItems = (List<AppendItem>) request.getAttribute("appendItems");
    Set<String> availableSkeletons = (Set<String>) request.getAttribute("availableSkeletons");
    ULocale localeAttr = (ULocale) request.getAttribute("locale");
%>

<div class="card">
    <h3>DateTimePatternGenerator parameters</h3>
    <form method="POST">
        <div class="form-group">
            <label for="pat">Skeleton Format Pattern Input:</label>
            <input class="input-control" style="font-family: var(--font-mono);" type="text" id="pat" name="pat" value="<%= WebUtil.escapeHtml(pat) %>" />
        </div>
        
        <div class="form-group">
            <label for="_">Target Language Locale:</label>
            <input class="input-control" type="text" id="_" name="_" value="<%= WebUtil.escapeHtml(localeAttr.toLanguageTag()) %>" />
            <span style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.25rem; display: block;">
                Active locale: <strong><%= localeAttr.getDisplayName(localeAttr) %></strong>
            </span>
        </div>
        
        <div class="btn-group">
            <button type="submit" class="btn btn-primary">Generate Best Pattern</button>
            <a href="?pat=&_=" class="btn btn-secondary">Clear Input</a>
        </div>
    </form>
</div>

<% if (errorMsg != null) { %>
    <div class="card" style="border-color: var(--danger);">
        <h3 style="color: var(--danger);">Generation Error</h3>
        <p style="color: var(--danger);"><%= WebUtil.escapeHtml(errorMsg) %></p>
    </div>
<% } %>

<% if (!bestPattern.isEmpty()) { %>
    <div class="card result-card">
        <h3>Calculated Best Match</h3>
        <div style="display: flex; flex-direction: column; gap: 0.75rem;">
            <div>
                <span style="color: var(--text-muted); font-size: 0.9rem; display: block; margin-bottom: 0.25rem;">Best Pattern:</span>
                <code style="font-family: var(--font-mono); font-size: 1.15rem; color: #38bdf8; background-color: rgba(0,0,0,0.2); padding: 0.3rem 0.6rem; border-radius: 0.3rem; border: 1px solid var(--border-color);"><%= WebUtil.escapeHtml(bestPattern) %></code>
            </div>
            <div>
                <span style="color: var(--text-muted); font-size: 0.9rem; display: block; margin-bottom: 0.25rem;">Example Format Output:</span>
                <span style="font-size: 1.2rem; font-weight: 500; color: var(--accent);"><%= WebUtil.escapeHtml(formattedExample) %></span>
            </div>
        </div>
    </div>
<% } %>

<div class="card">
    <h3>Build Skeletons interactively</h3>
    <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.25rem;">
        Click any date-time parameter below to add its canonical field representation to your current pattern skeleton:
    </p>
    
    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 1rem;">
        <%
            for (AppendItem item : appendItems) {
        %>
                <a href="?pat=<%= java.net.URLEncoder.encode(item.modifiedPattern, "UTF-8") %>&_=" class="skeleton-tag" style="display: flex; flex-direction: column; gap: 0.25rem; align-items: flex-start; padding: 0.75rem 1rem;">
                    <span style="font-family: var(--font-mono); font-size: 1rem; font-weight: bold; color: var(--text-main);"><%= WebUtil.escapeHtml(item.canonicalToken) %></span>
                    <span style="font-size: 0.8rem; color: var(--text-muted);"><%= WebUtil.escapeHtml(item.name) %> (<%= WebUtil.escapeHtml(item.formattedPreview) %>)</span>
                </a>
        <% } %>
    </div>
</div>

<div class="card">
    <h3>Available Locale Skeletons</h3>
    <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.25rem;">
        Choose one of the base pattern skeletons defined for this locale database to load it as input:
    </p>
    <div class="btn-group">
        <%
            for (String base : availableSkeletons) {
        %>
                <a href="?pat=<%= java.net.URLEncoder.encode(base, "UTF-8") %>&_=" class="skeleton-tag"><%= WebUtil.escapeHtml(base) %></a>
        <% } %>
    </div>
</div>

<%@ include file="footer.jspf" %>
