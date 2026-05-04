// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.WebUtil;
import com.ibm.icu.text.Bidi;

@WebServlet(name = "BidiServlet", urlPatterns = {"/bidi"})
public class BidiServlet extends BaseServlet {
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
        String text = WebUtil.getParameter(request, "text", "");
        
        Bidi bidi = null;
        if (!text.isEmpty()) {
            try {
                bidi = new Bidi(text, Bidi.OPTION_DEFAULT);
            } catch (Exception e) {
                request.setAttribute("error", e.getMessage());
            }
        }
        
        request.setAttribute("text", text);
        request.setAttribute("bidi", bidi);
        
        forward(request, response, "bidi.jsp");
    }
}
