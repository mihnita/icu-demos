<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="com.ibm.icu.text.Bidi" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.WebUtil" %>
<%@ include file="header.jspf" %>

<%
    String text = (String) request.getAttribute("text");
    Bidi bidi = (Bidi) request.getAttribute("bidi");
    String error = (String) request.getAttribute("error");
%>

<div class="card">
    <h3>BiDi Run Analysis</h3>
    <form method="POST">
        <div class="form-group">
            <label for="text">Enter text containing bi-directional script mixes:</label>
            <textarea class="textarea-control" id="text" name="text"><%= WebUtil.escapeHtml(text) %></textarea>
        </div>
        <button type="submit" class="btn btn-primary">Analyze Text Runs</button>
    </form>
</div>

<% if (error != null) { %>
    <div class="card" style="border-color: var(--danger);">
        <h3 style="color: var(--danger);">Analysis Error</h3>
        <p style="color: var(--danger);"><%= WebUtil.escapeHtml(error) %></p>
    </div>
<% } %>

<% if (bidi != null) { %>
    <div class="card result-card">
        <h3>Analysis Results: <%= bidi.countRuns() %> level runs detected</h3>
        <ol style="margin-left: 1.5rem; display: flex; flex-direction: column; gap: 1rem;">
            <%
                for (int i = 0; i < bidi.countRuns(); i++) {
                    int runStart = bidi.getRunStart(i);
                    int runLimit = bidi.getRunLimit(i);
                    String runText = text.substring(runStart, runLimit);
                    int level = bidi.getRunLevel(i);
            %>
                <li style="line-height: 1.6;">
                    <div style="margin-bottom: 0.25rem;">
                        <strong>Run Index:</strong> <%= i %> &bull; 
                        <strong>Run Level:</strong> <span class="argNumber"><%= level %></span>
                    </div>
                    <div style="padding: 0.75rem; background-color: rgba(0,0,0,0.15); border: 1px solid var(--border-color); border-radius: 0.4rem; display: inline-block; font-family: var(--font-mono);" dir="<%= (level % 2 == 0) ? "ltr" : "rtl" %>">
                        |<span style="border: 1px dashed var(--accent); padding: 0.1rem 0.3rem; margin: 0 0.2rem;"><%= WebUtil.escapeHtml(runText) %></span>|
                    </div>
                </li>
            <% } %>
        </ol>
    </div>
<% } %>

<%@ include file="footer.jspf" %>
