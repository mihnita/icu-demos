<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.WebUtil" %>
<%@ include file="header.jspf" %>

<%
    String localeParam = (String) request.getAttribute("localeParam");
    String baseLocale = (String) request.getAttribute("baseLocale");
    String baseExtension = (String) request.getAttribute("baseExtension");
    List<String> candidateLocales = (List<String>) request.getAttribute("candidateLocales");
    List<String> jdkList = (List<String>) request.getAttribute("jdkList");
    Boolean isExtension = (Boolean) request.getAttribute("isExtension");
    String extensionValue = (String) request.getAttribute("extensionValue");
    String error = (String) request.getAttribute("error");
%>

<div class="card">
    <h3>Locale Fallback Candidate List</h3>
    <form method="POST">
        <div class="form-group">
            <label for="locale">Enter a Locale ID (e.g., zh_CN, zh_CN_Beijing, no_NO_NY, en_US__@x=new-user):</label>
            <input class="input-control" style="font-size: 1.1rem; font-weight: 600;" type="text" id="locale" name="locale" value="<%= localeParam != null ? WebUtil.escapeHtml(localeParam) : "" %>" />
        </div>
        <button type="submit" class="btn btn-primary">Compute Fallback Candidates</button>
    </form>
</div>

<% if (error != null) { %>
    <div class="card" style="border-color: var(--danger);">
        <h3 style="color: var(--danger);">Input Error</h3>
        <p style="color: var(--danger);"><%= WebUtil.escapeHtml(error) %></p>
    </div>
<% } %>

<% if (localeParam != null && error == null) { %>
    <div class="card result-card">
        <h3>Fallback Candidates Analysis</h3>
        
        <div style="display: flex; flex-direction: column; gap: 0.75rem; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid rgba(255,255,255,0.05);">
            <div>
                <span style="color: var(--text-muted); font-size: 0.9rem;">Resolved Base Locale:</span>
                <code style="font-family: var(--font-mono); font-size: 1.1rem; color: var(--text-main);"><%= WebUtil.escapeHtml(baseLocale) %></code>
            </div>
            <% if (baseExtension != null) { %>
                <div>
                    <span style="color: var(--text-muted); font-size: 0.9rem;">Base Extension:</span>
                    <code style="font-family: var(--font-mono); font-size: 1.1rem; color: var(--accent);"><%= WebUtil.escapeHtml(baseExtension) %></code>
                </div>
            <% } %>
        </div>
        
        <h4 style="margin-bottom: 1rem; color: var(--text-main);">Computed Candidate Fallback Locales</h4>
        <p style="color: var(--text-muted); font-size: 0.85rem; margin-bottom: 1rem;">
            Candidates listed in <span style="color: #00FFFF; font-weight: bold;">cyan</span> are custom extensions supported by ICU4J but not present in standard JDK fallback lists.
        </p>
        
        <div style="display: flex; flex-direction: column; gap: 0.5rem; padding: 1rem; border-radius: 0.5rem; background-color: rgba(0,0,0,0.2); border: 1px solid var(--border-color);">
            <%
                if (isExtension != null && isExtension) {
                    // Custom rendering for extension case
                    for (int i = 0; i < candidateLocales.size() - 2; i++) {
                        String candidate = candidateLocales.get(i);
                        boolean inJdk = jdkList.contains(candidate);
            %>
                        <div style="font-family: var(--font-mono); font-size: 1rem; color: <%= inJdk ? "var(--text-main)" : "#00FFFF" %>;">
                            &bull; <%= WebUtil.escapeHtml(candidate) %> <%= inJdk ? "" : "(ICU4J Specific Extension)" %>
                        </div>
            <%
                    }
            %>
                    <div style="font-family: var(--font-mono); font-size: 1rem; color: #00FFFF; margin-top: 0.5rem; border-top: 1px dashed var(--border-color); padding-top: 0.5rem;">
                        Extension Key: <strong>@<%= WebUtil.escapeHtml(candidateLocales.get(candidateLocales.size() - 1)) %></strong>
                    </div>
            <%
                } else {
                    // Normal case
                    for (String candidate : candidateLocales) {
                        boolean inJdk = jdkList.contains(candidate);
            %>
                        <div style="font-family: var(--font-mono); font-size: 1rem; color: <%= inJdk ? "var(--text-main)" : "#00FFFF" %>;">
                            &bull; <%= WebUtil.escapeHtml(candidate) %> <%= inJdk ? "" : "(ICU4J Specific Extension)" %>
                        </div>
            <%
                    }
            %>
                    <div style="font-family: var(--font-mono); font-size: 1rem; color: var(--text-muted); margin-top: 0.5rem; border-top: 1px dashed var(--border-color); padding-top: 0.5rem;">
                        No fallback extensions found.
                    </div>
            <%
                }
            %>
        </div>
    </div>
<% } %>

<%@ include file="footer.jspf" %>
