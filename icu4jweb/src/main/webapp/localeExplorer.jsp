<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.ibm.icu.util.ULocale" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta content="Copyright (c) 2024 Unicode, Inc. and others. All Rights Reserved." name="COPYRIGHT" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>ICU Locale Explorer</title>
    <%@ include file="demohead.jsf" %>
    <style type="text/css">
        .section-header {
            background-color: #eee;
            padding: 5px;
            font-weight: bold;
            margin-top: 20px;
            border-bottom: 2px solid #ccc;
        }
        .prop-table {
            width: 100%;
            border-collapse: collapse;
        }
        .prop-table th {
            text-align: left;
            width: 200px;
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            padding: 8px;
        }
        .prop-table td {
            border: 1px solid #ddd;
            padding: 8px;
        }
        .example {
            font-family: monospace;
            background-color: #f0f0f0;
            padding: 2px 4px;
        }
        pre.rules {
            max-height: 200px;
            overflow: auto;
            background: #f8f8f8;
            padding: 5px;
            border: 1px solid #ddd;
            font-size: 11px;
            white-space: pre-wrap;
        }
    </style>
</head>
<body>
    <%@ include file="demolist.jsf" %>
    
    <div id="main">
        <h1>Locale Explorer</h1>
        
        <%@ include file="locale_chooser.jsf" %>
        
        <%
            // The variable 'locale' (ULocale) is already defined by locale_chooser.jsf
            if (locale == null) {
                locale = com.ibm.icu.util.ULocale.getDefault();
            }
        %>
        
        <p>Display Name: <%= locale.getDisplayName() %></p>
        <p>ICU Version: <%= com.ibm.icu.util.VersionInfo.ICU_VERSION %></p>

        <div class="section-header">Locale Basics</div>
        <table class="prop-table">
            <tr><th>Identifier</th><td><%= locale.toString() %></td></tr>
            <tr><th>Language Tag</th><td><%= locale.toLanguageTag() %></td></tr>
            <tr><th>Language</th><td><%= locale.getLanguage() %></td></tr>
            <tr>
                <th>Script</th>
                <td>
                    <%
                        int[] scriptCodes = com.ibm.icu.lang.UScript.getCode(locale);
                        if (scriptCodes != null && scriptCodes.length > 0) {
                            for (int i = 0; i < scriptCodes.length; i++) {
                                if (i > 0) out.print(", ");
                                out.print(com.ibm.icu.lang.UScript.getName(scriptCodes[i]));
                                out.print(" (" + com.ibm.icu.lang.UScript.getShortName(scriptCodes[i]) + ")");
                            }
                        } else {
                            out.print(locale.getScript());
                        }
                    %>
                </td>
            </tr>
            <tr><th>Country / Region</th><td><%= locale.getCountry() %></td></tr>
            <tr><th>Variant</th><td><%= locale.getVariant() %></td></tr>
            <tr>
                <th>ISO 3 Language</th>
                <td><% try { out.print(locale.getISO3Language()); } catch (Exception e) { out.print("N/A"); } %></td>
            </tr>
            <tr>
                <th>ISO 3 Country</th>
                <td><% try { out.print(locale.getISO3Country()); } catch (Exception e) { out.print("N/A"); } %></td>
            </tr>
            <tr>
                <th>Likely Subtags</th>
                <td><%= escapeString(ULocale.addLikelySubtags(locale).toLanguageTag()) %></td>
            </tr>
            <tr>
                <th>Character Orientation</th>
                <td><%= locale.getCharacterOrientation() %></td>
            </tr>
            <tr>
                <th>Line Orientation</th>
                <td><%= locale.getLineOrientation() %></td>
            </tr>
        </table>

        <div class="section-header">Localized Names</div>
        <table class="prop-table">
            <tr><th>Display Name (self)</th><td><%= locale.getDisplayName(locale) %></td></tr>
            <tr><th>Display Name (English)</th><td><%= locale.getDisplayName(com.ibm.icu.util.ULocale.ENGLISH) %></td></tr>
            <tr><th>Language (self)</th><td><%= locale.getDisplayLanguage(locale) %></td></tr>
            <tr><th>Script (self)</th><td><%= locale.getDisplayScript(locale) %></td></tr>
            <tr><th>Country (self)</th><td><%= locale.getDisplayCountry(locale) %></td></tr>
            <tr><th>Variant (self)</th><td><%= locale.getDisplayVariant(locale) %></td></tr>
        </table>

        <div class="section-header">Keywords</div>
        <table class="prop-table">
            <%
                java.util.Iterator<String> keywordsIter = locale.getKeywords();
                if (keywordsIter != null && keywordsIter.hasNext()) {
                    while (keywordsIter.hasNext()) {
                        String key = keywordsIter.next();
                        String value = locale.getKeywordValue(key);
            %>
            <tr><th><%= key %></th><td><%= value %></td></tr>
            <%
                    }
                } else {
            %>
            <tr><td colspan="2">No keywords found.</td></tr>
            <%
                }
            %>
        </table>

        <div class="section-header">Calendar Symbols</div>
        <table class="prop-table">
            <%
                com.ibm.icu.text.DateFormatSymbols dfs = new com.ibm.icu.text.DateFormatSymbols(locale);
                String[] months = dfs.getMonths();
                String[] shortMonths = dfs.getShortMonths();
                String[] weekdays = dfs.getWeekdays();
                String[] shortWeekdays = dfs.getShortWeekdays();
                String[] eras = dfs.getEras();
                String[] ampm = dfs.getAmPmStrings();
            %>
            <tr><th>Months (Wide)</th><td><%= java.util.Arrays.toString(java.util.Arrays.copyOfRange(months, 0, 12)) %></td></tr>
            <tr><th>Months (Abbr)</th><td><%= java.util.Arrays.toString(java.util.Arrays.copyOfRange(shortMonths, 0, 12)) %></td></tr>
            <tr><th>Weekdays (Wide)</th><td><%= java.util.Arrays.toString(java.util.Arrays.copyOfRange(weekdays, 1, 8)) %></td></tr>
            <tr><th>Weekdays (Abbr)</th><td><%= java.util.Arrays.toString(java.util.Arrays.copyOfRange(shortWeekdays, 1, 8)) %></td></tr>
            <tr><th>Eras</th><td><%= java.util.Arrays.toString(eras) %></td></tr>
            <tr><th>AM/PM</th><td><%= java.util.Arrays.toString(ampm) %></td></tr>
        </table>

        <div class="section-header">Numbers</div>
        <table class="prop-table">
            <%
                double num = 1234567.89;
            %>
            <tr><th>Decimal Format</th><td class="example"><%= com.ibm.icu.text.NumberFormat.getInstance(locale).format(num) %></td></tr>
            <tr><th>Currency Format</th><td class="example"><%= com.ibm.icu.text.NumberFormat.getCurrencyInstance(locale).format(num) %></td></tr>
            <tr><th>Percent Format</th><td class="example"><%= com.ibm.icu.text.NumberFormat.getPercentInstance(locale).format(0.1234) %></td></tr>
            <tr><th>Scientific Format</th><td class="example"><%= com.ibm.icu.text.NumberFormat.getScientificInstance(locale).format(num) %></td></tr>
        </table>

        <div class="section-header">Dates and Times</div>
        <table class="prop-table">
            <%
                java.util.Date now = new java.util.Date();
            %>
            <tr><th>Date (Short)</th><td class="example"><%= com.ibm.icu.text.DateFormat.getDateInstance(com.ibm.icu.text.DateFormat.SHORT, locale).format(now) %></td></tr>
            <tr><th>Date (Medium)</th><td class="example"><%= com.ibm.icu.text.DateFormat.getDateInstance(com.ibm.icu.text.DateFormat.MEDIUM, locale).format(now) %></td></tr>
            <tr><th>Date (Long)</th><td class="example"><%= com.ibm.icu.text.DateFormat.getDateInstance(com.ibm.icu.text.DateFormat.LONG, locale).format(now) %></td></tr>
            <tr><th>Date (Full)</th><td class="example"><%= com.ibm.icu.text.DateFormat.getDateInstance(com.ibm.icu.text.DateFormat.FULL, locale).format(now) %></td></tr>
            <tr><th>Time (Short)</th><td class="example"><%= com.ibm.icu.text.DateFormat.getTimeInstance(com.ibm.icu.text.DateFormat.SHORT, locale).format(now) %></td></tr>
            <tr><th>Time (Medium)</th><td class="example"><%= com.ibm.icu.text.DateFormat.getTimeInstance(com.ibm.icu.text.DateFormat.MEDIUM, locale).format(now) %></td></tr>
            <tr><th>Time (Long)</th><td class="example"><%= com.ibm.icu.text.DateFormat.getTimeInstance(com.ibm.icu.text.DateFormat.LONG, locale).format(now) %></td></tr>
            <tr><th>Time (Full)</th><td class="example"><%= com.ibm.icu.text.DateFormat.getTimeInstance(com.ibm.icu.text.DateFormat.FULL, locale).format(now) %></td></tr>
        </table>

        <div class="section-header">Plural Rules</div>
        <table class="prop-table">
            <%
                com.ibm.icu.text.PluralRules pr = com.ibm.icu.text.PluralRules.forLocale(locale);
                java.util.Set<String> keywords = pr.getKeywords();
            %>
            <tr><th>Keywords</th><td><%= keywords %></td></tr>
            <%
                for (String keyword : keywords) {
                    java.util.Collection<Double> samples = pr.getSamples(keyword);
            %>
            <tr>
                <th><%= keyword %></th>
                <td>Samples: <%= samples != null ? samples : "None" %></td>
            </tr>
            <%
                }
            %>
        </table>

        <div class="section-header">Other Info</div>
        <table class="prop-table">
            <%
                com.ibm.icu.util.Calendar cal = com.ibm.icu.util.Calendar.getInstance(locale);
                com.ibm.icu.util.Currency cur = com.ibm.icu.util.Currency.getInstance(locale);
            %>
            <tr><th>Default Calendar</th><td><%= cal.getType() %></td></tr>
            <tr><th>Default Currency</th><td><%= cur != null ? cur.getCurrencyCode() + " (" + cur.getDisplayName(locale.toLocale()) + ")" : "N/A" %></td></tr>
        </table>
        
        <div class="section-header">Exemplar Characters</div>
        <table class="prop-table">
            <%
                com.ibm.icu.util.LocaleData ld = com.ibm.icu.util.LocaleData.getInstance(locale);
                com.ibm.icu.text.UnicodeSet mainExemplars = ld.getExemplarSet(0, com.ibm.icu.util.LocaleData.ES_STANDARD);
                com.ibm.icu.text.UnicodeSet indexExemplars = ld.getExemplarSet(0, com.ibm.icu.util.LocaleData.ES_INDEX);
                com.ibm.icu.text.UnicodeSet auxExemplars = ld.getExemplarSet(0, com.ibm.icu.util.LocaleData.ES_AUXILIARY);
                com.ibm.icu.text.UnicodeSet punctExemplars = ld.getExemplarSet(0, com.ibm.icu.util.LocaleData.ES_PUNCTUATION);
            %>
            <tr><th>Standard</th><td style="word-break: break-all;"><% if(mainExemplars!=null) for(String s : mainExemplars) out.print(s + " "); %></td></tr>
            <tr><th>Auxiliary</th><td style="word-break: break-all;"><% if(auxExemplars!=null) for(String s : auxExemplars) out.print(s + " "); else out.print("None"); %></td></tr>
            <tr><th>Index</th><td style="word-break: break-all;"><% if(indexExemplars!=null) for(String s : indexExemplars) out.print(s + " "); else out.print("None"); %></td></tr>
            <tr><th>Punctuation</th><td style="word-break: break-all;"><% if(punctExemplars!=null) for(String s : punctExemplars) out.print(s + " "); else out.print("None"); %></td></tr>
        </table>

        <div class="section-header">List Patterns</div>
        <table class="prop-table">
            <%
                String[] items = {"Alice", "Bob", "Charlie"};
                com.ibm.icu.text.ListFormatter lf = com.ibm.icu.text.ListFormatter.getInstance(locale);
            %>
            <tr><th>3 items</th><td class="example"><%= lf.format(java.util.Arrays.asList(items)) %></td></tr>
        </table>

        <div class="section-header">Relative Date and Time</div>
        <table class="prop-table">
            <%
                com.ibm.icu.text.RelativeDateTimeFormatter rdtf = com.ibm.icu.text.RelativeDateTimeFormatter.getInstance(locale);
            %>
            <tr>
              <th>2 days ago</th>
              <td class="example"><%= rdtf.format(-2, com.ibm.icu.text.RelativeDateTimeFormatter.RelativeDateTimeUnit.DAY) %></td>
            </tr>
            <tr>
              <th>in 2 days</th>
              <td class="example"><%= rdtf.format(2, com.ibm.icu.text.RelativeDateTimeFormatter.RelativeDateTimeUnit.DAY) %></td>
            </tr>
            <tr>
              <th>Yesterday</th>
              <td class="example"><%= rdtf.format(com.ibm.icu.text.RelativeDateTimeFormatter.Direction.LAST, com.ibm.icu.text.RelativeDateTimeFormatter.AbsoluteUnit.DAY) %></td>
            </tr>
            <tr>
              <th>Tomorrow</th>
              <td class="example"><%= rdtf.format(com.ibm.icu.text.RelativeDateTimeFormatter.Direction.NEXT, com.ibm.icu.text.RelativeDateTimeFormatter.AbsoluteUnit.DAY) %></td>
            </tr>
        </table>

        <div class="section-header">Collation</div>
        <table class="prop-table">
            <%
                com.ibm.icu.text.Collator coll = com.ibm.icu.text.Collator.getInstance(locale);
            %>
            <tr><th>Default Collator</th><td><%= coll.getClass().getName() %></td></tr>
            <%
                if (coll instanceof com.ibm.icu.text.RuleBasedCollator) {
                    String rules = ((com.ibm.icu.text.RuleBasedCollator)coll).getRules();
            %>
            <tr>
                <th>Rules</th>
                <td>
                    <details>
                        <summary>View Rules</summary>
                        <pre class="rules"><%= rules %></pre>
                    </details>
                </td>
            </tr>
            <%
                }
            %>
            <%
                String[] words = {"Apple", "banana", "Cherry", "apple", "Banana"};
                String[] sortedWords = words.clone();
                java.util.Arrays.sort(sortedWords, coll);
            %>
            <tr>
              <th>Sorted Sample</th>
              <td><%= java.util.Arrays.toString(words) %> &rarr; <%= java.util.Arrays.toString(sortedWords) %></td>
            </tr>
        </table>

        <div class="section-header">Fallback Chain</div>
        <table class="prop-table">
            <tr>
                <th>Chain</th>
                <td>
                    <%
                        ULocale curr = locale;
                        while (curr != null) {
                            out.print(curr.toLanguageTag());
                            curr = curr.getFallback();
                            if (curr != null && curr.toString().length() > 0) {
                                out.print(" &rarr; ");
                            } else if (curr != null && curr.toString().length() == 0) {
                                out.print(" &rarr; Root");
                                break;
                            }
                        }
                    %>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
