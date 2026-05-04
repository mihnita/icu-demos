// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import java.text.ParsePosition;
import java.util.Formatter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.WebUtil;
import com.ibm.icu.text.DecimalFormat;
import com.ibm.icu.text.SimpleDateFormat;
import com.ibm.icu.util.ULocale;

@WebServlet(name = "FormatTestServlet", urlPatterns = {"/formatTest"})
public class FormatTestServlet extends BaseServlet {
    private static final long serialVersionUID = 1L;

    private static final String STR = "str";
    private static final String NUM = "num";
    private static final String DATE = "date";
    private static final String CHAR = "char";
    private static final String NUM_FMT = "0.#";
    private static final DecimalFormat decFmt = new DecimalFormat(NUM_FMT);
    private static final String DATE_FMT = "yyyy-MM-dd HH:mm:ss";
    private static final SimpleDateFormat dateFmt = new SimpleDateFormat(DATE_FMT);

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
        
        String selectedLocale = request.getParameter("locale");
        if (selectedLocale == null || selectedLocale.trim().isEmpty()) {
            selectedLocale = (request.getLocale() != null) ? request.getLocale().toString() : "en_US";
        }
        
        String msgType = WebUtil.getParameter(request, "msgType", "icu4j");
        String msgFmtStr = WebUtil.getParameter(request, "msg", "Hello {0}!");
        
        String[] args = request.getParameterValues("arg");
        if (args == null) {
            args = new String[]{"world", "", ""};
        }
        
        String[] argTypes = request.getParameterValues("argType");
        if (argTypes == null) {
            argTypes = new String[]{"str", "str", "str"};
        }
        
        Object[] argObjs = convertToObjects(argTypes, args);
        
        String formattedResult = "";
        try {
            ULocale currULoc = new ULocale(selectedLocale);
            if ("icu4j".equals(msgType)) {
                formattedResult = new com.ibm.icu.text.MessageFormat(msgFmtStr, currULoc).format(argObjs);
            } else if ("printf".equals(msgType)) {
                formattedResult = new Formatter(currULoc.toLocale()).format(currULoc.toLocale(), msgFmtStr, argObjs).toString();
            } else {
                formattedResult = new java.text.MessageFormat(msgFmtStr, currULoc.toLocale()).format(argObjs);
            }
        } catch (Exception e) {
            formattedResult = "<span class='null'>" + WebUtil.escapeHtml(e.getMessage()) + "</span>";
        }
        
        request.setAttribute("selectedLocale", selectedLocale);
        request.setAttribute("msgType", msgType);
        request.setAttribute("msg", msgFmtStr);
        request.setAttribute("args", args);
        request.setAttribute("argTypes", argTypes);
        request.setAttribute("formattedResult", formattedResult);
        
        forward(request, response, "formatTest.jsp");
    }

    private static Object convertToObject(String argType, String arg) {
        try {
            if (STR.equals(argType)) {
                return arg;
            } else if (NUM.equals(argType)) {
                Object result = decFmt.parse(arg, new ParsePosition(0));
                return result != null ? result : "<span class='null'>null</span>";
            } else if (DATE.equals(argType)) {
                Object result = dateFmt.parse(arg, new ParsePosition(0));
                return result != null ? result : "<span class='null'>null</span>";
            } else if (CHAR.equals(argType)) {
                return arg.isEmpty() ? ' ' : arg.charAt(0);
            } else {
                return "Invalid Type " + argType;
            }
        } catch (Exception e) {
            return "[Can not parse \"" + arg + "\"]";
        }
    }

    private static Object[] convertToObjects(String[] argTypes, String[] args) {
        int length = Math.min(args.length, argTypes.length);
        Object[] objs = new Object[length];
        for (int i = 0; i < length; i++) {
            objs[i] = convertToObject(argTypes[i], args[i]);
        }
        return objs;
    }
}
