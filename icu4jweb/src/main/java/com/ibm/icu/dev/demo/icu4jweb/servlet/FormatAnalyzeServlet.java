// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.WebUtil;
import com.ibm.icu.text.MessagePattern;
import com.ibm.icu.text.MessagePatternUtil;
import com.ibm.icu.text.MessagePatternUtil.*;

@WebServlet(name = "FormatAnalyzeServlet", urlPatterns = {"/formatAnalyze"})
public class FormatAnalyzeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("text/html;charset=utf-8");
        request.setCharacterEncoding("UTF-8");
        
        String msg = request.getParameter("msg");
        if (msg == null) {
            msg = "";
        }
        
        PrintWriter out = response.getWriter();
        out.println("<div id='msgAnalysis' class='msgAnalysis'>");
        try {
            if (!msg.isEmpty()) {
                MessageNode rootNode = MessagePatternUtil.buildMessageNode(msg);
                showNode(out, rootNode);
            }
        } catch (Exception e) {
            out.print("<span class='null'>" + WebUtil.escapeHtml(e.getMessage()) + "</span>");
        }
        out.println("</div>");
    }

    private void showNode(PrintWriter out, TextNode node) {
        out.print("<span class='msgLiteral'>" + WebUtil.escapeHtml(node.getText()) + "</span>");
    }

    private void showNode(PrintWriter out, VariantNode node) {
        out.print("<tr><th>");
        out.print(WebUtil.escapeHtml(node.getSelector()));
        if (node.isSelectorNumeric()) {
            out.print("&nbsp;&nbsp;" + node.getSelectorValue());
        }
        out.print("</th><td>");
        showNode(out, node.getMessage());
        out.print("</td></tr>");
    }

    private void showNode(PrintWriter out, List<VariantNode> nodeList) {
        for (VariantNode node : nodeList) {
            showNode(out, node);
        }
    }

    private void showNode(PrintWriter out, ComplexArgStyleNode node) {
        MessagePattern.ArgType type = node.getArgType();
        out.print("<table class='msgSubPart'>");
        out.print("<thead>");
        out.print("<tr><th>" + type.toString().toLowerCase() + "</th><td>");
        if (node.hasExplicitOffset()) {
            out.print("offset:" + node.getOffset());
        }
        out.print("</td></tr>");
        out.print("</thead><tbody>");

        List<VariantNode> numericVariants = new ArrayList<>();
        List<VariantNode> keywordVariants = new ArrayList<>();
        VariantNode otherNode = node.getVariantsByType(numericVariants, keywordVariants);

        showNode(out, numericVariants);
        showNode(out, keywordVariants);
        if (otherNode != null) {
            showNode(out, otherNode);
        }
        out.print("</tbody></table>");
    }

    private void showNode(PrintWriter out, ArgNode node) {
        MessagePattern.ArgType type = node.getArgType();
        switch (type) {
            case NONE:
            case SIMPLE:
                out.print("<span class='argNumber'>" + WebUtil.escapeHtml(node.toString()) + "</span>");
                break;
            case SELECT:
            case CHOICE:
            case PLURAL:
                showNode(out, node.getComplexStyle());
                break;
            default:
                out.print("<span class='null'>" + WebUtil.escapeHtml(node.toString()) + "</span> (type=" + node.getArgType() + ")");
        }
    }

    private void showNode(PrintWriter out, MessageContentsNode node) {
        switch (node.getType()) {
            case TEXT:
                showNode(out, (TextNode) node);
                break;
            case ARG:
                showNode(out, (ArgNode) node);
                break;
            case REPLACE_NUMBER:
                out.print("<span class='msgReplace'>#</span>");
                break;
            default:
                out.print("<div class='msgSubPart'>");
                out.print("type=" + node.getType());
                out.print("</div>");
                break;
        }
    }

    private void showNode(PrintWriter out, MessageNode node) {
        out.print("<div class='msgSubPart'>");
        List<MessageContentsNode> subNodes = node.getContents();
        for (MessageContentsNode subNode : subNodes) {
            showNode(out, subNode);
        }
        out.print("</div>");
    }
}
