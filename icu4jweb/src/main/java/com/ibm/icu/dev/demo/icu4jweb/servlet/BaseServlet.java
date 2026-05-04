// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.WebUtil;
import com.ibm.icu.util.ULocale;

public abstract class BaseServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=utf-8");
        
        // Resolve common properties like active locale
        ULocale locale = WebUtil.resolveLocale(req);
        req.setAttribute("locale", locale);
        
        // Call standard service logic
        super.service(req, resp);
    }

    /**
     * Forward request to a JSP file inside /WEB-INF/jsp/
     */
    protected void forward(HttpServletRequest request, HttpServletResponse response, String jspName) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/jsp/" + jspName).forward(request, response);
    }
}
