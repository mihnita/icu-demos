// Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb.servlet;

import java.io.IOException;
import java.text.ParsePosition;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.icu.dev.demo.icu4jweb.WebUtil;
import com.ibm.icu.text.DateFormat;
import com.ibm.icu.text.DateTimePatternGenerator;
import com.ibm.icu.text.ListFormatter;
import com.ibm.icu.text.SimpleDateFormat;
import com.ibm.icu.util.Calendar;
import com.ibm.icu.util.ULocale;

@WebServlet(name = "TuthuServlet", urlPatterns = {"/tuthu"})
public class TuthuServlet extends BaseServlet {
    private static final long serialVersionUID = 1L;

    public static class MonthReport {
        public final String monthName;
        public final List<String> formattedDates;

        public MonthReport(String monthName, List<String> formattedDates) {
            this.monthName = monthName;
            this.formattedDates = formattedDates;
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
        
        int[] dayList = { Calendar.TUESDAY, Calendar.THURSDAY };
        String[] dayNames = new String[dayList.length];
        
        DateTimePatternGenerator gen = DateTimePatternGenerator.getInstance(locale);
        
        DateFormat yearFormat = new SimpleDateFormat(gen.getBestPattern("y"), locale);
        DateFormat monthFormat = new SimpleDateFormat(gen.getBestPattern("MMMM"), locale);
        DateFormat longDayFormat = new SimpleDateFormat(gen.getBestPattern("EEEE"), locale);
        DateFormat longDayDateFormat = new SimpleDateFormat(gen.getBestPattern("dEEEE"), locale);
        String yearName = gen.getAppendItemName(DateTimePatternGenerator.YEAR);
        
        Calendar c = Calendar.getInstance(locale);
        c.setMinimalDaysInFirstWeek(1);
        
        // Calculate names of Tuesday & Thursday
        for (int i = 0; i < dayList.length; i++) {
            c.set(Calendar.DAY_OF_WEEK, dayList[i]);
            dayNames[i] = longDayFormat.format(c.getTime());
        }
        
        // Format list of names
        ListFormatter lf = ListFormatter.getInstance(locale);
        String namesList = lf.format((Object[]) dayNames);
        
        String yearStr = request.getParameter("year");
        int yearNum = -1;
        if (yearStr != null && !yearStr.trim().isEmpty()) {
            ParsePosition pp = new ParsePosition(0);
            yearFormat.parse(yearStr, c, pp);
            if (pp.getErrorIndex() == -1) {
                yearNum = c.get(Calendar.YEAR);
            } else {
                yearNum = Calendar.getInstance().get(Calendar.YEAR);
            }
        } else {
            yearNum = c.get(Calendar.YEAR);
        }
        
        List<MonthReport> reports = new ArrayList<>();
        int minmo = c.getActualMinimum(Calendar.MONTH);
        int maxmo = c.getActualMaximum(Calendar.MONTH);
        
        for (int m = minmo; m <= maxmo; m++) {
            c.clear();
            c.set(Calendar.YEAR, yearNum);
            c.set(Calendar.MONTH, m);
            String monthName = monthFormat.format(c.getTime());
            
            List<String> formattedDates = new ArrayList<>();
            int minw = c.getActualMinimum(Calendar.WEEK_OF_MONTH);
            int maxw = c.getActualMaximum(Calendar.WEEK_OF_MONTH);
            
            for (int w = minw; w <= maxw; w++) {
                for (int dayOfWeek : dayList) {
                    c.clear();
                    c.set(Calendar.YEAR, yearNum);
                    c.set(Calendar.MONTH, m);
                    c.set(Calendar.WEEK_OF_MONTH, w);
                    c.set(Calendar.DAY_OF_WEEK, dayOfWeek);
                    if (c.get(Calendar.MONTH) == m) {
                        formattedDates.add(longDayDateFormat.format(c.getTime()));
                    }
                }
            }
            reports.add(new MonthReport(monthName, formattedDates));
        }
        
        // Reset calendar to display search input value
        c.clear();
        c.set(Calendar.YEAR, yearNum);
        
        request.setAttribute("yearName", yearName);
        request.setAttribute("yearValue", yearFormat.format(c.getTime()));
        request.setAttribute("namesList", namesList);
        request.setAttribute("reports", reports);
        
        forward(request, response, "tuthu.jsp");
    }
}
