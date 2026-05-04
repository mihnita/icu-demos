<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.ibm.icu.util.ULocale" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.WebUtil" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.servlet.TuthuServlet.MonthReport" %>
<%@ include file="header.jspf" %>

<%
    String yearName = (String) request.getAttribute("yearName");
    String yearValue = (String) request.getAttribute("yearValue");
    String namesList = (String) request.getAttribute("namesList");
    List<MonthReport> reports = (List<MonthReport>) request.getAttribute("reports");
    ULocale localeAttr = (ULocale) request.getAttribute("locale");
%>

<div class="card">
    <h3>weekday recurrence calculation parameters</h3>
    <form method="POST">
        <div class="flex-row">
            <div class="form-group flex-col">
                <label for="year"><%= WebUtil.escapeHtml(yearName) %>:</label>
                <input class="input-control" type="text" id="year" name="year" value="<%= WebUtil.escapeHtml(yearValue) %>" />
            </div>
            
            <div class="form-group flex-col">
                <label for="_">Target Language Locale:</label>
                <input class="input-control" type="text" id="_" name="_" value="<%= WebUtil.escapeHtml(localeAttr.toLanguageTag()) %>" />
                <span style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.25rem; display: block;">
                    Resolved locale: <strong><%= localeAttr.getDisplayName(localeAttr) %></strong>
                </span>
            </div>
        </div>
        
        <button type="submit" class="btn btn-primary">Generate Weekdays list</button>
    </form>
</div>

<div class="card result-card">
    <h3>Calculated calendar matching <%= WebUtil.escapeHtml(namesList) %> for the year <%= WebUtil.escapeHtml(yearValue) %></h3>
    
    <div class="report-grid">
        <%
            for (MonthReport report : reports) {
        %>
                <div class="month-box">
                    <h4><%= WebUtil.escapeHtml(report.monthName) %></h4>
                    <div style="display: flex; flex-direction: column; gap: 0.3rem;">
                        <%
                            if (report.formattedDates.isEmpty()) {
                        %>
                                <span style="color: var(--text-muted); font-style: italic;">No matching days</span>
                        <%
                            } else {
                                for (String formattedDate : report.formattedDates) {
                        %>
                                    <div class="date-item"><%= WebUtil.escapeHtml(formattedDate) %></div>
                        <%
                                }
                            }
                        %>
                    </div>
                </div>
        <% } %>
    </div>
</div>

<%@ include file="footer.jspf" %>
