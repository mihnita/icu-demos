// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.TestLocaleHelper;
import com.ibm.icu.dev.demo.icu4jweb.WebUtil;

@WebServlet(name = "TestLocaleServlet", urlPatterns = {"/testLocale"})
public class TestLocaleServlet extends BaseServlet {
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
        String localeParam = request.getParameter("locale");
        
        if (localeParam != null) {
            localeParam = localeParam.trim();
            if (localeParam.isEmpty()) {
                request.setAttribute("error", "Please enter locale.");
            } else {
                String baseLocale = localeParam;
                String baseExtension = null;
                if (localeParam.contains("@")) {
                    baseLocale = localeParam.substring(0, localeParam.indexOf("@") - 1);
                    baseExtension = localeParam.substring(localeParam.indexOf("@"));
                }
                
                TestLocaleHelper.Result candidateResult = TestLocaleHelper.getCandidateList(localeParam);
                String[] jdkLocales = TestLocaleHelper.getJDKLocales(localeParam);
                
                List<String> jdkList = Arrays.asList(jdkLocales);
                List<String> candidateLocales = new ArrayList<>(Arrays.asList(candidateResult.candidates));
                
                boolean isExtension = false;
                for (String s : candidateLocales) {
                    if ("@".equals(s)) {
                        isExtension = true;
                        break;
                    }
                }
                
                request.setAttribute("localeParam", localeParam);
                request.setAttribute("baseLocale", baseLocale);
                request.setAttribute("baseExtension", baseExtension);
                request.setAttribute("candidateLocales", candidateLocales);
                request.setAttribute("jdkList", jdkList);
                request.setAttribute("isExtension", isExtension);
                request.setAttribute("extensionValue", candidateResult.extension);
            }
        }
        
        forward(request, response, "testLocale.jsp");
    }
}
