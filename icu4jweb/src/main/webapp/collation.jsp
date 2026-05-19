<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.ibm.icu.util.ULocale" %>
<%@ page import="com.ibm.icu.text.Collator" %>
<%@ page import="com.ibm.icu.text.RuleBasedCollator" %>
<%@ page import="com.ibm.icu.text.CollationElementIterator" %>
<%@ page import="com.ibm.icu.text.CollationKey" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta content="Copyright (c) 2026 Unicode, Inc. and others. All Rights Reserved." name="COPYRIGHT" />
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>ICU4J Collation Demo</title>
    <%@ include file="demohead.jsf" %>
    <style type="text/css">
        .settings-table { font-size: 85%; margin-bottom: 1em; width: 100%; border-collapse: collapse; }
        .settings-table th { text-align: right; padding-right: 10px; white-space: nowrap; font-weight: bold; }
        .settings-table td { padding: 4px; }
        .default-flag { text-decoration: underline; }
        #intro { float: left; width: 50%; }
        #settings { float: right; width: 45%; padding-left: 2%; border-left: 1px solid #ccc; }
        #sortaction { clear: both; padding-top: 1em; padding-bottom: 1em; border-top: 1px solid #ccc; border-bottom: 1px solid #ccc; margin-bottom: 1em; }
        #inputsection { float: left; width: 33%; }
        #outputsection { float: right; width: 64%; }
        .output-table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        .output-table th { background-color: #99CCFF; color: black; text-align: left; padding: 6px; border: 1px solid #aaa; }
        .output-table td { padding: 6px; border: 1px solid #ccc; font-family: monospace; font-size: 11pt; }
        .output-table tr:nth-child(even) { background-color: #f9f9f9; }
        .output-table tr:hover { background-color: #f1f1f1; }
        .strength-diff { color: #006699; font-weight: bold; text-align: center; }
        .legend-box { margin-top: 2em; background-color: #f5f5f5; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 9pt; }
        .legend-box h4 { margin-top: 0; margin-bottom: 5px; }
        .legend-box p { margin: 3px 0; line-height: 1.3em; }
    </style>
</head>
<body>

<%@ include file="demolist.jsf" %>

<%
    request.setCharacterEncoding("utf-8");

    // Form fields retrieval
    String co = request.getParameter("co");
    if (co == null) co = "";

    String rules = request.getParameter("rules");
    if (rules == null) rules = "";

    String kk = request.getParameter("kk"); // normalization
    if (kk == null) kk = "?";

    String kn = request.getParameter("kn"); // numeric
    if (kn == null) kn = "?";

    String ks = request.getParameter("ks"); // strength
    if (ks == null) ks = "?";

    String kb = request.getParameter("kb"); // backwards
    if (kb == null) kb = "?";

    String kc = request.getParameter("kc"); // case level
    if (kc == null) kc = "?";

    String kf = request.getParameter("kf"); // case first
    if (kf == null) kf = "?";

    String ka = request.getParameter("ka"); // alternate
    if (ka == null) ka = "?";

    String kv = request.getParameter("kv"); // max variable
    if (kv == null) kv = "?";

    // Display checkboxes
    String ds = request.getParameter("ds"); // diff strengths
    if (ds == null && request.getParameter("submitted") != null) ds = "0";
    else if (ds == null) ds = "1"; // default checked

    String nr = request.getParameter("nr"); // input line numbers
    if (nr == null) nr = "0";

    String sk = request.getParameter("sk"); // sort keys
    if (sk == null) sk = "0";

    String ce = request.getParameter("ce"); // raw CEs
    if (ce == null) ce = "0";

    String input = request.getParameter("input");
    if (input == null) {
        // Default sample text
        input = "ｶ\nヵ\nabc\nab\\uFFFEc\nab©\n𝒶bc\n𝕒bc\nガ\nが\nabç\näbc\nカ\nか\nAbc\nabC\nFile-3\nfile-12\nfilé-110";
    }
%>

<%!
    // Decoder for escape sequences
    private static String unescape(String s) {
        if (s == null) return null;
        StringBuilder sb = new StringBuilder();
        int len = s.length();
        for (int i = 0; i < len; i++) {
            char c = s.charAt(i);
            if (c == '\\' && i + 1 < len) {
                char next = s.charAt(i + 1);
                if ((next == 'u' || next == 'U') && i + 2 < len) {
                    int offset = next == 'u' ? 4 : 8;
                    if (i + 2 + offset <= len) {
                        try {
                            int codePoint = Integer.parseInt(s.substring(i + 2, i + 2 + offset), 16);
                            sb.append(Character.toChars(codePoint));
                            i += 1 + offset;
                            continue;
                        } catch (NumberFormatException e) {
                            // ignore
                        }
                    }
                }
            }
            sb.append(c);
        }
        return sb.toString();
    }

    // Collator creation helper
    private static Collator createCollator(String coVal, String rulesVal, 
                                          String kkVal, String knVal, String ksVal, 
                                          String kbVal, String kcVal, String kfVal, 
                                          String kaVal, String kvVal) throws Exception {
        ULocale loc = ULocale.ROOT;
        if (coVal != null && !coVal.isEmpty()) {
            loc = new ULocale(coVal);
        }
        
        Collator coll = Collator.getInstance(loc);
        
        if (rulesVal != null && !rulesVal.trim().isEmpty()) {
            if (coll instanceof RuleBasedCollator) {
                String baseRules = ((RuleBasedCollator) coll).getRules();
                coll = new RuleBasedCollator(baseRules + "\n" + rulesVal);
            }
        }
        
        if (coll instanceof RuleBasedCollator) {
            RuleBasedCollator rbc = (RuleBasedCollator) coll;
            
            if ("P".equals(kkVal)) {
                rbc.setDecomposition(Collator.NO_DECOMPOSITION);
            } else if ("Q".equals(kkVal)) {
                rbc.setDecomposition(Collator.CANONICAL_DECOMPOSITION);
            }
            
            if ("P".equals(knVal)) {
                rbc.setNumericCollation(false);
            } else if ("Q".equals(knVal)) {
                rbc.setNumericCollation(true);
            }
            
            if ("@".equals(ksVal)) {
                rbc.setStrength(Collator.PRIMARY);
            } else if ("A".equals(ksVal)) {
                rbc.setStrength(Collator.SECONDARY);
            } else if ("B".equals(ksVal)) {
                rbc.setStrength(Collator.TERTIARY);
            } else if ("C".equals(ksVal)) {
                rbc.setStrength(Collator.QUATERNARY);
            } else if ("O".equals(ksVal)) {
                rbc.setStrength(Collator.IDENTICAL);
            }
            
            if ("P".equals(kbVal)) {
                rbc.setFrenchCollation(false);
            } else if ("Q".equals(kbVal)) {
                rbc.setFrenchCollation(true);
            }
            
            if ("P".equals(kcVal)) {
                rbc.setCaseLevel(false);
            } else if ("Q".equals(kcVal)) {
                rbc.setCaseLevel(true);
            }
            
            if ("P".equals(kfVal)) {
                rbc.setLowerCaseFirst(false);
                rbc.setUpperCaseFirst(false);
            } else if ("X".equals(kfVal)) {
                rbc.setLowerCaseFirst(true);
            } else if ("Y".equals(kfVal)) {
                rbc.setUpperCaseFirst(true);
            }
            
            if ("U".equals(kaVal)) {
                rbc.setAlternateHandlingShifted(false);
            } else if ("T".equals(kaVal)) {
                rbc.setAlternateHandlingShifted(true);
            }
            
            if ("@".equals(kvVal)) {
                rbc.setMaxVariable(Collator.ReorderCodes.SPACE);
            } else if ("A".equals(kvVal)) {
                rbc.setMaxVariable(Collator.ReorderCodes.PUNCTUATION);
            } else if ("B".equals(kvVal)) {
                rbc.setMaxVariable(Collator.ReorderCodes.SYMBOL);
            } else if ("C".equals(kvVal)) {
                rbc.setMaxVariable(Collator.ReorderCodes.CURRENCY);
            }
        }
        
        return coll;
    }

    // Difference strength helper
    private static String getDiffStrength(Collator baseColl, String s1, String s2) {
        if (s1.equals(s2)) {
            return "=";
        }
        
        Collator coll;
        try {
            coll = (Collator) baseColl.clone();
        } catch (CloneNotSupportedException e) {
            throw new RuntimeException(e);
        }
        
        boolean origCaseLevel = false;
        if (coll instanceof RuleBasedCollator) {
            origCaseLevel = ((RuleBasedCollator) coll).isCaseLevel();
            ((RuleBasedCollator) coll).setCaseLevel(false);
        }
        
        coll.setStrength(Collator.PRIMARY);
        if (coll.compare(s1, s2) != 0) {
            return "<1";
        }
        
        coll.setStrength(Collator.SECONDARY);
        if (coll.compare(s1, s2) != 0) {
            return "<2";
        }
        
        if (origCaseLevel) {
            ((RuleBasedCollator) coll).setCaseLevel(true);
            if (coll.compare(s1, s2) != 0) {
                return "<c";
            }
            ((RuleBasedCollator) coll).setCaseLevel(false);
        }
        
        coll.setStrength(Collator.TERTIARY);
        if (coll.compare(s1, s2) != 0) {
            return "<3";
        }
        
        coll.setStrength(Collator.QUATERNARY);
        if (coll.compare(s1, s2) != 0) {
            return "<4";
        }
        
        return "<i";
    }

    // Hex formatter for CollationKey
    private static String formatSortKey(Collator coll, String s) {
        CollationKey key = coll.getCollationKey(s);
        byte[] bytes = key.toByteArray();
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            int val = b & 0xFF;
            if (val == 0x01) {
                sb.append(" , ");
            } else if (val == 0x00) {
                sb.append(" .");
            } else {
                sb.append(String.format("%02X ", val));
            }
        }
        return sb.toString().trim();
    }

    // Formatting helper for CEs
    private static String formatCEs(Collator coll, String s) {
        if (!(coll instanceof RuleBasedCollator)) {
            return "N/A";
        }
        RuleBasedCollator rbc = (RuleBasedCollator) coll;
        CollationElementIterator iter = rbc.getCollationElementIterator(s);
        StringBuilder sb = new StringBuilder();
        int ce;
        while ((ce = iter.next()) != CollationElementIterator.NULLORDER) {
            int primary = CollationElementIterator.primaryOrder(ce);
            int secondary = CollationElementIterator.secondaryOrder(ce);
            int tertiary = CollationElementIterator.tertiaryOrder(ce);
            
            if (primary == 0 && secondary == 0 && tertiary == 0) {
                sb.append("[] ");
            } else {
                int caseBits = tertiary & 0xC0;
                int tertWeight = tertiary & 0x3F;
                String caseStr = "_";
                if (caseBits == 0x80) caseStr = "u";
                else if (caseBits == 0x40) caseStr = "m";
                
                sb.append(String.format("[%04X,%02X,%s%02X] ", 
                                        primary, secondary, caseStr, tertWeight));
            }
        }
        return sb.toString().trim();
    }

    // Checked radio/checkbox helpers
    private static String checked(String param, String value, String def) {
        if (param == null) {
            return value.equals(def) ? "checked=\"checked\"" : "";
        }
        return value.equals(param) ? "checked=\"checked\"" : "";
    }

    private static String checked(String param, String def) {
        if (param == null) {
            return "1".equals(def) ? "checked=\"checked\"" : "";
        }
        return "1".equals(param) ? "checked=\"checked\"" : "";
    }
%>

<h2>ICU4J Collation Demo</h2>

<form action="<%= request.getContextPath() + request.getServletPath() %>" method="post">
<input type="hidden" name="submitted" value="1" />

<div id="intro">
    <b>Collation Locale / Tailoring</b><br/>
    <select name="co" style="width: 95%; padding: 4px; margin-bottom: 8px;">
        <option value="" <%= "".equals(co) ? "selected=\"selected\"" : "" %>>und (type=standard): &nbsp; root (Standard Sort Order)</option>
        <option value="@collation=emoji" <%= "@collation=emoji".equals(co) ? "selected=\"selected\"" : "" %>>und-u-co-emoji: &nbsp; root (Emoji Sort Order)</option>
        <option value="@collation=eor" <%= "@collation=eor".equals(co) ? "selected=\"selected\"" : "" %>>und-u-co-eor: &nbsp; root (European Ordering Rules)</option>
        <option value="@collation=search" <%= "@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>und-u-co-search (normalization=on): &nbsp; root (General-Purpose Search)</option>
        <option value="af" <%= "af".equals(co) ? "selected=\"selected\"" : "" %>>af (type=standard): &nbsp; Afrikaans (Standard Sort Order)</option>
        <option value="am" <%= "am".equals(co) ? "selected=\"selected\"" : "" %>>am (type=standard): &nbsp; Amharic (Standard Sort Order)</option>
        <option value="ar" <%= "ar".equals(co) ? "selected=\"selected\"" : "" %>>ar (type=standard): &nbsp; Arabic (Standard Sort Order)</option>
        <option value="ar@collation=compat" <%= "ar@collation=compat".equals(co) ? "selected=\"selected\"" : "" %>>ar-u-co-compat: &nbsp; Arabic (Previous Sort Order, for compatibility)</option>
        <option value="as" <%= "as".equals(co) ? "selected=\"selected\"" : "" %>>as (type=standard, normalization=on): &nbsp; Assamese (Standard Sort Order)</option>
        <option value="az" <%= "az".equals(co) ? "selected=\"selected\"" : "" %>>az (type=standard): &nbsp; Azerbaijani (Standard Sort Order)</option>
        <option value="az@collation=search" <%= "az@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>az-u-co-search (normalization=on): &nbsp; Azerbaijani (General-Purpose Search)</option>
        <option value="be" <%= "be".equals(co) ? "selected=\"selected\"" : "" %>>be (type=standard): &nbsp; Belarusian (Standard Sort Order)</option>
        <option value="bg" <%= "bg".equals(co) ? "selected=\"selected\"" : "" %>>bg (type=standard): &nbsp; Bulgarian (Standard Sort Order)</option>
        <option value="bn" <%= "bn".equals(co) ? "selected=\"selected\"" : "" %>>bn (type=standard, normalization=on): &nbsp; Bangla (Standard Sort Order)</option>
        <option value="bn@collation=traditional" <%= "bn@collation=traditional".equals(co) ? "selected=\"selected\"" : "" %>>bn-u-co-trad (normalization=on): &nbsp; Bangla (Traditional Sort Order)</option>
        <option value="bo" <%= "bo".equals(co) ? "selected=\"selected\"" : "" %>>bo (type=standard, normalization=on): &nbsp; Tibetan (Standard Sort Order)</option>
        <option value="br" <%= "br".equals(co) ? "selected=\"selected\"" : "" %>>br (type=standard): &nbsp; Breton (Standard Sort Order)</option>
        <option value="bs" <%= "bs".equals(co) ? "selected=\"selected\"" : "" %>>bs (type=standard): &nbsp; Bosnian (Standard Sort Order)</option>
        <option value="bs@collation=search" <%= "bs@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>bs-u-co-search (normalization=on): &nbsp; Bosnian (General-Purpose Search)</option>
        <option value="bs_Cyrl" <%= "bs_Cyrl".equals(co) ? "selected=\"selected\"" : "" %>>bs-Cyrl (type=standard): &nbsp; Bosnian (Cyrillic, Standard Sort Order)</option>
        <option value="ca@collation=search" <%= "ca@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>ca-u-co-search (normalization=on): &nbsp; Catalan (General-Purpose Search)</option>
        <option value="ceb" <%= "ceb".equals(co) ? "selected=\"selected\"" : "" %>>ceb (type=standard): &nbsp; Cebuano (Standard Sort Order)</option>
        <option value="chr" <%= "chr".equals(co) ? "selected=\"selected\"" : "" %>>chr (type=standard): &nbsp; Cherokee (Standard Sort Order)</option>
        <option value="cs" <%= "cs".equals(co) ? "selected=\"selected\"" : "" %>>cs (type=standard): &nbsp; Czech (Standard Sort Order)</option>
        <option value="cy" <%= "cy".equals(co) ? "selected=\"selected\"" : "" %>>cy (type=standard): &nbsp; Welsh (Standard Sort Order)</option>
        <option value="da" <%= "da".equals(co) ? "selected=\"selected\"" : "" %>>da (type=standard, caseFirst=upper): &nbsp; Danish (Standard Sort Order)</option>
        <option value="da@collation=search" <%= "da@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>da-u-co-search (normalization=on): &nbsp; Danish (General-Purpose Search)</option>
        <option value="de@collation=phonebook" <%= "de@collation=phonebook".equals(co) ? "selected=\"selected\"" : "" %>>de-u-co-phonebk: &nbsp; German (Phonebook Sort Order)</option>
        <option value="de@collation=search" <%= "de@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>de-u-co-search (normalization=on): &nbsp; German (General-Purpose Search)</option>
        <option value="de_AT@collation=phonebook" <%= "de_AT@collation=phonebook".equals(co) ? "selected=\"selected\"" : "" %>>de-AT-u-co-phonebk: &nbsp; Austrian German (Phonebook Sort Order)</option>
        <option value="dsb" <%= "dsb".equals(co) ? "selected=\"selected\"" : "" %>>dsb (type=standard): &nbsp; Lower Sorbian (Standard Sort Order)</option>
        <option value="ee" <%= "ee".equals(co) ? "selected=\"selected\"" : "" %>>ee (type=standard): &nbsp; Ewe (Standard Sort Order)</option>
        <option value="el" <%= "el".equals(co) ? "selected=\"selected\"" : "" %>>el (type=standard, normalization=on): &nbsp; Greek (Standard Sort Order)</option>
        <option value="en_US_POSIX" <%= "en_US_POSIX".equals(co) ? "selected=\"selected\"" : "" %>>en-US-u-va-posix (type=standard): &nbsp; American English (Computer, Standard Sort Order)</option>
        <option value="eo" <%= "eo".equals(co) ? "selected=\"selected\"" : "" %>>eo (type=standard): &nbsp; Esperanto (Standard Sort Order)</option>
        <option value="es" <%= "es".equals(co) ? "selected=\"selected\"" : "" %>>es (type=standard): &nbsp; Spanish (Standard Sort Order)</option>
        <option value="es@collation=search" <%= "es@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>es-u-co-search (normalization=on): &nbsp; Spanish (General-Purpose Search)</option>
        <option value="es@collation=traditional" <%= "es@collation=traditional".equals(co) ? "selected=\"selected\"" : "" %>>es-u-co-trad: &nbsp; Spanish (Traditional Sort Order)</option>
        <option value="et" <%= "et".equals(co) ? "selected=\"selected\"" : "" %>>et (type=standard): &nbsp; Estonian (Standard Sort Order)</option>
        <option value="fa" <%= "fa".equals(co) ? "selected=\"selected\"" : "" %>>fa (type=standard, normalization=on): &nbsp; Persian (Standard Sort Order)</option>
        <option value="fa_AF" <%= "fa_AF".equals(co) ? "selected=\"selected\"" : "" %>>fa-AF (type=standard, normalization=on): &nbsp; Dari (Standard Sort Order)</option>
        <option value="ff_Adlm" <%= "ff_Adlm".equals(co) ? "selected=\"selected\"" : "" %>>ff-Adlm (type=standard): &nbsp; Fula (Adlam, Standard Sort Order)</option>
        <option value="fi" <%= "fi".equals(co) ? "selected=\"selected\"" : "" %>>fi (type=standard): &nbsp; Finnish (Standard Sort Order)</option>
        <option value="fi@collation=search" <%= "fi@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>fi-u-co-search (normalization=on): &nbsp; Finnish (General-Purpose Search)</option>
        <option value="fi@collation=traditional" <%= "fi@collation=traditional".equals(co) ? "selected=\"selected\"" : "" %>>fi-u-co-trad: &nbsp; Finnish (Traditional Sort Order)</option>
        <option value="fil" <%= "fil".equals(co) ? "selected=\"selected\"" : "" %>>fil (type=standard): &nbsp; Filipino (Standard Sort Order)</option>
        <option value="fo" <%= "fo".equals(co) ? "selected=\"selected\"" : "" %>>fo (type=standard): &nbsp; Faroese (Standard Sort Order)</option>
        <option value="fo@collation=search" <%= "fo@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>fo-u-co-search (normalization=on): &nbsp; Faroese (General-Purpose Search)</option>
        <option value="fr_CA" <%= "fr_CA".equals(co) ? "selected=\"selected\"" : "" %>>fr-CA (type=standard, backwards=on): &nbsp; Canadian French (Standard Sort Order)</option>
        <option value="fy" <%= "fy".equals(co) ? "selected=\"selected\"" : "" %>>fy (type=standard): &nbsp; Western Frisian (Standard Sort Order)</option>
        <option value="gl" <%= "gl".equals(co) ? "selected=\"selected\"" : "" %>>gl (type=standard): &nbsp; Galician (Standard Sort Order)</option>
        <option value="gl@collation=search" <%= "gl@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>gl-u-co-search (normalization=on): &nbsp; Galician (General-Purpose Search)</option>
        <option value="gu" <%= "gu".equals(co) ? "selected=\"selected\"" : "" %>>gu (type=standard, normalization=on): &nbsp; Gujarati (Standard Sort Order)</option>
        <option value="ha" <%= "ha".equals(co) ? "selected=\"selected\"" : "" %>>ha (type=standard): &nbsp; Hausa (Standard Sort Order)</option>
        <option value="haw" <%= "haw".equals(co) ? "selected=\"selected\"" : "" %>>haw (type=standard): &nbsp; Hawaiian (Standard Sort Order)</option>
        <option value="he" <%= "he".equals(co) ? "selected=\"selected\"" : "" %>>he (type=standard, normalization=on): &nbsp; Hebrew (Standard Sort Order)</option>
        <option value="hi" <%= "hi".equals(co) ? "selected=\"selected\"" : "" %>>hi (type=standard, normalization=on): &nbsp; Hindi (Standard Sort Order)</option>
        <option value="hr" <%= "hr".equals(co) ? "selected=\"selected\"" : "" %>>hr (type=standard): &nbsp; Croatian (Standard Sort Order)</option>
        <option value="hr@collation=search" <%= "hr@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>hr-u-co-search (normalization=on): &nbsp; Croatian (General-Purpose Search)</option>
        <option value="hsb" <%= "hsb".equals(co) ? "selected=\"selected\"" : "" %>>hsb (type=standard): &nbsp; Upper Sorbian (Standard Sort Order)</option>
        <option value="hu" <%= "hu".equals(co) ? "selected=\"selected\"" : "" %>>hu (type=standard): &nbsp; Hungarian (Standard Sort Order)</option>
        <option value="hy" <%= "hy".equals(co) ? "selected=\"selected\"" : "" %>>hy (type=standard): &nbsp; Armenian (Standard Sort Order)</option>
        <option value="ig" <%= "ig".equals(co) ? "selected=\"selected\"" : "" %>>ig (type=standard, normalization=on): &nbsp; Igbo (Standard Sort Order)</option>
        <option value="is" <%= "is".equals(co) ? "selected=\"selected\"" : "" %>>is (type=standard): &nbsp; Icelandic (Standard Sort Order)</option>
        <option value="is@collation=search" <%= "is@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>is-u-co-search (normalization=on): &nbsp; Icelandic (General-Purpose Search)</option>
        <option value="ja" <%= "ja".equals(co) ? "selected=\"selected\"" : "" %>>ja (type=standard): &nbsp; Japanese (Standard Sort Order)</option>
        <option value="ja@collation=unihan" <%= "ja@collation=unihan".equals(co) ? "selected=\"selected\"" : "" %>>ja-u-co-unihan: &nbsp; Japanese (Radical-Stroke Sort Order)</option>
        <option value="ka" <%= "ka".equals(co) ? "selected=\"selected\"" : "" %>>ka (type=standard): &nbsp; Georgian (Standard Sort Order)</option>
        <option value="kk" <%= "kk".equals(co) ? "selected=\"selected\"" : "" %>>kk (type=standard): &nbsp; Kazakh (Standard Sort Order)</option>
        <option value="kl" <%= "kl".equals(co) ? "selected=\"selected\"" : "" %>>kl (type=standard): &nbsp; Kalaallisut (Standard Sort Order)</option>
        <option value="kl@collation=search" <%= "kl@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>kl-u-co-search (normalization=on): &nbsp; Kalaallisut (General-Purpose Search)</option>
        <option value="km" <%= "km".equals(co) ? "selected=\"selected\"" : "" %>>km (type=standard, normalization=on): &nbsp; Khmer (Standard Sort Order)</option>
        <option value="kn" <%= "kn".equals(co) ? "selected=\"selected\"" : "" %>>kn (type=standard, normalization=on): &nbsp; Kannada (Standard Sort Order)</option>
        <option value="kn@collation=traditional" <%= "kn@collation=traditional".equals(co) ? "selected=\"selected\"" : "" %>>kn-u-co-trad (normalization=on): &nbsp; Kannada (Traditional Sort Order)</option>
        <option value="ko" <%= "ko".equals(co) ? "selected=\"selected\"" : "" %>>ko (type=standard): &nbsp; Korean (Standard Sort Order)</option>
        <option value="ko@collation=search" <%= "ko@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>ko-u-co-search (normalization=on): &nbsp; Korean (General-Purpose Search)</option>
        <option value="ko@collation=searchjl" <%= "ko@collation=searchjl".equals(co) ? "selected=\"selected\"" : "" %>>ko-u-co-searchjl (normalization=on): &nbsp; Korean (Search By Hangul Initial Consonant)</option>
        <option value="ko@collation=unihan" <%= "ko@collation=unihan".equals(co) ? "selected=\"selected\"" : "" %>>ko-u-co-unihan: &nbsp; Korean (Radical-Stroke Sort Order)</option>
        <option value="kok" <%= "kok".equals(co) ? "selected=\"selected\"" : "" %>>kok (type=standard, normalization=on): &nbsp; Konkani (Standard Sort Order)</option>
        <option value="ku" <%= "ku".equals(co) ? "selected=\"selected\"" : "" %>>ku (type=standard): &nbsp; Kurdish (Standard Sort Order)</option>
        <option value="ky" <%= "ky".equals(co) ? "selected=\"selected\"" : "" %>>ky (type=standard): &nbsp; Kyrgyz (Standard Sort Order)</option>
        <option value="lkt" <%= "lkt".equals(co) ? "selected=\"selected\"" : "" %>>lkt (type=standard): &nbsp; Lakota (Standard Sort Order)</option>
        <option value="ln" <%= "ln".equals(co) ? "selected=\"selected\"" : "" %>>ln (type=standard): &nbsp; Lingala (Standard Sort Order)</option>
        <option value="ln@collation=phonetic" <%= "ln@collation=phonetic".equals(co) ? "selected=\"selected\"" : "" %>>ln-u-co-phonetic: &nbsp; Lingala (Phonetic Sort Order)</option>
        <option value="lo" <%= "lo".equals(co) ? "selected=\"selected\"" : "" %>>lo (type=standard): &nbsp; Lao (Standard Sort Order)</option>
        <option value="lt" <%= "lt".equals(co) ? "selected=\"selected\"" : "" %>>lt (type=standard): &nbsp; Lithuanian (Standard Sort Order)</option>
        <option value="lv" <%= "lv".equals(co) ? "selected=\"selected\"" : "" %>>lv (type=standard): &nbsp; Latvian (Standard Sort Order)</option>
        <option value="mk" <%= "mk".equals(co) ? "selected=\"selected\"" : "" %>>mk (type=standard): &nbsp; Macedonian (Standard Sort Order)</option>
        <option value="ml" <%= "ml".equals(co) ? "selected=\"selected\"" : "" %>>ml (type=standard): &nbsp; Malayalam (Standard Sort Order)</option>
        <option value="mn" <%= "mn".equals(co) ? "selected=\"selected\"" : "" %>>mn (type=standard): &nbsp; Mongolian (Standard Sort Order)</option>
        <option value="mr" <%= "mr".equals(co) ? "selected=\"selected\"" : "" %>>mr (type=standard, normalization=on): &nbsp; Marathi (Standard Sort Order)</option>
        <option value="mt" <%= "mt".equals(co) ? "selected=\"selected\"" : "" %>>mt (type=standard, caseFirst=upper): &nbsp; Maltese (Standard Sort Order)</option>
        <option value="my" <%= "my".equals(co) ? "selected=\"selected\"" : "" %>>my (type=standard, normalization=on): &nbsp; Burmese (Standard Sort Order)</option>
        <option value="ne" <%= "ne".equals(co) ? "selected=\"selected\"" : "" %>>ne (type=standard): &nbsp; Nepali (Standard Sort Order)</option>
        <option value="no" <%= "no".equals(co) ? "selected=\"selected\"" : "" %>>no (type=standard): &nbsp; Norwegian (Standard Sort Order)</option>
        <option value="no@collation=search" <%= "no@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>no-u-co-search (normalization=on): &nbsp; Norwegian (General-Purpose Search)</option>
        <option value="nso" <%= "nso".equals(co) ? "selected=\"selected\"" : "" %>>nso (type=standard): &nbsp; Northern Sotho (Standard Sort Order)</option>
        <option value="om" <%= "om".equals(co) ? "selected=\"selected\"" : "" %>>om (type=standard): &nbsp; Oromo (Standard Sort Order)</option>
        <option value="or" <%= "or".equals(co) ? "selected=\"selected\"" : "" %>>or (type=standard, normalization=on): &nbsp; Odia (Standard Sort Order)</option>
        <option value="pa" <%= "pa".equals(co) ? "selected=\"selected\"" : "" %>>pa (type=standard, normalization=on): &nbsp; Punjabi (Standard Sort Order)</option>
        <option value="pl" <%= "pl".equals(co) ? "selected=\"selected\"" : "" %>>pl (type=standard): &nbsp; Polish (Standard Sort Order)</option>
        <option value="ps" <%= "ps".equals(co) ? "selected=\"selected\"" : "" %>>ps (type=standard, normalization=on): &nbsp; Pashto (Standard Sort Order)</option>
        <option value="ro" <%= "ro".equals(co) ? "selected=\"selected\"" : "" %>>ro (type=standard): &nbsp; Romanian (Standard Sort Order)</option>
        <option value="ru" <%= "ru".equals(co) ? "selected=\"selected\"" : "" %>>ru (type=standard): &nbsp; Russian (Standard Sort Order)</option>
        <option value="se" <%= "se".equals(co) ? "selected=\"selected\"" : "" %>>se (type=standard): &nbsp; Northern Sami (Standard Sort Order)</option>
        <option value="se@collation=search" <%= "se@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>se-u-co-search (normalization=on): &nbsp; Northern Sami (General-Purpose Search)</option>
        <option value="si" <%= "si".equals(co) ? "selected=\"selected\"" : "" %>>si (type=standard, normalization=on): &nbsp; Sinhala (Standard Sort Order)</option>
        <option value="si@collation=dictionary" <%= "si@collation=dictionary".equals(co) ? "selected=\"selected\"" : "" %>>si-u-co-dict (normalization=on): &nbsp; Sinhala (Dictionary Sort Order)</option>
        <option value="sk" <%= "sk".equals(co) ? "selected=\"selected\"" : "" %>>sk (type=standard): &nbsp; Slovak (Standard Sort Order)</option>
        <option value="sk@collation=search" <%= "sk@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>sk-u-co-search (normalization=on): &nbsp; Slovak (General-Purpose Search)</option>
        <option value="sl" <%= "sl".equals(co) ? "selected=\"selected\"" : "" %>>sl (type=standard): &nbsp; Slovenian (Standard Sort Order)</option>
        <option value="smn" <%= "smn".equals(co) ? "selected=\"selected\"" : "" %>>smn (type=standard): &nbsp; Inari Sami (Standard Sort Order)</option>
        <option value="smn@collation=search" <%= "smn@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>smn-u-co-search (normalization=on): &nbsp; Inari Sami (General-Purpose Search)</option>
        <option value="sq" <%= "sq".equals(co) ? "selected=\"selected\"" : "" %>>sq (type=standard): &nbsp; Albanian (Standard Sort Order)</option>
        <option value="sr" <%= "sr".equals(co) ? "selected=\"selected\"" : "" %>>sr (type=standard): &nbsp; Serbian (Standard Sort Order)</option>
        <option value="sr_Latn" <%= "sr_Latn".equals(co) ? "selected=\"selected\"" : "" %>>sr-Latn (type=standard): &nbsp; Serbian (Latin, Standard Sort Order)</option>
        <option value="sr_Latn@collation=search" <%= "sr_Latn@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>sr-Latn-u-co-search (normalization=on): &nbsp; Serbian (Latin, General-Purpose Search)</option>
        <option value="sv" <%= "sv".equals(co) ? "selected=\"selected\"" : "" %>>sv (type=standard): &nbsp; Swedish (Standard Sort Order)</option>
        <option value="sv@collation=search" <%= "sv@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>sv-u-co-search (normalization=on): &nbsp; Swedish (General-Purpose Search)</option>
        <option value="sv@collation=traditional" <%= "sv@collation=traditional".equals(co) ? "selected=\"selected\"" : "" %>>sv-u-co-trad: &nbsp; Swedish (Traditional Sort Order)</option>
        <option value="ta" <%= "ta".equals(co) ? "selected=\"selected\"" : "" %>>ta (type=standard, normalization=on): &nbsp; Tamil (Standard Sort Order)</option>
        <option value="te" <%= "te".equals(co) ? "selected=\"selected\"" : "" %>>te (type=standard, normalization=on): &nbsp; Telugu (Standard Sort Order)</option>
        <option value="th" <%= "th".equals(co) ? "selected=\"selected\"" : "" %>>th (type=standard, alternate=shifted, normalization=on): &nbsp; Thai (Standard Sort Order)</option>
        <option value="tk" <%= "tk".equals(co) ? "selected=\"selected\"" : "" %>>tk (type=standard): &nbsp; Turkmen (Standard Sort Order)</option>
        <option value="tn" <%= "tn".equals(co) ? "selected=\"selected\"" : "" %>>tn (type=standard): &nbsp; Tswana (Standard Sort Order)</option>
        <option value="to" <%= "to".equals(co) ? "selected=\"selected\"" : "" %>>to (type=standard): &nbsp; Tongan (Standard Sort Order)</option>
        <option value="tr" <%= "tr".equals(co) ? "selected=\"selected\"" : "" %>>tr (type=standard): &nbsp; Turkish (Standard Sort Order)</option>
        <option value="tr@collation=search" <%= "tr@collation=search".equals(co) ? "selected=\"selected\"" : "" %>>tr-u-co-search (normalization=on): &nbsp; Turkish (General-Purpose Search)</option>
        <option value="ug" <%= "ug".equals(co) ? "selected=\"selected\"" : "" %>>ug (type=standard): &nbsp; Uyghur (Standard Sort Order)</option>
        <option value="uk" <%= "uk".equals(co) ? "selected=\"selected\"" : "" %>>uk (type=standard): &nbsp; Ukrainian (Standard Sort Order)</option>
        <option value="ur" <%= "ur".equals(co) ? "selected=\"selected\"" : "" %>>ur (type=standard): &nbsp; Urdu (Standard Sort Order)</option>
        <option value="uz" <%= "uz".equals(co) ? "selected=\"selected\"" : "" %>>uz (type=standard): &nbsp; Uzbek (Standard Sort Order)</option>
        <option value="vi" <%= "vi".equals(co) ? "selected=\"selected\"" : "" %>>vi (type=standard, normalization=on): &nbsp; Vietnamese (Standard Sort Order)</option>
        <option value="vi@collation=traditional" <%= "vi@collation=traditional".equals(co) ? "selected=\"selected\"" : "" %>>vi-u-co-trad (normalization=on): &nbsp; Vietnamese (Traditional Sort Order)</option>
        <option value="wo" <%= "wo".equals(co) ? "selected=\"selected\"" : "" %>>wo (type=standard, normalization=on): &nbsp; Wolof (Standard Sort Order)</option>
        <option value="yi" <%= "yi".equals(co) ? "selected=\"selected\"" : "" %>>yi (type=standard, normalization=on): &nbsp; Yiddish (Standard Sort Order)</option>
        <option value="yo" <%= "yo".equals(co) ? "selected=\"selected\"" : "" %>>yo (type=standard, normalization=on): &nbsp; Yoruba (Standard Sort Order)</option>
        <option value="zh" <%= "zh".equals(co) ? "selected=\"selected\"" : "" %>>zh (type=pinyin): &nbsp; Chinese (Pinyin Sort Order)</option>
        <option value="zh@collation=stroke" <%= "zh@collation=stroke".equals(co) ? "selected=\"selected\"" : "" %>>zh-u-co-stroke: &nbsp; Chinese (Stroke Sort Order)</option>
        <option value="zh@collation=unihan" <%= "zh@collation=unihan".equals(co) ? "selected=\"selected\"" : "" %>>zh-u-co-unihan: &nbsp; Chinese (Radical-Stroke Sort Order)</option>
        <option value="zh@collation=zhuyin" <%= "zh@collation=zhuyin".equals(co) ? "selected=\"selected\"" : "" %>>zh-u-co-zhuyin: &nbsp; Chinese (Zhuyin Sort Order)</option>
    </select><br/>
    
    Append rules: (For examples see the <a href="https://github.com/unicode-org/cldr/tree/main/common/collation" target="_blank">CLDR tailoring data</a>)<br/>
    <textarea name="rules" rows="5" style="width: 95%; padding: 4px; font-family: monospace;"><%= escapeString(rules) %></textarea>
</div>

<div id="settings">
    <b>Collation Settings</b>
    <table class="settings-table">
        <tr>
            <th>normalization:</th>
            <td>
                <input type="radio" name="kk" value="?" <%= checked(kk, "?", "?") %>/>default
                <input type="radio" name="kk" value="P" <%= checked(kk, "P", "?") %>/><span class="default-flag">off</span>
                <input type="radio" name="kk" value="Q" <%= checked(kk, "Q", "?") %>/>on
            </td>
        </tr>
        <tr>
            <th>numeric:</th>
            <td>
                <input type="radio" name="kn" value="?" <%= checked(kn, "?", "?") %>/>default
                <input type="radio" name="kn" value="P" <%= checked(kn, "P", "?") %>/><span class="default-flag">off</span>
                <input type="radio" name="kn" value="Q" <%= checked(kn, "Q", "?") %>/>on
            </td>
        </tr>
        <tr>
            <th>strength:</th>
            <td>
                <input type="radio" name="ks" value="?" <%= checked(ks, "?", "?") %>/>default
                <input type="radio" name="ks" value="@" <%= checked(ks, "@", "?") %>/>primary
                <input type="radio" name="ks" value="A" <%= checked(ks, "A", "?") %>/>secondary<br/>
                <input type="radio" name="ks" value="B" <%= checked(ks, "B", "?") %>/><span class="default-flag">tertiary</span>
                <input type="radio" name="ks" value="C" <%= checked(ks, "C", "?") %>/>quaternary
                <input type="radio" name="ks" value="O" <%= checked(ks, "O", "?") %>/>identical
            </td>
        </tr>
        <tr>
            <th>backwards<br/>secondary:</th>
            <td>
                <input type="radio" name="kb" value="?" <%= checked(kb, "?", "?") %>/>default
                <input type="radio" name="kb" value="P" <%= checked(kb, "P", "?") %>/><span class="default-flag">off</span>
                <input type="radio" name="kb" value="Q" <%= checked(kb, "Q", "?") %>/>on
            </td>
        </tr>
        <tr>
            <th>case level:</th>
            <td>
                <input type="radio" name="kc" value="?" <%= checked(kc, "?", "?") %>/>default
                <input type="radio" name="kc" value="P" <%= checked(kc, "P", "?") %>/><span class="default-flag">off</span>
                <input type="radio" name="kc" value="Q" <%= checked(kc, "Q", "?") %>/>on
            </td>
        </tr>
        <tr>
            <th>case first:</th>
            <td>
                <input type="radio" name="kf" value="?" <%= checked(kf, "?", "?") %>/>default
                <input type="radio" name="kf" value="P" <%= checked(kf, "P", "?") %>/><span class="default-flag">off</span>
                <input type="radio" name="kf" value="X" <%= checked(kf, "X", "?") %>/>lower
                <input type="radio" name="kf" value="Y" <%= checked(kf, "Y", "?") %>/>upper
            </td>
        </tr>
        <tr>
            <th>alternate:</th>
            <td>
                <input type="radio" name="ka" value="?" <%= checked(ka, "?", "?") %>/>default
                <input type="radio" name="ka" value="U" <%= checked(ka, "U", "?") %>/><span class="default-flag">non-ignorable</span>
                <input type="radio" name="ka" value="T" <%= checked(ka, "T", "?") %>/>shifted
            </td>
        </tr>
        <tr>
            <th>max variable:</th>
            <td>
                <input type="radio" name="kv" value="?" <%= checked(kv, "?", "?") %>/>default
                <input type="radio" name="kv" value="@" <%= checked(kv, "@", "?") %>/>space
                <input type="radio" name="kv" value="A" <%= checked(kv, "A", "?") %>/><span class="default-flag">punct</span>
                <input type="radio" name="kv" value="B" <%= checked(kv, "B", "?") %>/>symbol
                <input type="radio" name="kv" value="C" <%= checked(kv, "C", "?") %>/>currency
            </td>
        </tr>
    </table>
</div>

<div id="sortaction">
    <input type="submit" value=" &nbsp; sort &nbsp; " style="font-size: 12pt; font-weight: bold; padding: 4px 12px; cursor: pointer;" /> &nbsp;&nbsp; &nbsp;&nbsp;
    <label><input type="checkbox" name="ds" value="1" <%= checked(ds, "1") %>/> diff strengths</label> &nbsp;&nbsp;
    <label><input type="checkbox" name="nr" value="1" <%= checked(nr, "1") %>/> input line numbers</label> &nbsp;&nbsp;
    <label><input type="checkbox" name="sk" value="1" <%= checked(sk, "1") %>/> sort keys</label> &nbsp;&nbsp;
    <label><input type="checkbox" name="ce" value="1" <%= checked(ce, "1") %>/> raw collation elements</label>
</div>

<div id="inputsection">
    <p><b>Input Strings</b> (one per line)</p>
    <textarea name="input" rows="25" style="width: 95%; padding: 4px; font-family: monospace; font-size: 11pt;"><%= escapeString(input) %></textarea>
    <p style="font-size: 8.5pt; color: #555; margin-top: 5px;">
        Escape syntax supported: <tt>\uHHHH</tt> (16-bit) or <tt>\U00HHHHHH</tt> (32-bit). E.g. <tt>ab\uFFFEc</tt> or <tt>ab\U0000FFFEc</tt>.
    </p>
</div>

<div id="outputsection">
    <p><b>Output / Sorted Results</b></p>
    
    <%
        try {
            // Create & configure collator
            Collator coll = createCollator(co, rules, kk, kn, ks, kb, kc, kf, ka, kv);
            
            // Split input lines
            String[] rawLines = input.split("\\r?\\n");
            
            // Container class for sorting
            class SortedItem implements Comparable<SortedItem> {
                int originalIndex;
                String raw;
                String unescaped;
                Collator collator;
                
                SortedItem(int index, String r, Collator c) {
                    this.originalIndex = index;
                    this.raw = r;
                    this.unescaped = unescape(r);
                    this.collator = c;
                }
                
                @Override
                public int compareTo(SortedItem other) {
                    return this.collator.compare(this.unescaped, other.unescaped);
                }
            }
            
            List<SortedItem> list = new ArrayList<SortedItem>();
            for (int i = 0; i < rawLines.length; i++) {
                list.add(new SortedItem(i + 1, rawLines[i], coll));
            }
            
            // Stable sort
            Collections.sort(list);
    %>
            <table class="output-table">
                <thead>
                    <tr>
                        <% if ("1".equals(nr)) { %>
                            <th style="width: 5%;">Line</th>
                        <% } %>
                        <th>Sorted Value</th>
                        <% if ("1".equals(ds)) { %>
                            <th style="width: 8%; text-align: center;">Diff</th>
                        <% } %>
                        <% if ("1".equals(sk)) { %>
                            <th>Collation Sort Key</th>
                        <% } %>
                        <% if ("1".equals(ce)) { %>
                            <th>Raw Collation Elements (CEs)</th>
                        <% } %>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (int i = 0; i < list.size(); i++) {
                            SortedItem current = list.get(i);
                            
                            // Determine difference strength to next item
                            String diffStr = "";
                            if ("1".equals(ds) && i < list.size() - 1) {
                                SortedItem next = list.get(i + 1);
                                diffStr = getDiffStrength(coll, current.unescaped, next.unescaped);
                            }
                    %>
                            <tr>
                                <% if ("1".equals(nr)) { %>
                                    <td style="color: #777; font-size: 9pt;"><%= current.originalIndex %></td>
                                <% } %>
                                <td style="font-weight: bold;"><%= escapeString(current.unescaped) %></td>
                                <% if ("1".equals(ds)) { %>
                                    <td class="strength-diff"><%= diffStr %></td>
                                <% } %>
                                <% if ("1".equals(sk)) { %>
                                    <td style="color: #555; word-break: break-all; font-size: 9.5pt;">
                                        <%= formatSortKey(coll, current.unescaped) %>
                                    </td>
                                <% } %>
                                <% if ("1".equals(ce)) { %>
                                    <td style="color: #006633; font-size: 9pt;">
                                        <%= formatCEs(coll, current.unescaped) %>
                                    </td>
                                <% } %>
                            </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
    <%
        } catch (Throwable t) {
            StringWriter sw = new StringWriter();
            t.printStackTrace(new PrintWriter(sw));
    %>
            <div style="border: 1px solid red; background-color: #fff2f2; padding: 10px; margin-top: 10px; border-radius: 4px;">
                <b style="color: red;">Collation Customization Error:</b>
                <pre style="white-space: pre-wrap; margin-top: 5px; font-size: 9.5pt;"><%= escapeString(sw.toString()) %></pre>
            </div>
    <%
        }
    %>
    
    <div class="legend-box">
        <h4>Legend</h4>
        <p><b>Difference strengths:</b> <tt>=</tt> equal &nbsp;&nbsp; <tt>&lt;1</tt> primary &nbsp;&nbsp; <tt>&lt;2</tt> secondary &nbsp;&nbsp; <tt>&lt;c</tt> case level &nbsp;&nbsp; <tt>&lt;3</tt> tertiary &nbsp;&nbsp; <tt>&lt;4</tt> quaternary &nbsp;&nbsp; <tt>&lt;i</tt> identical level</p>
        <p><b>Sort keys format:</b> <tt>,</tt> = 01 level separator &nbsp;&nbsp; <tt>.</tt> = 00 terminator</p>
        <p><b>Raw CEs format:</b> <tt>[]</tt> for completely ignorable, or <tt>[primary, secondary, case + tertiary]</tt></p>
        <p><b>Case indicator (inside CEs):</b> <tt>_</tt> = uncased/lowercase &nbsp;&nbsp; <tt>m</tt> = mixed case &nbsp;&nbsp; <tt>u</tt> = uppercase</p>
    </div>
</div>

</form>

<div style="clear: both; padding-top: 3em; text-align: center; font-size: 9pt; color: #888;">
    Powered by ICU4J <%= com.ibm.icu.util.VersionInfo.ICU_VERSION %>
</div>

</body>
</html>
