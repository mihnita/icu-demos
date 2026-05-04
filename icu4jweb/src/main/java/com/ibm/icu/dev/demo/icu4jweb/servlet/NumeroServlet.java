// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import java.util.Random;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.WebUtil;
import com.ibm.icu.text.RuleBasedNumberFormat;
import com.ibm.icu.util.ULocale;

@WebServlet(name = "NumeroServlet", urlPatterns = {"/numero"})
public class NumeroServlet extends BaseServlet {
    private static final long serialVersionUID = 1L;
    private static final Random random = new Random();

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
        ULocale locale = (ULocale) request.getAttribute("locale");
        
        double n = ((random.nextInt()) % 1000000) / 100.0;
        String nStr = request.getParameter("n");
        if (nStr != null && !nStr.trim().isEmpty()) {
            try {
                n = Double.parseDouble(nStr);
            } catch (Exception e) {
                // Keep random double on parse error
            }
        }
        
        String spelledOutResult = "";
        try {
            RuleBasedNumberFormat rbnf = new RuleBasedNumberFormat(locale, RuleBasedNumberFormat.SPELLOUT);
            spelledOutResult = rbnf.format(n);
        } catch (Exception e) {
            spelledOutResult = "Error: " + e.getMessage();
        }
        
        request.setAttribute("n", n);
        request.setAttribute("spelledOutResult", spelledOutResult);
        
        forward(request, response, "numero.jsp");
    }
}
