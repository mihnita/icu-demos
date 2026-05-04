<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="com.ibm.icu.util.ULocale" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.WebUtil" %>
<%@ include file="header.jspf" %>

<%
    String selectedLocale = (String) request.getAttribute("selectedLocale");
    String msgType = (String) request.getAttribute("msgType");
    String msg = (String) request.getAttribute("msg");
    String[] args = (String[]) request.getAttribute("args");
    String[] argTypes = (String[]) request.getAttribute("argTypes");
    String formattedResult = (String) request.getAttribute("formattedResult");
%>

<script type="text/javascript">
    var argNum = <%= args.length %>;
    
    function addArgument() {
        var argumentsCell = document.getElementById('argumentsCell');
        var divNode = document.createElement('div');
        divNode.className = 'form-group flex-row';
        divNode.style.alignItems = 'center';
        
        var msgTypeVal = document.getElementById('msgType').value;
        var rowLabel = (msgTypeVal === 'printf') ? (argNum + 1) : argNum;
        
        divNode.innerHTML = `
            <label id="argLabel${argNum}" style="min-width: 30px; font-weight: bold;">${rowLabel}</label>
            <select class="select-control" style="flex: 1; min-width: 120px;" name="argType" onchange="addExample(this, 'argVal${argNum}');">
                <option value="str">String</option>
                <option value="num">Number (0.#)</option>
                <option value="date">Date (yyyy-MM-dd HH:mm:ss)</option>
                <option value="char">Character</option>
            </select>
            <input class="input-control" style="flex: 2;" id="argVal${argNum}" type="text" name="arg" value="">
        `;
        argumentsCell.appendChild(divNode);
        argNum++;
    }
    
    function addExample(selectionBox, idToModify) {
        var valInput = document.getElementById(idToModify);
        if (selectionBox.selectedIndex == 1) {
            valInput.value = '1234.56';
        } else if (selectionBox.selectedIndex == 2) {
            valInput.value = '2026-12-31 23:59:59';
        } else if (selectionBox.selectedIndex == 3) {
            valInput.value = 'A';
        } else {
            valInput.value = '';
        }
    }
    
    function setArgumentBase(selectNode) {
        var msgAnalysisSection = document.getElementById("msgAnalysisSection");
        if (selectNode.value === "icu4j") {
            msgAnalysisSection.style.display = '';
        } else {
            msgAnalysisSection.style.display = 'none';
        }
        
        var baseNum = (selectNode.value === "printf") ? 1 : 0;
        for (var i = 0; i < argNum; i++) {
            var label = document.getElementById('argLabel' + i);
            if (label) {
                label.innerText = i + baseNum;
            }
        }
    }
    
    function msgBlur() {
        var msgInput = document.getElementById("msg");
        var analysisDiv = document.getElementById("msgAnalysis");
        if (!analysisDiv) return;
        
        fetch('<%= request.getContextPath() %>/formatAnalyze?msg=' + encodeURIComponent(msgInput.value))
            .then(response => response.text())
            .then(html => {
                analysisDiv.innerHTML = html;
            })
            .catch(err => {
                analysisDiv.innerHTML = `<i class="null">${err}</i>`;
            });
    }
    
    window.addEventListener('DOMContentLoaded', function() {
        msgBlur();
    });
</script>

<div class="card">
    <h3>Format Tester Input</h3>
    <form method="POST">
        <div class="form-group">
            <label for="msg">Format Message Pattern:</label>
            <textarea class="textarea-control" id="msg" name="msg" onchange="msgBlur()"><%= WebUtil.escapeHtml(msg) %></textarea>
        </div>
        
        <div class="flex-row">
            <div class="form-group flex-col">
                <label for="msgType">Message Syntax Engine:</label>
                <select class="select-control" id="msgType" name="msgType" onchange="setArgumentBase(this);">
                    <option value="icu4j" <%= "icu4j".equals(msgType) ? "selected" : "" %>>ICU4J MessageFormat</option>
                    <option value="java" <%= "java".equals(msgType) ? "selected" : "" %>>Java MessageFormat</option>
                    <option value="printf" <%= "printf".equals(msgType) ? "selected" : "" %>>Java Formatter (printf)</option>
                </select>
            </div>
            
            <div class="form-group flex-col">
                <label for="locale">Target Formatting Locale:</label>
                <select class="select-control" id="locale" name="locale">
                    <%
                        ULocale[] locales = com.ibm.icu.text.NumberFormat.getAvailableULocales();
                        for (ULocale currLoc : locales) {
                            String tag = currLoc.toString();
                    %>
                        <option value="<%= tag %>" <%= selectedLocale.equals(tag) ? "selected" : "" %>><%= tag %> [<%= currLoc.getDisplayName() %>]</option>
                    <% } %>
                </select>
            </div>
        </div>
        
        <div class="form-group">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                <label style="margin-bottom: 0;">Arguments List</label>
                <button type="button" class="btn btn-secondary" style="padding: 0.4rem 1rem; font-size: 0.85rem;" onclick="addArgument()">+ Add Argument</button>
            </div>
            <div id="argumentsCell" style="display: flex; flex-direction: column; gap: 0.5rem;">
                <%
                    int baseNum = "printf".equals(msgType) ? 1 : 0;
                    for (int i = 0; i < args.length; i++) {
                %>
                    <div class="form-group flex-row" style="align-items: center; margin-bottom: 0;">
                        <label id="argLabel<%= i %>" style="min-width: 30px; font-weight: bold;"><%= i + baseNum %></label>
                        <select class="select-control" style="flex: 1; min-width: 120px;" id="argType<%= i %>" name="argType" onchange="addExample(this, 'argVal<%= i %>');">
                            <option value="str" <%= "str".equals(argTypes[i]) ? "selected" : "" %>>String</option>
                            <option value="num" <%= "num".equals(argTypes[i]) ? "selected" : "" %>>Number (0.#)</option>
                            <option value="date" <%= "date".equals(argTypes[i]) ? "selected" : "" %>>Date (yyyy-MM-dd HH:mm:ss)</option>
                            <option value="char" <%= "char".equals(argTypes[i]) ? "selected" : "" %>>Character</option>
                        </select>
                        <input class="input-control" style="flex: 2;" id="argVal<%= i %>" type="text" name="arg" value="<%= WebUtil.escapeHtml(args[i]) %>" />
                    </div>
                <% } %>
            </div>
        </div>
        
        <button type="submit" class="btn btn-primary" style="margin-top: 1rem;">Execute Format</button>
    </form>
</div>

<div class="card result-card">
    <h3>Formatted Result Output</h3>
    <pre class="code-output"><%= formattedResult %></pre>
</div>

<div class="card" id="msgAnalysisSection" style="<%= "icu4j".equals(msgType) ? "" : "display:none;" %>">
    <h3>Pattern Structure Analysis</h3>
    <div id="msgAnalysis">
        <!-- Loaded dynamically via AJAX msgBlur() -->
    </div>
</div>

<%@ include file="footer.jspf" %>
