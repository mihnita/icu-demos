// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.WebUtil;
import com.ibm.icu.text.DateTimePatternGenerator;
import com.ibm.icu.text.SimpleDateFormat;
import com.ibm.icu.util.ULocale;

@WebServlet(name = "FlexTestServlet", urlPatterns = {"/flexTest"})
public class FlexTestServlet extends BaseServlet {
    private static final long serialVersionUID = 1L;

    private static final String[] CANONICAL_ITEMS = {
        "G", "y", "Q", "M", "w", "W", "e",
        "d", "D", "F", "a", "H", "m", "s", "S", "v"
    };

    public static class AppendItem {
        public final String canonicalToken;
        public final String name;
        public final String modifiedPattern;
        public final String formattedPreview;

        public AppendItem(String canonicalToken, String name, String modifiedPattern, String formattedPreview) {
            this.canonicalToken = canonicalToken;
            this.name = name;
            this.modifiedPattern = modifiedPattern;
            this.formattedPreview = formattedPreview;
        }
    }

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
        
        String thePattern = WebUtil.getParameter(request, "pat", "");
        
        DateTimePatternGenerator dtpg = DateTimePatternGenerator.getInstance(locale);
        
        String bestPattern = "";
        String formattedExample = "";
        String errorMsg = null;
        
        if (!thePattern.isEmpty()) {
            try {
                bestPattern = dtpg.getBestPattern(thePattern);
                formattedExample = new SimpleDateFormat(bestPattern, locale).format(new Date());
            } catch (IllegalArgumentException iae) {
                errorMsg = iae.getMessage();
            }
        }
        
        // Compute AppendItems list
        List<AppendItem> appendItems = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("y", locale);
        Date dnow = new Date();

        for (int i = 0; i < DateTimePatternGenerator.TYPE_LIMIT; i++) {
            String name = dtpg.getAppendItemName(i);
            String canonicalToken = CANONICAL_ITEMS[i];
            
            // Reconstruct pattern addition logic
            StringBuilder pat2Buf = new StringBuilder();
            char ch = canonicalToken.charAt(0);
            char toAppend = ch;
            char[] patBytes = thePattern.toCharArray();
            StringBuilder pat2Test = new StringBuilder(canonicalToken);
            
            for (char patByte : patBytes) {
                pat2Buf.append(patByte);
                if (patByte == ch) {
                    pat2Test.append(ch);
                    if (toAppend != 0) {
                        pat2Buf.append(toAppend);
                        toAppend = 0;
                    }
                }
            }
            if (toAppend != 0) {
                pat2Buf.append(toAppend);
            }
            
            String formattedPreview = "";
            try {
                sdf.applyPattern(pat2Test.toString());
                formattedPreview = sdf.format(dnow);
            } catch (Exception e) {
                formattedPreview = "N/A";
            }
            
            appendItems.add(new AppendItem(pat2Test.toString(), name, pat2Buf.toString(), formattedPreview));
        }
        
        // Fetch available skeletons
        Set<String> availableSkeletons = new TreeSet<>();
        dtpg.getBaseSkeletons(availableSkeletons);
        
        request.setAttribute("pat", thePattern);
        request.setAttribute("bestPattern", bestPattern);
        request.setAttribute("formattedExample", formattedExample);
        request.setAttribute("errorMsg", errorMsg);
        request.setAttribute("appendItems", appendItems);
        request.setAttribute("availableSkeletons", availableSkeletons);
        
        forward(request, response, "flexTest.jsp");
    }
}
