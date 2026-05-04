// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.StringJoiner;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.WebUtil;

@WebServlet(name = "EscaperServlet", urlPatterns = {"/escaper"})
public class EscaperServlet extends BaseServlet {
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
        String v = WebUtil.getParameter(request, "v", "");
        
        final int[] codePointCount = { 0 };
        StringJoiner utf32Dump = new StringJoiner(", ", "{ ", " }");
        v.codePoints().forEach(cp -> {
            codePointCount[0]++;
            utf32Dump.add("0x" + Integer.toHexString(cp));
        });
        utf32Dump.add("0");

        StringJoiner utf16Dump = new StringJoiner(", ", "{ ", " }");
        v.chars().forEach(ch16 -> utf16Dump.add("0x" + Integer.toHexString(ch16 & 0xffff)));
        utf16Dump.add("0");

        StringJoiner utf8Dump = new StringJoiner(", ", "{ ", " }");
        byte[] bytes = v.getBytes(StandardCharsets.UTF_8);
        for (byte b : bytes) {
            utf8Dump.add("0x" + Integer.toHexString(((int) b) & 0xff));
        }
        utf8Dump.add("0");
        
        request.setAttribute("v", v);
        request.setAttribute("codePointCount", codePointCount[0]);
        request.setAttribute("bytesLength", bytes.length);
        request.setAttribute("charsLength", v.length());
        request.setAttribute("utf8Dump", utf8Dump.toString());
        request.setAttribute("utf16Dump", utf16Dump.toString());
        request.setAttribute("utf32Dump", utf32Dump.toString());
        
        forward(request, response, "escaper.jsp");
    }
}
