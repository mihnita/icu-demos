// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb;

import javax.servlet.http.HttpServletRequest;
import com.ibm.icu.util.ULocale;

public final class WebUtil {

    private WebUtil() {
        // Private constructor to prevent instantiation
    }

    /**
     * Escape HTML characters to prevent XSS.
     */
    public static String escapeHtml(String arg) {
        if (arg == null) {
            return "";
        }
        return arg.replace("&", "&amp;")
                  .replace("\"", "&quot;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;");
    }

    /**
     * Resolve ULocale from the request.
     * Checks the parameter "_" (locale chooser parameter).
     * Falls back to request.getLocale(), then to ULocale.getDefault().
     */
    public static ULocale resolveLocale(HttpServletRequest request) {
        String locString = request.getParameter("_");
        if (locString == null || locString.trim().isEmpty()) {
            locString = request.getParameter("locale"); // check alternative parameter name
        }
        
        ULocale locale = null;
        if (locString != null && !locString.trim().isEmpty()) {
            try {
                locale = ULocale.forLanguageTag(locString);
                if (locale.toString().length() == 0) {
                    locale = new ULocale(locString);
                }
            } catch (Exception e) {
                // Fallback on exception
            }
        }
        
        if (locale == null) {
            if (request.getLocale() != null) {
                locale = ULocale.forLocale(request.getLocale());
            } else {
                locale = ULocale.getDefault();
            }
        }
        return locale;
    }

    /**
     * Fetch request parameter safely with default value.
     */
    public static String getParameter(HttpServletRequest request, String param, String defaultValue) {
        String val = request.getParameter(param);
        if (val == null) {
            return defaultValue;
        }
        return val.trim();
    }
}
