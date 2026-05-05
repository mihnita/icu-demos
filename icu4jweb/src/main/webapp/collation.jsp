<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
  <%@ include file="demohead.jsf" %>
  <title>Tuesdays and Thursdays</title>
  <style type="text/css">
    .settings { font-size:67% }
    .default { text-decoration:underline }
    th { text-align:right }
    #intro { float:left }
    #settings { float:left }
    #sortaction { clear:both }
    #inputsection {
      float:left;
      width:33%
    }
    #outputsection {
      width:66%;
      margin-left:33%
    }
  </style>

<%!
  static final String getParam(ServletRequest req, String name, String defValue) {
    String result = req.getParameter(name);
    return result == null ? defValue : result;
  }
%>  
</head>
<body>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.ibm.icu.util.*" %>
<%@ page import="com.ibm.icu.text.*" %>
<%@ page import="com.ibm.icu.dev.demo.icu4jweb.ListPatternFormatter" %>
<%@ page import="java.text.ParsePosition" %>
<%@ page import="javax.xml.parsers.*" %>
<%@ page import="org.w3c.dom.*" %>

<%@ include file="demolist.jsf"  %>

<%
request.setCharacterEncoding("UTF-8");
response.setContentType("text/html;charset=utf-8");

String textToSort = getParam(request, "input", "");
String kk = getParam(request, "kk", "?");
String kn = getParam(request, "kn", "?");
String ks = getParam(request, "ks", "?");
String kb = getParam(request, "kb", "?");
String kc = getParam(request, "kc", "?");
String kf = getParam(request, "kf", "?");
String ka = getParam(request, "ka", "?");
String kv = getParam(request, "kv", "?");
String co = getParam(request, "co", "????");

String ds = getParam(request, "ds", "0");
String nr = getParam(request, "nr", "0");
String sk = getParam(request, "sk", "0");
String ce = getParam(request, "ce", "0");

System.out.println("===== BINGO! =====");
System.out.println("locale: " + co);
System.out.println("normalization: " + kk);
System.out.println("numeric: " + kn);
System.out.println("strength: " + ks);
System.out.println("backwards secondary: " + kb);
System.out.println("case level: " + kc);
System.out.println("case first: " + kf);
System.out.println("alternate: " + ka);
System.out.println("max variable: " + kv);
System.out.println("diff strengths: " + ds);
System.out.println("input line numbers: " + nr);
System.out.println("sort keys: " + sk);
System.out.println("raw collation elements: " + ce);

System.out.println("------------------");
System.out.println(textToSort);
System.out.println("==================");

String [] pieces = textToSort.split("\n");
Collator collat = Collator.getInstance(new ULocale(co));
Arrays.sort(pieces, collat);

StringBuffer tmpBuf = new StringBuffer();
for (String s : pieces) {
  tmpBuf.append(s + "<br>");
}
String output = tmpBuf.toString();
// "<span color='red'>foo</span> <b>BOLD</b>\n<span color='red'>bar</span>";

%>

<h1>Collation Demo</h1>

<form action="<%= request.getContextPath() + request.getServletPath() %>" method="post">
<div id="intro">

<h1><a href="https://icu.unicode.org/">ICU</a> Collation Demo</h1>
<p><a href="https://unicode-org.github.io/icu/userguide/collation/customization/">User Guide</a> —
<a href="https://www.unicode.org/reports/tr35/tr35-collation.html">LDML Collation</a> —
<a href="https://icu4c-demos.unicode.org/icu-bin/icudemos">ICU4C Demos</a> —
<a href="https://icu.unicode.org/home/icu4j-demos">ICU4J Demos</a></p>
<select name="co"><!-- begin output from webdemo/collation/available -->
<option value="">und (type=standard):   root (Standard Sort Order)</option>
<option value="@collation=emoji">und-u-co-emoji:   root (Emoji Sort Order)</option>
<option value="@collation=eor">und-u-co-eor:   root (European Ordering Rules)</option>
<option value="@collation=search">und-u-co-search (normalization=on):   root (General-Purpose Search)</option>
<option value="af">af (type=standard):   Afrikaans (Standard Sort Order)</option>
<option value="am">am (type=standard):   Amharic (Standard Sort Order)</option>
<option value="ar">ar (type=standard):   Arabic (Standard Sort Order)</option>
<option value="ar@collation=compat">ar-u-co-compat:   Arabic (Previous Sort Order, for compatibility)</option>
<option value="as">as (type=standard, normalization=on):   Assamese (Standard Sort Order)</option>
<option value="az">az (type=standard):   Azerbaijani (Standard Sort Order)</option>
<option value="az@collation=search">az-u-co-search (normalization=on):   Azerbaijani (General-Purpose Search)</option>
<option value="be">be (type=standard):   Belarusian (Standard Sort Order)</option>
<option value="bg">bg (type=standard):   Bulgarian (Standard Sort Order)</option>
<option value="bn">bn (type=standard, normalization=on):   Bangla (Standard Sort Order)</option>
<option value="bn@collation=traditional">bn-u-co-trad (normalization=on):   Bangla (Traditional Sort Order)</option>
<option value="bo">bo (type=standard, normalization=on):   Tibetan (Standard Sort Order)</option>
<option value="br">br (type=standard):   Breton (Standard Sort Order)</option>
<option value="bs">bs (type=standard):   Bosnian (Standard Sort Order)</option>
<option value="bs@collation=search">bs-u-co-search (normalization=on):   Bosnian (General-Purpose Search)</option>
<option value="bs_Cyrl">bs-Cyrl (type=standard):   Bosnian (Cyrillic, Standard Sort Order)</option>
<option value="ca@collation=search">ca-u-co-search (normalization=on):   Catalan (General-Purpose Search)</option>
<option value="ceb">ceb (type=standard):   Cebuano (Standard Sort Order)</option>
<option value="chr">chr (type=standard):   Cherokee (Standard Sort Order)</option>
<option value="cs">cs (type=standard):   Czech (Standard Sort Order)</option>
<option value="cy">cy (type=standard):   Welsh (Standard Sort Order)</option>
<option value="da">da (type=standard, caseFirst=upper):   Danish (Standard Sort Order)</option>
<option value="da@collation=search">da-u-co-search (normalization=on):   Danish (General-Purpose Search)</option>
<option value="de@collation=phonebook">de-u-co-phonebk:   German (Phonebook Sort Order)</option>
<option value="de@collation=search">de-u-co-search (normalization=on):   German (General-Purpose Search)</option>
<option value="de_AT@collation=phonebook">de-AT-u-co-phonebk:   Austrian German (Phonebook Sort Order)</option>
<option value="dsb">dsb (type=standard):   Lower Sorbian (Standard Sort Order)</option>
<option value="ee">ee (type=standard):   Ewe (Standard Sort Order)</option>
<option value="el">el (type=standard, normalization=on):   Greek (Standard Sort Order)</option>
<option value="en_US_POSIX">en-US-u-va-posix (type=standard):   American English (Computer, Standard Sort Order)</option>
<option value="eo">eo (type=standard):   Esperanto (Standard Sort Order)</option>
<option value="es">es (type=standard):   Spanish (Standard Sort Order)</option>
<option value="es@collation=search">es-u-co-search (normalization=on):   Spanish (General-Purpose Search)</option>
<option value="es@collation=traditional">es-u-co-trad:   Spanish (Traditional Sort Order)</option>
<option value="et">et (type=standard):   Estonian (Standard Sort Order)</option>
<option value="fa">fa (type=standard, normalization=on):   Persian (Standard Sort Order)</option>
<option value="fa_AF">fa-AF (type=standard, normalization=on):   Dari (Standard Sort Order)</option>
<option value="ff_Adlm">ff-Adlm (type=standard):   Fula (Adlam, Standard Sort Order)</option>
<option value="fi">fi (type=standard):   Finnish (Standard Sort Order)</option>
<option value="fi@collation=search">fi-u-co-search (normalization=on):   Finnish (General-Purpose Search)</option>
<option value="fi@collation=traditional">fi-u-co-trad:   Finnish (Traditional Sort Order)</option>
<option value="fil">fil (type=standard):   Filipino (Standard Sort Order)</option>
<option value="fo">fo (type=standard):   Faroese (Standard Sort Order)</option>
<option value="fo@collation=search">fo-u-co-search (normalization=on):   Faroese (General-Purpose Search)</option>
<option value="fr_CA">fr-CA (type=standard, backwards=on):   Canadian French (Standard Sort Order)</option>
<option value="fy">fy (type=standard):   Western Frisian (Standard Sort Order)</option>
<option value="gl">gl (type=standard):   Galician (Standard Sort Order)</option>
<option value="gl@collation=search">gl-u-co-search (normalization=on):   Galician (General-Purpose Search)</option>
<option value="gu">gu (type=standard, normalization=on):   Gujarati (Standard Sort Order)</option>
<option value="ha">ha (type=standard):   Hausa (Standard Sort Order)</option>
<option value="haw">haw (type=standard):   Hawaiian (Standard Sort Order)</option>
<option value="he">he (type=standard, normalization=on):   Hebrew (Standard Sort Order)</option>
<option value="hi">hi (type=standard, normalization=on):   Hindi (Standard Sort Order)</option>
<option value="hr">hr (type=standard):   Croatian (Standard Sort Order)</option>
<option value="hr@collation=search">hr-u-co-search (normalization=on):   Croatian (General-Purpose Search)</option>
<option value="hsb">hsb (type=standard):   Upper Sorbian (Standard Sort Order)</option>
<option value="hu">hu (type=standard):   Hungarian (Standard Sort Order)</option>
<option value="hy">hy (type=standard):   Armenian (Standard Sort Order)</option>
<option value="ig">ig (type=standard, normalization=on):   Igbo (Standard Sort Order)</option>
<option value="is">is (type=standard):   Icelandic (Standard Sort Order)</option>
<option value="is@collation=search">is-u-co-search (normalization=on):   Icelandic (General-Purpose Search)</option>
<option value="ja">ja (type=standard):   Japanese (Standard Sort Order)</option>
<option value="ja@collation=unihan">ja-u-co-unihan:   Japanese (Radical-Stroke Sort Order)</option>
<option value="ka">ka (type=standard):   Georgian (Standard Sort Order)</option>
<option value="kk">kk (type=standard):   Kazakh (Standard Sort Order)</option>
<option value="kl">kl (type=standard):   Kalaallisut (Standard Sort Order)</option>
<option value="kl@collation=search">kl-u-co-search (normalization=on):   Kalaallisut (General-Purpose Search)</option>
<option value="km">km (type=standard, normalization=on):   Khmer (Standard Sort Order)</option>
<option value="kn">kn (type=standard, normalization=on):   Kannada (Standard Sort Order)</option>
<option value="kn@collation=traditional">kn-u-co-trad (normalization=on):   Kannada (Traditional Sort Order)</option>
<option value="ko">ko (type=standard):   Korean (Standard Sort Order)</option>
<option value="ko@collation=search">ko-u-co-search (normalization=on):   Korean (General-Purpose Search)</option>
<option value="ko@collation=searchjl">ko-u-co-searchjl (normalization=on):   Korean (Search By Hangul Initial Consonant)</option>
<option value="ko@collation=unihan">ko-u-co-unihan:   Korean (Radical-Stroke Sort Order)</option>
<option value="kok">kok (type=standard, normalization=on):   Konkani (Standard Sort Order)</option>
<option value="ku">ku (type=standard):   Kurdish (Standard Sort Order)</option>
<option value="ky">ky (type=standard):   Kyrgyz (Standard Sort Order)</option>
<option value="lkt">lkt (type=standard):   Lakota (Standard Sort Order)</option>
<option value="ln">ln (type=standard):   Lingala (Standard Sort Order)</option>
<option value="ln@collation=phonetic">ln-u-co-phonetic:   Lingala (Phonetic Sort Order)</option>
<option value="lo">lo (type=standard):   Lao (Standard Sort Order)</option>
<option value="lt">lt (type=standard):   Lithuanian (Standard Sort Order)</option>
<option value="lv">lv (type=standard):   Latvian (Standard Sort Order)</option>
<option value="mk">mk (type=standard):   Macedonian (Standard Sort Order)</option>
<option value="ml">ml (type=standard):   Malayalam (Standard Sort Order)</option>
<option value="mn">mn (type=standard):   Mongolian (Standard Sort Order)</option>
<option value="mr">mr (type=standard, normalization=on):   Marathi (Standard Sort Order)</option>
<option value="mt">mt (type=standard, caseFirst=upper):   Maltese (Standard Sort Order)</option>
<option value="my">my (type=standard, normalization=on):   Burmese (Standard Sort Order)</option>
<option value="ne">ne (type=standard):   Nepali (Standard Sort Order)</option>
<option value="no">no (type=standard):   Norwegian (Standard Sort Order)</option>
<option value="no@collation=search">no-u-co-search (normalization=on):   Norwegian (General-Purpose Search)</option>
<option value="nso">nso (type=standard):   Northern Sotho (Standard Sort Order)</option>
<option value="om">om (type=standard):   Oromo (Standard Sort Order)</option>
<option value="or">or (type=standard, normalization=on):   Odia (Standard Sort Order)</option>
<option value="pa">pa (type=standard, normalization=on):   Punjabi (Standard Sort Order)</option>
<option value="pl">pl (type=standard):   Polish (Standard Sort Order)</option>
<option value="ps">ps (type=standard, normalization=on):   Pashto (Standard Sort Order)</option>
<option value="ro">ro (type=standard):   Romanian (Standard Sort Order)</option>
<option value="ru">ru (type=standard):   Russian (Standard Sort Order)</option>
<option value="se">se (type=standard):   Northern Sami (Standard Sort Order)</option>
<option value="se@collation=search">se-u-co-search (normalization=on):   Northern Sami (General-Purpose Search)</option>
<option value="si">si (type=standard, normalization=on):   Sinhala (Standard Sort Order)</option>
<option value="si@collation=dictionary">si-u-co-dict (normalization=on):   Sinhala (Dictionary Sort Order)</option>
<option value="sk">sk (type=standard):   Slovak (Standard Sort Order)</option>
<option value="sk@collation=search">sk-u-co-search (normalization=on):   Slovak (General-Purpose Search)</option>
<option value="sl">sl (type=standard):   Slovenian (Standard Sort Order)</option>
<option value="smn">smn (type=standard):   Inari Sami (Standard Sort Order)</option>
<option value="smn@collation=search">smn-u-co-search (normalization=on):   Inari Sami (General-Purpose Search)</option>
<option value="sq">sq (type=standard):   Albanian (Standard Sort Order)</option>
<option value="sr">sr (type=standard):   Serbian (Standard Sort Order)</option>
<option value="sr_Latn">sr-Latn (type=standard):   Serbian (Latin, Standard Sort Order)</option>
<option value="sr_Latn@collation=search">sr-Latn-u-co-search (normalization=on):   Serbian (Latin, General-Purpose Search)</option>
<option value="sv">sv (type=standard):   Swedish (Standard Sort Order)</option>
<option value="sv@collation=search">sv-u-co-search (normalization=on):   Swedish (General-Purpose Search)</option>
<option value="sv@collation=traditional">sv-u-co-trad:   Swedish (Traditional Sort Order)</option>
<option value="ta">ta (type=standard, normalization=on):   Tamil (Standard Sort Order)</option>
<option value="te">te (type=standard, normalization=on):   Telugu (Standard Sort Order)</option>
<option value="th">th (type=standard, alternate=shifted, normalization=on):   Thai (Standard Sort Order)</option>
<option value="tk">tk (type=standard):   Turkmen (Standard Sort Order)</option>
<option value="tn">tn (type=standard):   Tswana (Standard Sort Order)</option>
<option value="to">to (type=standard):   Tongan (Standard Sort Order)</option>
<option value="tr">tr (type=standard):   Turkish (Standard Sort Order)</option>
<option value="tr@collation=search">tr-u-co-search (normalization=on):   Turkish (General-Purpose Search)</option>
<option value="ug">ug (type=standard):   Uyghur (Standard Sort Order)</option>
<option value="uk">uk (type=standard):   Ukrainian (Standard Sort Order)</option>
<option value="ur">ur (type=standard):   Urdu (Standard Sort Order)</option>
<option value="uz">uz (type=standard):   Uzbek (Standard Sort Order)</option>
<option value="vi">vi (type=standard, normalization=on):   Vietnamese (Standard Sort Order)</option>
<option value="vi@collation=traditional">vi-u-co-trad (normalization=on):   Vietnamese (Traditional Sort Order)</option>
<option value="wo">wo (type=standard, normalization=on):   Wolof (Standard Sort Order)</option>
<option value="yi">yi (type=standard, normalization=on):   Yiddish (Standard Sort Order)</option>
<option value="yo">yo (type=standard, normalization=on):   Yoruba (Standard Sort Order)</option>
<option value="zh">zh (type=pinyin):   Chinese (Pinyin Sort Order)</option>
<option value="zh@collation=stroke">zh-u-co-stroke:   Chinese (Stroke Sort Order)</option>
<option value="zh@collation=unihan">zh-u-co-unihan:   Chinese (Radical-Stroke Sort Order)</option>
<option value="zh@collation=zhuyin">zh-u-co-zhuyin:   Chinese (Zhuyin Sort Order)</option>
<!-- end output from webdemo/collation/available --></select><br>
<!-- TODO: Maybe collapsible/growable rules textarea? -->
Append rules: (For examples see the
<a href="https://github.com/unicode-org/cldr/tree/main/common/collation">CLDR tailoring data</a>)<br>
<textarea name="rules" rows="3" cols="60"></textarea><br>
</div><!-- intro -->
<div id="settings">
<b>Settings</b> (see LDML <a href="https://www.unicode.org/reports/tr35/tr35-collation.html#Collation_Settings">Table</a> /
<a href="https://www.unicode.org/reports/tr35/tr35-collation.html#Common_Settings">Common combinations</a>)<br>
<!-- TODO: Maybe make the settings collapsible? -->
<!-- TODO: convenience buttons that set "ignore accents" and other common combinations,
see https://unicode.org/repos/cldr/trunk/specs/ldml/tr35-collation.html#Common_Settings -->
<table class="settings">
<tr><th>normalization:</th><td>
<input type="radio" name="kk" value="?" <%= "?".equals(kk) ? "checked" : "" %>>default
<input type="radio" name="kk" value="P" <%= "P".equals(kk) ? "checked" : "" %>><span class="default">off</span>
<input type="radio" name="kk" value="Q" <%= "Q".equals(kk) ? "checked" : "" %>>on</td></tr>
<tr><th>numeric:</th><td>
<input type="radio" name="kn" value="?" <%= "?".equals(kn) ? "checked" : "" %>>default
<input type="radio" name="kn" value="P" <%= "P".equals(kn) ? "checked" : "" %>><span class="default">off</span>
<input type="radio" name="kn" value="Q" <%= "Q".equals(kn) ? "checked" : "" %>>on</td></tr>
<tr><th>strength:</th><td>
<input type="radio" name="ks" value="?" <%= "?".equals(ks) ? "checked" : "" %>>default
<input type="radio" name="ks" value="@" <%= "@".equals(ks) ? "checked" : "" %>>primary
<input type="radio" name="ks" value="A" <%= "A".equals(ks) ? "checked" : "" %>>secondary<br>
        <input type="radio" name="ks" value="B" <%= "B".equals(ks) ? "checked" : "" %>><span class="default">tertiary</span>
<input type="radio" name="ks" value="C" <%= "C".equals(ks) ? "checked" : "" %>>quaternary
<input type="radio" name="ks" value="O" <%= "O".equals(ks) ? "checked" : "" %>>identical</td></tr>
<tr><th>backwards<br>secondary:</th><td>
<input type="radio" name="kb" value="?" <%= "?".equals(kb) ? "checked" : "" %>>default
<input type="radio" name="kb" value="P" <%= "P".equals(kb) ? "checked" : "" %>><span class="default">off</span>
<input type="radio" name="kb" value="Q" <%= "Q".equals(kb) ? "checked" : "" %>>on</td></tr>
<tr><th>case level:</th><td>
<input type="radio" name="kc" value="?" <%= "?".equals(kc) ? "checked" : "" %>>default
<input type="radio" name="kc" value="P" <%= "P".equals(kc) ? "checked" : "" %>><span class="default">off</span>
<input type="radio" name="kc" value="Q" <%= "Q".equals(kc) ? "checked" : "" %>>on</td></tr>
<tr><th>case first:</th><td>
<input type="radio" name="kf" value="?" <%= "?".equals(kf) ? "checked" : "" %>>default
<input type="radio" name="kf" value="P" <%= "P".equals(kf) ? "checked" : "" %>><span class="default">off</span>
<input type="radio" name="kf" value="X" <%= "X".equals(kf) ? "checked" : "" %>>lower
<input type="radio" name="kf" value="Y" <%= "Y".equals(kf) ? "checked" : "" %>>upper</td></tr>
<tr><th>alternate:</th><td>
<input type="radio" name="ka" value="?" <%= "?".equals(ka) ? "checked" : "" %>>default
<input type="radio" name="ka" value="U" <%= "U".equals(ka) ? "checked" : "" %>><span class="default">non-ignorable</span>
<input type="radio" name="ka" value="T" <%= "T".equals(ka) ? "checked" : "" %>>shifted</td></tr>
<tr><th>max variable:</th><td>
<input type="radio" name="kv" value="?" <%= "?".equals(kv) ? "checked" : "" %>>default
<input type="radio" name="kv" value="@" <%= "@".equals(kv) ? "checked" : "" %>>space
<input type="radio" name="kv" value="A" <%= "A".equals(kv) ? "checked" : "" %>><span class="default">punct</span>
<input type="radio" name="kv" value="B" <%= "B".equals(kv) ? "checked" : "" %>>symbol
<input type="radio" name="kv" value="C" <%= "C".equals(kv) ? "checked" : "" %>>currency</td></tr>
</table>
<!-- TODO: kr=reorder textarea -->
</div><!-- settings -->
<div id="sortaction">
<input type="submit" value="   sort   "> &amp; show
<input type="checkbox" name="ds" value="1" <%= "1".equals(ds) ? "checked" : "" %>>diff strengths
<input type="checkbox" name="nr" value="1" <%= "1".equals(nr) ? "checked" : "" %>>input line numbers
<input type="checkbox" name="sk" value="1" <%= "1".equals(sk) ? "checked" : "" %>>sort keys
<input type="checkbox" name="ce" value="1" <%= "1".equals(ce) ? "checked" : "" %>>raw collation elements
</div><!-- sortaction -->
<!-- TODO: Maybe buttons to make the following sections taller, and the input wider? -->
<div id="inputsection">
<p><b>Input</b></p>
<!-- TODO: use full width of the #inputsection -->
<textarea name="input" rows="32" cols="20">
ｶ
ヵ
abc
ab\uFFFEc
ab©
𝒶bc
𝕒bc
ガ
が
abç
äbc
カ
か
Abc
abC
File-3
file-12
filé-110
</textarea>
<p>Escape syntax: \uHHHH or \U00HHHHHH.
(See <a href="https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/classicu_1_1UnicodeString.html">UnicodeString</a>::unescape() documentation.)</p>
</div><!-- inputsection -->
<!-- TODO: Add a little margin between the inputsection and outputsection. -->
<div id="outputsection">
<p><b>Output</b> (<a href="#legend">Legend</a>)</p>
<!-- TODO: match alignment and height of the #inputsection -->
<div name="output" width="100%" height="100em"><%= output %></div><br>

<p><a name="legend" href="#legend">Legend</a></p>
<p>Difference strengths: = equal &lt;1 primary &lt;2 secondary
&lt;c case level &lt;3 tertiary &lt;4 quaternary &lt;i identical level</p>
<p>Sort keys: , = 01 level separator   . = 00 terminator</p>
<p>CEs (Collation Elements): [] for completely ignorable or
[primary,secondary,case+tertiary,optional quaternary]<br>
case: _ = uncased/lowercase   m = mixed case   u = uppercase<br>
  q1/q2/q3 = quaternary weight</p>
</div><!-- outputsection -->
</form>

</body>
</html>
