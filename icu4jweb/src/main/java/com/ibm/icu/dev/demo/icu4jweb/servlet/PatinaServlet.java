// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import java.text.AttributedCharacterIterator;
import java.text.AttributedCharacterIterator.Attribute;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.WebUtil;
import com.ibm.icu.text.DateFormat;
import com.ibm.icu.text.SimpleDateFormat;
import com.ibm.icu.util.Calendar;
import com.ibm.icu.util.ULocale;

@WebServlet(name = "PatinaServlet", urlPatterns = {"/patina"})
public class PatinaServlet extends BaseServlet {
    private static final long serialVersionUID = 1L;

    public static class Segment {
        public final String text;
        public final List<String> fields;

        public Segment(String text, List<String> fields) {
            this.text = text;
            this.fields = fields;
        }
        
        public boolean hasFields() {
            return fields != null && !fields.isEmpty();
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

    @SuppressWarnings("deprecation")
    private void processRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        ULocale locale = (ULocale) request.getAttribute("locale");
        
        String skel = WebUtil.getParameter(request, "skel", "");
        
        Date ta = new Date();
        String taStr = request.getParameter("ta");
        if (taStr != null && !taStr.trim().isEmpty()) {
            try {
                ta = new Date(taStr);
            } catch (Exception e) {
                // Fallback to current date on parse error
            }
        }
        
        String formattedResult = "";
        List<Segment> segments = new ArrayList<>();
        try {
            SimpleDateFormat dtf = (SimpleDateFormat) DateFormat.getInstance(Calendar.getInstance(locale), locale);
            if (!skel.isEmpty()) {
                dtf.applyPattern(skel);
            } else {
                skel = dtf.toPattern();
            }
            
            formattedResult = dtf.format(ta);
            
            AttributedCharacterIterator aci = dtf.formatToCharacterIterator(ta);
            int limit;
            for (int i = aci.getBeginIndex(); i < aci.getEndIndex(); i = limit) {
                aci.setIndex(i);
                limit = aci.getRunLimit();
                Map<Attribute, Object> attributes = aci.getAttributes();
                List<String> fieldNames = new ArrayList<>();
                for (Attribute attr : attributes.keySet()) {
                    if (attr instanceof DateFormat.Field) {
                        fieldNames.add(attr.toString());
                    }
                }
                
                StringBuilder sb = new StringBuilder();
                for (int j = i; j < limit; j++) {
                    sb.append(aci.setIndex(j));
                }
                segments.add(new Segment(sb.toString(), fieldNames));
            }
        } catch (Exception e) {
            formattedResult = "Error: " + e.getMessage();
        }
        
        request.setAttribute("skel", skel);
        request.setAttribute("ta", ta);
        request.setAttribute("formattedResult", formattedResult);
        request.setAttribute("segments", segments);
        
        forward(request, response, "patina.jsp");
    }
}
