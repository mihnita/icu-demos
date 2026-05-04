<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ include file="header.jspf" %>

<div class="card">
    <h3>Welcome to ICU4J Web Demos</h3>
    <p style="margin-bottom: 1rem; line-height: 1.6; color: var(--text-muted);">
        This web application showcases the power, flexibility, and elegance of the <strong>International Components for Unicode</strong> library for Java (ICU4J).
    </p>
    <p style="margin-bottom: 1.5rem; line-height: 1.6; color: var(--text-muted);">
        Please select a demo from the sidebar on the left to interact with global locale databases, date-time pattern generators, spellout rule-based formats, and complex text layout parsers.
    </p>
    
    <div style="padding: 1.25rem; border-radius: 0.5rem; background-color: rgba(255,255,255,0.03); border: 1px solid var(--border-color);">
        <strong style="color: var(--accent); display: block; margin-bottom: 0.5rem;">System Information</strong>
        <ul style="list-style: none; display: flex; flex-direction: column; gap: 0.4rem; font-family: var(--font-mono); font-size: 0.85rem;">
            <li>ICU4J version: <%= com.ibm.icu.util.VersionInfo.ICU_VERSION %></li>
            <li>JVM runtime: <%= System.getProperty("java.vendor") %> Java <%= System.getProperty("java.version") %></li>
            <li>OS platform: <%= System.getProperty("os.name") %> (<%= System.getProperty("os.arch") %>)</li>
        </ul>
    </div>
</div>

<%@ include file="footer.jspf" %>
