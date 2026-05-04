// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.WebUtil;
import com.ibm.icu.text.DateIntervalFormat;
import com.ibm.icu.util.DateInterval;
import com.ibm.icu.util.ULocale;

@WebServlet(name = "IntervalServlet", urlPatterns = {"/interval"})
public class IntervalServlet extends BaseServlet {
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

    @SuppressWarnings("deprecation")
    private void processRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        ULocale locale = (ULocale) request.getAttribute("locale");
        
        String skel = WebUtil.getParameter(request, "skel", "yMMMdd");
        
        Date ta = new Date();
        Date tb = new Date();
        
        String taStr = request.getParameter("ta");
        if (taStr != null && !taStr.trim().isEmpty()) {
            try {
                ta = new Date(taStr);
            } catch (Exception e) {
                // Fallback to current date on parse failure
            }
        }
        
        String tbStr = request.getParameter("tb");
        if (tbStr != null && !tbStr.trim().isEmpty()) {
            try {
                tb = new Date(tbStr);
            } catch (Exception e) {
                // Fallback to current date on parse failure
            }
        }
        
        String formattedResult = "";
        try {
            DateInterval interval = new DateInterval(ta.getTime(), tb.getTime());
            DateIntervalFormat format = DateIntervalFormat.getInstance(skel, locale);
            formattedResult = format.format(interval);
        } catch (Exception e) {
            formattedResult = "Error: " + e.getMessage();
        }
        
        request.setAttribute("skel", skel);
        request.setAttribute("ta", ta);
        request.setAttribute("tb", tb);
        request.setAttribute("formattedResult", formattedResult);
        
        forward(request, response, "interval.jsp");
    }
}
