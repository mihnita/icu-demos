<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="com.ibm.icu.util.ULocale" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.WebUtil" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.servlet.PatinaServlet.Segment" %>
<%@ include file="header.jspf" %>

<%
    String skel = (String) request.getAttribute("skel");
    Date ta = (Date) request.getAttribute("ta");
    String formattedResult = (String) request.getAttribute("formattedResult");
    List<Segment> segments = (List<Segment>) request.getAttribute("segments");
    ULocale localeAttr = (ULocale) request.getAttribute("locale");
%>

<div class="card">
    <h3>Date Pattern Attributes (Patina)</h3>
    <form method="POST">
        <div class="form-group">
            <label for="skel">Pattern Pattern (e.g., yyyy-MM-dd HH:mm:ss, or leave empty for default):</label>
            <input class="input-control" type="text" id="skel" name="skel" value="<%= WebUtil.escapeHtml(skel) %>" />
        </div>
        
        <div class="flex-row">
            <div class="form-group flex-col">
                <label for="ta">Date A:</label>
                <input class="input-control" type="text" id="ta" name="ta" value="<%= WebUtil.escapeHtml(ta.toString()) %>" />
            </div>
            
            <div class="form-group flex-col">
                <label for="_">Target Language Locale:</label>
                <input class="input-control" type="text" id="_" name="_" value="<%= WebUtil.escapeHtml(localeAttr.toLanguageTag()) %>" />
                <span style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.25rem; display: block;">
                    Resolved locale: <strong><%= localeAttr.getDisplayName(localeAttr) %></strong>
                </span>
            </div>
        </div>
        
        <button type="submit" class="btn btn-primary">Parse & Format</button>
    </form>
</div>

<div class="card result-card">
    <h3>Formatted Date Representation</h3>
    <pre class="code-output"><%= formattedResult %></pre>
</div>

<div class="card">
    <h3>Formatted Pattern Segments (Field Highlights)</h3>
    <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.5rem;">
        Below is the list of parsed elements making up the date output string, highlighting the internal Calendar calendar-field labels for each character run.
    </p>
    
    <div style="display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: center; padding: 1.25rem; border-radius: 0.5rem; background-color: rgba(0,0,0,0.2); border: 1px solid var(--border-color);">
        <%
            for (Segment seg : segments) {
                if (seg.hasFields()) {
                    for (String fieldName : seg.fields) {
        %>
                        <div style="display: inline-flex; align-items: center; border: 1px solid rgba(16,185,129,0.3); border-radius: 0.4rem; padding: 0.4rem 0.75rem; background-color: rgba(16,185,129,0.1);">
                            <span class="field" style="margin-right: 0;"><%= WebUtil.escapeHtml(fieldName) %></span>
                            <strong style="margin-left: 0.5rem; font-family: var(--font-mono); font-size: 1.1rem; color: var(--text-main);"><%= WebUtil.escapeHtml(seg.text) %></strong>
                        </div>
        <%
                    }
                } else {
        %>
                    <span style="font-family: var(--font-mono); font-size: 1.1rem; color: var(--text-muted); padding: 0.2rem 0.4rem;"><%= WebUtil.escapeHtml(seg.text) %></span>
        <%
                }
            }
        %>
    </div>
</div>

<%@ include file="footer.jspf" %>
