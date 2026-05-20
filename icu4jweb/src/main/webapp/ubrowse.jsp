<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" 
    import="com.ibm.icu.lang.UCharacter"
    import="com.ibm.icu.lang.UProperty"
    import="com.ibm.icu.lang.UScript"
    import="com.ibm.icu.text.UnicodeSet"
    import="com.ibm.icu.text.UnicodeSetIterator"
    import="com.ibm.icu.text.Normalizer2"
    import="java.lang.reflect.Field"
    import="java.util.List"
    import="java.util.ArrayList"
    import="java.util.Collections"
%>
<%
    request.setCharacterEncoding("utf-8");
    
    // 1. Helper Class for Blocks
    class BlockInfo implements Comparable<BlockInfo> {
        String name;
        int start;
        int end;
        UCharacter.UnicodeBlock block;
        
        BlockInfo(String name, UCharacter.UnicodeBlock block) {
            this.name = name;
            this.block = block;
            try {
                UnicodeSet set = new UnicodeSet("[:Block=" + name + ":]");
                this.start = set.getRangeStart(0);
                this.end = set.getRangeEnd(0);
            } catch (Exception e) {
                this.start = Integer.MAX_VALUE;
                this.end = Integer.MAX_VALUE;
            }
        }
        
        @Override
        public int compareTo(BlockInfo other) {
            return Integer.compare(this.start, other.start);
        }
    }

    // 2. Reflectively load and sort all blocks by range
    List<BlockInfo> sortedBlocks = new ArrayList<>();
    try {
        Field[] fields = UCharacter.UnicodeBlock.class.getFields();
        for (Field f : fields) {
            if (f.getType() == UCharacter.UnicodeBlock.class) {
                UCharacter.UnicodeBlock blockInstance = (UCharacter.UnicodeBlock) f.get(null);
                String fName = f.getName();
                if (blockInstance != null && !fName.equals("INVALID_CODE")) {
                    sortedBlocks.add(new BlockInfo(fName, blockInstance));
                }
            }
        }
        Collections.sort(sortedBlocks);
    } catch (Exception e) {
        // safety fallback
    }

    // 3. Extract Query Parameters
    String scrParam = request.getParameter("scr"); // block name or index
    String typParam = request.getParameter("typ"); // category ID
    String chParam = request.getParameter("ch");   // char hex code point
    String kParam = request.getParameter("k");     // column list view start hex
    String nParam = request.getParameter("n");     // block grid view start hex
    String sParam = request.getParameter("s");     // name search query
    String sxParam = request.getParameter("sx");   // exact name search checkbox
    String usParam = request.getParameter("us");   // custom UnicodeSet string
    String allParam = request.getParameter("all"); // show all indicator
    
    // Map legacy C/C++ parameters to JSP equivalents
    if (chParam == null || chParam.trim().isEmpty()) {
        chParam = request.getParameter("go");
    }
    if ((nParam == null || nParam.trim().isEmpty()) && (request.getParameter("n.x") != null || request.getParameter("gosetn.x") != null)) {
        nParam = chParam;
        chParam = null;
    }
    if ((kParam == null || kParam.trim().isEmpty()) && (request.getParameter("k.x") != null || request.getParameter("gosetk.x") != null)) {
        kParam = chParam;
        chParam = null;
    }
    
    // Sanitize Hex Parameters
    if (chParam != null && !chParam.trim().isEmpty()) {
        try {
            Integer.parseInt(chParam.trim(), 16);
        } catch (NumberFormatException e) {
            chParam = null;
        }
    }
    if (kParam != null && !kParam.trim().isEmpty()) {
        try {
            Integer.parseInt(kParam.trim(), 16);
        } catch (NumberFormatException e) {
            kParam = null;
        }
    }
    if (nParam != null && !nParam.trim().isEmpty()) {
        try {
            Integer.parseInt(nParam.trim(), 16);
        } catch (NumberFormatException e) {
            nParam = null;
        }
    }
    
    String k1Param = request.getParameter("k1");   // highlighted column list view start hex
    if (k1Param != null && !k1Param.trim().isEmpty()) {
        try {
            Integer.parseInt(k1Param.trim(), 16);
        } catch (NumberFormatException e) {
            k1Param = null;
        }
    }
    
    String csParam = request.getParameter("cs");   // name search start hex offset
    int csStart = 0;
    if (csParam != null && !csParam.trim().isEmpty()) {
        try {
            csStart = Integer.parseInt(csParam.trim(), 16);
        } catch (NumberFormatException e) {
            csParam = null;
        }
    }
    
    // Exact name search parameters
    boolean isExactResultView = false;
    int exactCp = -1;
    if (sParam != null && !sParam.trim().isEmpty() && sxParam != null) {
        try {
            exactCp = UCharacter.getCharFromName(sParam.trim());
            if (exactCp != -1) {
                isExactResultView = true;
            }
        } catch (Exception e) {}
    }

    // Determine current view state
    boolean isDetailView = !isExactResultView && (chParam != null && !chParam.trim().isEmpty());
    boolean isGridView = !isExactResultView && (nParam != null && !nParam.trim().isEmpty());
    boolean isListingView = !isExactResultView && (scrParam != null || typParam != null || usParam != null || kParam != null || k1Param != null || (sParam != null && !sParam.trim().isEmpty()));

    // Unified calculation for pagination/listing at top
    int prevOffset = -1;
    int nextOffset = -1;
    boolean showAll = (allParam != null);
    List<Integer> pageCodePoints = new ArrayList<>();
    int setSize = 0;
    String sourceTitle = "";
    String setQueryError = null;
    int baseCodePoint = 0;
    int highlightCp = -1;
    int nextSearchStart = -1;
    boolean isDefaultFilter = true;
    UnicodeSet resultSet = null;
    
    if (isListingView || isGridView) {
        
        // 1. Handle Block Search
        if (scrParam != null && !scrParam.trim().isEmpty()) {
            String matchedBlockName = null;
            try {
                int idx = Integer.parseInt(scrParam.trim());
                if (idx >= 0 && idx < sortedBlocks.size()) {
                    matchedBlockName = sortedBlocks.get(idx).name;
                }
            } catch (NumberFormatException ne) {
                for (BlockInfo bi : sortedBlocks) {
                    if (bi.name.equalsIgnoreCase(scrParam.trim())) {
                        matchedBlockName = bi.name;
                        break;
                    }
                }
            }
            if (matchedBlockName != null) {
                try {
                    resultSet = new UnicodeSet("[:Block=" + matchedBlockName + ":]");
                    sourceTitle = "Block: " + matchedBlockName;
                } catch (Exception e) {}
            }
        }
        
        // 2. Handle Category Search
        if (resultSet == null && typParam != null && !typParam.trim().isEmpty()) {
            try {
                int catId = Integer.parseInt(typParam.trim());
                String catLongName = UCharacter.getPropertyValueName(UProperty.GENERAL_CATEGORY, catId, UProperty.NameChoice.LONG);
                if (catLongName != null) {
                    resultSet = new UnicodeSet("[:General_Category=" + catLongName + ":]");
                    sourceTitle = "General Category: " + catLongName;
                }
            } catch (Exception e) {}
        }
        
        // 3. Handle UnicodeSet direct query
        if (resultSet == null && usParam != null && !usParam.trim().isEmpty()) {
            try {
                resultSet = new UnicodeSet(usParam.trim());
                sourceTitle = "UnicodeSet Query: " + usParam;
            } catch (Exception e) {
                setQueryError = escapeString(e.getMessage());
            }
        }
        
        // 4. Handle Substring Name Search
        if (resultSet == null && sParam != null && !sParam.trim().isEmpty()) {
            resultSet = new UnicodeSet();
            sourceTitle = "Name Search containing: \"" + sParam + "\"";
            int foundCount = 0;
            int cp = csStart;
            for (; cp <= 0x2FFFF; cp++) {
                String name = UCharacter.getName(cp);
                if (name != null && name.toLowerCase().contains(sParam.trim().toLowerCase())) {
                    if ("true".equals(allParam) || foundCount < 15) {
                        resultSet.add(cp);
                        foundCount++;
                    } else {
                        nextSearchStart = cp;
                        break;
                    }
                }
            }
        }
        
        // 5. Default
        if (resultSet == null) {
            resultSet = new UnicodeSet(0, 0x10FFFF);
            sourceTitle = "All Characters";
            isDefaultFilter = true;
        } else {
            isDefaultFilter = false;
        }
        
        if (resultSet != null && !resultSet.isEmpty()) {
            setSize = resultSet.size();
            int viewLimit = showAll ? Math.min(2000, setSize) : 16;
            baseCodePoint = resultSet.isEmpty() ? 0 : resultSet.getRangeStart(0);
            if (k1Param != null && !k1Param.trim().isEmpty()) {
                try {
                    highlightCp = Integer.parseInt(k1Param.trim(), 16);
                    baseCodePoint = (highlightCp / 16) * 16;
                } catch (NumberFormatException e) {}
            } else if (kParam != null && !kParam.trim().isEmpty()) {
                try {
                    baseCodePoint = Integer.parseInt(kParam.trim(), 16);
                } catch (NumberFormatException e) {}
            }
            
            UnicodeSet matchingSuffix = new UnicodeSet(resultSet).retainAll(new UnicodeSet(baseCodePoint, 0x10FFFF));
            UnicodeSetIterator setIter = new UnicodeSetIterator(matchingSuffix);
            while (setIter.next() && pageCodePoints.size() < viewLimit) {
                pageCodePoints.add(setIter.codepoint);
            }
            
            UnicodeSet matchingPrefix = new UnicodeSet();
            if (baseCodePoint > 0) {
                matchingPrefix = new UnicodeSet(resultSet).retainAll(new UnicodeSet(0, baseCodePoint - 1));
            }
            if (!matchingPrefix.isEmpty()) {
                prevOffset = matchingPrefix.isEmpty() ? 0 : matchingPrefix.getRangeStart(0);
                if (matchingPrefix.size() > 16) {
                    List<Integer> prefixList = new ArrayList<>();
                    UnicodeSetIterator prefixIter = new UnicodeSetIterator(matchingPrefix);
                    while (prefixIter.next()) {
                        prefixList.add(prefixIter.codepoint);
                    }
                    prevOffset = prefixList.get(prefixList.size() - 16);
                }
            }
            
            if (matchingSuffix.size() > 16) {
                List<Integer> suffixList = new ArrayList<>();
                UnicodeSetIterator suffixIter = new UnicodeSetIterator(matchingSuffix);
                while (suffixIter.next() && suffixList.size() < 17) {
                    suffixList.add(suffixIter.codepoint);
                }
                nextOffset = suffixList.get(16);
            }
        }
    }
    
    // Populate valid General Category IDs at page level
    List<Integer> validCatIds = new ArrayList<>();
    for (int j = 0; j < 40; j++) {
        try {
            String catName = UCharacter.getPropertyValueName(UProperty.GENERAL_CATEGORY, j, UProperty.NameChoice.LONG);
            if (catName != null) {
                validCatIds.add(j);
            }
        } catch (IllegalArgumentException e) {}
    }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ICU4J Unicode Browser</title>
    <%@ include file="demohead.jsf" %>
    <style>
        /* Custom styles for ubrowse page */
        table.ub_nav {
            border: 1px solid #ccc;
            background-color: #f9f9f9;
            padding: 5px;
            margin-bottom: 15px;
            width: 100%;
        }
        table.blocks_table, table.cats_table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
        }
        table.blocks_table td, table.cats_table td {
            padding: 4px 8px;
            border: 1px solid #e0e0e0;
            font-size: 9pt;
        }
        table.blocks_table tr:nth-child(even), table.cats_table tr:nth-child(even) {
            background-color: #f7f7f7;
        }
        h3.section_title {
            background-color: #006699;
            color: white;
            padding: 4px 8px;
            margin-top: 15px;
            margin-bottom: 5px;
            font-size: 10pt;
        }
        table.column_table, table.grid_table, table.detail_table {
            border-collapse: collapse;
            margin-top: 10px;
            width: 100%;
        }
        table.column_table th, table.column_table td, table.detail_table th, table.detail_table td {
            border: 1px solid #ccc;
            padding: 5px 8px;
            text-align: left;
        }
        table.column_table th, table.detail_table th {
            background-color: #eee;
        }
        table.grid_table {
            border: 2px solid #000;
            border-collapse: collapse;
            width: auto;
        }
        table.grid_table td {
            border: 1px solid #ccc;
            width: 30px;
            height: 30px;
            text-align: center;
            font-size: 14pt;
            vertical-align: middle;
            background-color: #fff;
        }
        table.grid_table td.header_cell {
            background-color: #ddd;
            font-weight: bold;
            font-size: 9pt;
            width: 35px;
        }
        table.grid_table td a {
            text-decoration: none;
            color: #006699;
            display: block;
            width: 100%;
            height: 100%;
            line-height: 30px;
        }
        table.grid_table td a:hover {
            background-color: #e0f0ff;
        }
        .large_glyph_box {
            font-size: 72pt;
            border: 2px solid #ccc;
            padding: 15px;
            width: 120px;
            height: 120px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f9f9f9;
            margin-right: 20px;
            float: left;
        }
        .detail_summary {
            overflow: hidden;
            margin-bottom: 20px;
        }
        .search_form_box {
            border: 1px dashed #999;
            padding: 10px;
            background-color: #fcfcfc;
            margin-bottom: 15px;
        }
        .search_form_box td {
            padding: 3px;
        }
        .unassigned_cell {
            background-color: #888888 !important;
        }
        .pink_cell {
            background-color: #ffdddd !important;
        }
    </style>
</head>
<body>
    <%@ include file="demolist.jsf" %>
    
    <!-- A. Welcome / Search Navbar at Top -->
    <form action="<%= request.getContextPath() + request.getServletPath() %>" method="get">
        <table class="ub_nav" border="0">
            <tr>
                <td>
                    <label for="go">Go: </label>
                    <input id="go" type="text" size="8" name="ch" value="<%= isDetailView ? escapeString(chParam) : (isGridView ? escapeString(nParam) : (k1Param != null ? escapeString(k1Param) : (kParam != null ? escapeString(kParam) : ""))) %>" />
                    <input type="submit" value="Char Properties" />
                    
                    <%
                        // Generate Column (k) and Block (n) modes URL parameters
                        String baseQuery = "";
                        if (scrParam != null) baseQuery += "&scr=" + escapeString(scrParam);
                        if (typParam != null) baseQuery += "&typ=" + escapeString(typParam);
                        if (usParam != null) baseQuery += "&us=" + escapeString(usParam);
                        if (sParam != null) baseQuery += "&s=" + escapeString(sParam);
                        if (csParam != null) baseQuery += "&cs=" + escapeString(csParam);
                        
                        String currentHex = "0000";
                        if (isDetailView) currentHex = chParam;
                        else if (isGridView) currentHex = nParam;
                        else if (k1Param != null) currentHex = k1Param;
                        else if (kParam != null) currentHex = kParam;
                    %>
                    |
                    <a href="?k=<%= currentHex + baseQuery %>">Column View</a> |
                    <a href="?n=<%= currentHex + baseQuery %>">Block Grid View</a>
                    <% if (isListingView) { %>
                        |
                        <% if (prevOffset != -1 && !showAll) { %>
                            <a href="?k=<%= Integer.toHexString(prevOffset).toUpperCase() + baseQuery %>">prev</a>
                        <% } else { %>
                            <span style="color: #999;">prev</span>
                        <% } %>
                        <% if (nextOffset != -1 && !showAll) { %>
                            <a href="?k=<%= Integer.toHexString(nextOffset).toUpperCase() + baseQuery %>">next</a>
                        <% } else { %>
                            <span style="color: #999;">next</span>
                        <% } %>
                    <% } else if (isGridView) { %>
                        <%
                            int baseGrid = 0;
                            try { baseGrid = Integer.parseInt(nParam.trim(), 16); } catch(Exception e){}
                            baseGrid = (baseGrid / 256) * 256;
                            String prevHex = Integer.toHexString(Math.max(0, baseGrid - 256)).toUpperCase();
                            String nextHex = Integer.toHexString(Math.min(0x10FFFF, baseGrid + 256)).toUpperCase();
                        %>
                        |
                        <a href="?n=<%= prevHex + baseQuery %>">prev</a>
                        <a href="?n=<%= nextHex + baseQuery %>">next</a>
                    <% } else if (isDetailView) { %>
                        <%
                            int cp = Integer.parseInt(chParam.trim(), 16);
                            String prevHex = Integer.toHexString(Math.max(0, cp - 1)).toUpperCase();
                            String nextHex = Integer.toHexString(Math.min(0x10FFFF, cp + 1)).toUpperCase();
                        %>
                        |
                        <a href="?ch=<%= prevHex + baseQuery %>">prev</a>
                        <a href="?ch=<%= nextHex + baseQuery %>">next</a>
                    <% } %>
                </td>
                <td align="right">
                    <label for="set">Set query (UnicodeSet): </label>
                    <input id="set" type="text" name="us" size="35" value="<%= usParam != null ? escapeString(usParam) : "" %>" />
                    <input type="submit" value="Filter" />
                </td>
            </tr>
        </table>
    </form>

    <% if (isDetailView) { %>
        <!-- B. Character Detail View -->
        <%
            int cp = Integer.parseInt(chParam.trim(), 16);
            String charName = UCharacter.getName(cp);
            if (charName == null) charName = "<control or unassigned>";
            String displayGlyph = UCharacter.isBMP(cp) ? String.valueOf((char) cp) : new String(Character.toChars(cp));
            
            // Prev / Next buttons
            String prevHex = Integer.toHexString(Math.max(0, cp - 1)).toUpperCase();
            String nextHex = Integer.toHexString(Math.min(0x10FFFF, cp + 1)).toUpperCase();
        %>
        <h2>Character Detail: U+<%= chParam.toUpperCase() %></h2>
        <div style="margin-bottom: 15px;">
            <a href="?ch=<%= prevHex + baseQuery %>">&lt; Previous Character (U+<%= prevHex %>)</a> |
            <a href="?ch=<%= nextHex + baseQuery %>">Next Character (U+<%= nextHex %>) &gt;</a>
        </div>
        
        <div class="detail_summary">
            <div class="large_glyph_box">
                <%= (UCharacter.getType(cp) != UCharacter.CONTROL && UCharacter.getType(cp) != UCharacter.FORMAT && UCharacter.getType(cp) != UCharacter.UNASSIGNED) ? displayGlyph : "&nbsp;" %>
            </div>
            <table class="column_table" style="width: 75%; margin-top: 0;">
                <tr>
                    <th>Code Point</th>
                    <th>Name</th>
                    <th>Category</th>
                    <th>Block</th>
                    <th>Script</th>
                    <th>Bidi Class</th>
                </tr>
                <tr>
                    <td><b>U+<%= Integer.toHexString(cp).toUpperCase() %></b></td>
                    <td><%= charName %></td>
                    <td><a href="?typ=<%= UCharacter.getType(cp) %>"><%= UCharacter.getPropertyValueName(UProperty.GENERAL_CATEGORY, UCharacter.getType(cp), UProperty.NameChoice.LONG) %></a></td>
                    <td>
                        <%
                            UCharacter.UnicodeBlock block = UCharacter.UnicodeBlock.of(cp);
                            String blockName = block != null ? block.toString() : "None";
                        %>
                        <a href="?scr=<%= blockName %>"><%= blockName %></a>
                    </td>
                    <td><%= UScript.getName(UScript.getScript(cp)) %></td>
                    <td><%= UCharacter.getPropertyValueName(UProperty.BIDI_CLASS, UCharacter.getIntPropertyValue(cp, UProperty.BIDI_CLASS), UProperty.NameChoice.LONG) %></td>
                </tr>
            </table>
        </div>
        
        <%
            Normalizer2 nfd = Normalizer2.getNFDInstance();
            String decomp = nfd.getDecomposition(cp);
            if (decomp != null) {
        %>
            <div style="margin-top: 10px; margin-bottom: 15px; padding: 10px; border: 1px dashed #999; background-color: #fdfdfd; font-size: 9.5pt;">
                <b>Canonical Equivalencies:</b>
                <ol style="margin: 5px 0 0 20px; padding: 0; list-style-type: decimal;">
                    <li>
                        <span style="font-size: 12pt; font-family: monospace; margin-right: 10px;"><%= decomp %></span>
                        <%
                            int len = decomp.length();
                            boolean first = true;
                            for (int offset = 0; offset < len; ) {
                                int decompCp = decomp.codePointAt(offset);
                                String decompCpHex = Integer.toHexString(decompCp).toUpperCase();
                                String decompCpName = UCharacter.getName(decompCp);
                                if (!first) {
                                    out.print(", ");
                                }
                                first = false;
                        %>
                                <a href="?ch=<%= decompCpHex %>">U+<%= decompCpHex %></a> <%= decompCpName %>
                        <%
                                offset += Character.charCount(decompCp);
                            }
                        %>
                    </li>
                </ol>
            </div>
        <% } %>
        
        <h3 class="section_title">Detailed ICU4J Character Properties</h3>
        <table class="detail_table">
            <tr>
                <th>Property ID / Type</th>
                <th>Property Name</th>
                <th>Long Value Name</th>
                <th>Value ID / Raw Value</th>
            </tr>
            <!-- 1. Version -->
            <tr>
                <td>Derived Age</td>
                <td>Derived Age</td>
                <td><%= UCharacter.getAge(cp) %></td>
                <td>-</td>
            </tr>
            <!-- 2. Binary Properties -->
            <%
                for (int prop = UProperty.BINARY_START; prop < UProperty.BINARY_LIMIT; prop++) {
                    try {
                        String propName = UCharacter.getPropertyName(prop, UProperty.NameChoice.LONG);
                        if (propName != null) {
                            boolean hasProp = UCharacter.hasBinaryProperty(cp, prop);
            %>
                            <tr>
                                <td>binary (<%= prop %>)</td>
                                <td><%= propName %></td>
                                <td><b><%= hasProp ? "Yes" : "No" %></b></td>
                                <td><%= hasProp ? "1" : "0" %></td>
                            </tr>
            <%
                        }
                    } catch (IllegalArgumentException e) {
                        // Ignore unmapped property IDs in this version of ICU
                    }
                }
            %>
            <!-- 3. Enumerated/Integer Properties -->
            <%
                for (int prop = UProperty.INT_START; prop < UProperty.INT_LIMIT; prop++) {
                    try {
                        String propName = UCharacter.getPropertyName(prop, UProperty.NameChoice.LONG);
                        if (propName != null) {
                            int rawVal = UCharacter.getIntPropertyValue(cp, prop);
                            String valName = UCharacter.getPropertyValueName(prop, rawVal, UProperty.NameChoice.LONG);
            %>
                            <tr>
                                <td>integer (<%= prop %>)</td>
                                <td><%= propName %></td>
                                <td><b><%= valName != null ? valName : "" %></b></td>
                                <td><%= rawVal %></td>
                            </tr>
            <%
                        }
                    } catch (IllegalArgumentException e) {
                        // Ignore unmapped property IDs in this version of ICU
                    }
                }
            %>
        </table>

    <% } else if (isGridView && !isDefaultFilter) { %>
        <!-- H. Filtered Dense Grid View (srch_res2) -->
        <h2><%= sourceTitle %> Grid (<%= setSize %> characters found)</h2>
        <table class="dense_grid_table" style="border-collapse: collapse; border: 1px solid #ccc; margin-top: 10px;">
            <%
                int denseCols = 10;
                int count = 0;
                UnicodeSetIterator setIter = new UnicodeSetIterator(resultSet);
                while (setIter.next()) {
                    int denseCp = setIter.codepoint;
                    String denseGlyph = UCharacter.isBMP(denseCp) ? String.valueOf((char) denseCp) : new String(Character.toChars(denseCp));
                    String denseCharName = UCharacter.getName(denseCp);
                    if (denseCharName == null) denseCharName = "";
                    int catType = UCharacter.getType(denseCp);
                    boolean isControlOrFormat = (catType == UCharacter.CONTROL || catType == UCharacter.FORMAT || catType == UCharacter.UNASSIGNED);
                    
                    if (count % denseCols == 0) {
                        if (count > 0) out.print("</tr>");
                        out.print("<tr>");
                    }
            %>
                    <td class="<%= catType == UCharacter.UNASSIGNED ? "unassigned_cell" : ((catType == UCharacter.CONTROL || catType == UCharacter.ENCLOSING_MARK) ? "pink_cell" : "") %>" style="border: 1px solid #ccc; width: 45px; height: 45px; text-align: center; font-size: 16pt;">
                        <a href="?ch=<%= Integer.toHexString(denseCp).toUpperCase() %>" title="U+<%= String.format("%04X", denseCp) %>: <%= denseCharName %>" style="text-decoration: none; color: #006699; display: block; width: 100%; height: 100%; line-height: 45px;">
                            <%= isControlOrFormat ? "&nbsp;" : denseGlyph %>
                        </a>
                    </td>
            <%
                    count++;
                }
                if (count > 0) {
                    while (count % denseCols != 0) {
                        out.print("<td style='border: 1px solid #ccc;'>&nbsp;</td>");
                        count++;
                    }
                    out.print("</tr>");
                }
            %>
        </table>
        <div style="font-style: italic; margin-top: 5px;">Click any character cell to inspect properties.</div>

    <% } else if (isGridView && isDefaultFilter) { %>
        <!-- C. Block Grid View (16x16) -->
        <%
            int baseGrid = 0;
            if (nParam != null && !nParam.trim().isEmpty()) {
                try {
                    baseGrid = Integer.parseInt(nParam.trim(), 16);
                } catch (NumberFormatException e) {
                    // fallback
                }
            }
            // Round down to 256-character boundary
            baseGrid = (baseGrid / 256) * 256;
            
            String prevHex = Integer.toHexString(Math.max(0, baseGrid - 256)).toUpperCase();
            String nextHex = Integer.toHexString(Math.min(0x10FFFF, baseGrid + 256)).toUpperCase();
        %>
        <h2>Block Grid: U+<%= Integer.toHexString(baseGrid).toUpperCase() %> .. U+<%= Integer.toHexString(baseGrid + 255).toUpperCase() %></h2>
        <div style="margin-bottom: 15px;">
            <a href="?n=<%= prevHex + baseQuery %>">&lt; Previous 256 Characters (U+<%= prevHex %>)</a> |
            <a href="?n=<%= nextHex + baseQuery %>">Next 256 Characters (U+<%= nextHex %>) &gt;</a>
        </div>
        
        <table class="grid_table" summary="Unicode 16x16 Grid">
            <!-- Top Header Row -->
            <tr>
                <td class="header_cell">&nbsp;</td>
                <% for (int col = 0; col < 16; col++) { 
                    int colCp = baseGrid + (col * 16);
                    String colHex = String.format("%04X", colCp);
                %>
                    <td class="header_cell">
                        <b><a href="?k=<%= colHex %>"><tt><%= String.format("%03X", colCp >> 4) %></tt></a></b>
                    </td>
                <% } %>
            </tr>
            <!-- 16 rows -->
            <% for (int row = 0; row < 16; row++) { %>
                <tr>
                    <td class="header_cell">
                        <b><tt><%= Integer.toHexString(row).toUpperCase() %></tt></b>
                    </td>
                    <% for (int col = 0; col < 16; col++) { 
                        int gridCp = baseGrid + (col * 16) + row;
                        String cellGlyph = UCharacter.isBMP(gridCp) ? String.valueOf((char) gridCp) : new String(Character.toChars(gridCp));
                        String gridCharName = UCharacter.getName(gridCp);
                        if (gridCharName == null) gridCharName = "";
                        int catType = UCharacter.getType(gridCp);
                        boolean isControlOrFormat = (catType == UCharacter.CONTROL || catType == UCharacter.FORMAT || catType == UCharacter.UNASSIGNED);
                    %>
                        <%
                            String gridCellClass = "";
                            if (catType == UCharacter.UNASSIGNED) gridCellClass = "unassigned_cell";
                            else if (catType == UCharacter.CONTROL || catType == UCharacter.ENCLOSING_MARK) gridCellClass = "pink_cell";
                        %>
                        <td class="<%= gridCellClass %>">
                            <a href="?ch=<%= Integer.toHexString(gridCp).toUpperCase() %>" title="U+<%= String.format("%04X", gridCp) %>: <%= gridCharName %>">
                                <%= isControlOrFormat ? "&nbsp;" : cellGlyph %>
                            </a>
                        </td>
                    <% } %>
                </tr>
            <% } %>
        </table>
        <div style="font-style: italic; margin-top: 5px;">Hover over any character cell to see its name and code point. Click a cell to inspect properties.</div>

    <% } else if (isExactResultView) { %>
        <!-- G. Exact Name Search Bullets View -->
        <h1>Searching for '<%= sParam.toUpperCase() %>'...</h1>
        <hr />
        <ul>
            <li>
                <a href="?k1=<%= Integer.toHexString(exactCp).toUpperCase() %>#here"><tt><%= String.format("%04X", exactCp) %></tt> - <%= sParam.toUpperCase() %></a>
            </li>
        </ul>
        <hr />

    <% } else if (isListingView) { %>
        <!-- D. Column Listing View / Unified Search Results -->
        <%
            if (setQueryError != null) {
                out.println("<div class='null'><b>Error parsing UnicodeSet query: " + setQueryError + "</b></div>");
            }
            if (!pageCodePoints.isEmpty()) {
        %>
                <% if (!isDefaultFilter) { %>
                    <h2><%= sourceTitle %> (<%= setSize %> characters found)</h2>
                <% } %>
                
                <div style="margin-bottom: 15px; font-size: 10pt;">
                    <% if (prevOffset != -1 && !showAll) { %>
                        <a href="?k=<%= Integer.toHexString(prevOffset).toUpperCase() + baseQuery %>">&lt; prev page</a>
                    <% } else { %>
                        <span style="color: #999;">&lt; prev page</span>
                    <% } %>
                    |
                    <% if (nextOffset != -1 && !showAll) { %>
                        <a href="?k=<%= Integer.toHexString(nextOffset).toUpperCase() + baseQuery %>">next page &gt;</a>
                    <% } else { %>
                        <span style="color: #999;">next page &gt;</span>
                    <% } %>
                    |
                    <% if (showAll) { %>
                        <a href="?k=<%= Integer.toHexString(baseCodePoint).toUpperCase() + baseQuery %>">Show Paginated View</a>
                    <% } else { %>
                        <a href="?all=true&k=<%= Integer.toHexString(baseCodePoint).toUpperCase() + baseQuery %>">Show All Matches</a>
                    <% } %>
                </div>
                
                <% if (showAll && setSize > 2000) { %>
                    <div class="null" style="font-weight: bold; margin-bottom: 5px;">Showing first 2000 matching characters due to size limits.</div>
                <% } %>

                <table class="column_table" summary="Unicode Character Column Listing">
                    <tr>
                        <th>C</th>
                        <th>N (Hex Name)</th>
                        <th>General Category</th>
                        <th>Script</th>
                        <th># (Numeric Value)</th>
                        <th>BiDi Class</th>
                    </tr>
                    <%
                        for (int listingCp : pageCodePoints) {
                            String lName = UCharacter.getName(listingCp);
                            if (lName == null) lName = "<control or unassigned>";
                            String lGlyph = UCharacter.isBMP(listingCp) ? String.valueOf((char) listingCp) : new String(Character.toChars(listingCp));
                            int catType = UCharacter.getType(listingCp);
                            boolean isControlOrFormat = (catType == UCharacter.CONTROL || catType == UCharacter.FORMAT || catType == UCharacter.UNASSIGNED);
                    %>
                            <%
                                String rowClass = "";
                                if (catType == UCharacter.UNASSIGNED) rowClass = "unassigned_cell";
                                else if (catType == UCharacter.CONTROL || catType == UCharacter.ENCLOSING_MARK || listingCp == highlightCp) rowClass = "pink_cell";
                            %>
                            <tr class="<%= rowClass %>">
                                <td style="font-size: 16pt; text-align: center; width: 40px;">
                                    <% if (listingCp == highlightCp) { %><a name="here"></a><% } %>
                                    <%= isControlOrFormat ? "&nbsp;" : lGlyph %>
                                </td>
                                <td>
                                    <a href="?ch=<%= Integer.toHexString(listingCp).toUpperCase() %>">
                                        U+<%= String.format("%04X", listingCp) %> <%= lName %>
                                    </a>
                                </td>
                                <td><a href="?typ=<%= catType %>"><%= UCharacter.getPropertyValueName(UProperty.GENERAL_CATEGORY, catType, UProperty.NameChoice.LONG) %></a></td>
                                <td><%= UScript.getName(UScript.getScript(listingCp)) %></td>
                                <td>
                                    <%
                                        double numVal = UCharacter.getUnicodeNumericValue(listingCp);
                                        if (numVal == UCharacter.NO_NUMERIC_VALUE) out.print("-");
                                        else out.print(numVal);
                                    %>
                                </td>
                                <td><%= UCharacter.getPropertyValueName(UProperty.BIDI_CLASS, UCharacter.getIntPropertyValue(listingCp, UProperty.BIDI_CLASS), UProperty.NameChoice.LONG) %></td>
                            </tr>
                    <% } %>
                </table>
                <% if (nextSearchStart != -1) { %>
                    <blockquote>
                        <h4>
                            <a href="?s=<%= escapeString(sParam) %>&cs=<%= Integer.toHexString(nextSearchStart).toUpperCase() %>">Continue search for '<%= escapeString(sParam).toUpperCase() %>' from U+<%= Integer.toHexString(nextSearchStart).toUpperCase() %>...</a>
                        </h4>
                    </blockquote>
                <% } %>
        <%
            } else {
        %>
                <h2>No matching characters found</h2>
                <p>No code points matched your query inside the active database.</p>
        <%
            }
        %>

    <% } else { %>
        <!-- E. Welcome View / Full Block & Category Browsing Directory -->
        <h2>Unicode Browser</h2>
        <p>Click on a block range or category below to explore character properties in detail, or use the search forms.</p>
        
        <!-- E.1 Block Browser Directory Grid -->
        <h3 class="section_title">Unicode Blocks</h3>
        <table class="blocks_table" summary="Unicode Blocks Directory">
            <% 
                int cols = 3;
                for (int i = 0; i < sortedBlocks.size(); i += cols) { 
            %>
                <tr>
                    <% for (int c = 0; c < cols; c++) { 
                        int cellIdx = i + c;
                        if (cellIdx < sortedBlocks.size()) {
                            BlockInfo bi = sortedBlocks.get(cellIdx);
                    %>
                            <td>
                                <a href="?scr=<%= bi.name %>&k=<%= Integer.toHexString(bi.start).toUpperCase() %>">
                                    <%= bi.name %>
                                </a>
                                <br/>
                                <span style="color: #666; font-size: 8pt;">U+<%= Integer.toHexString(bi.start).toUpperCase() %> - U+<%= Integer.toHexString(bi.end).toUpperCase() %></span>
                            </td>
                    <% } else { %>
                            <td>&nbsp;</td>
                    <% } } %>
                </tr>
            <% } %>
        </table>

        <!-- E.2 General Categories Browsing Directory -->
        <h3 class="section_title">General Categories</h3>
        <table class="cats_table" summary="General Categories Directory">
            <% 
                int catCols = 3;
                for (int i = 0; i < validCatIds.size(); i += catCols) { 
            %>
                <tr>
                    <% for (int c = 0; c < catCols; c++) { 
                        int cellIdx = i + c;
                        if (cellIdx < validCatIds.size()) {
                            int catId = validCatIds.get(cellIdx);
                            String catName = UCharacter.getPropertyValueName(UProperty.GENERAL_CATEGORY, catId, UProperty.NameChoice.LONG);
                    %>
                            <td>
                                <a href="?typ=<%= catId %>">
                                    <%= catName %>
                                </a>
                            </td>
                    <% } else { %>
                            <td>&nbsp;</td>
                    <% } } %>
                </tr>
            <% } %>
        </table>

    <% } %>

    <hr style="border: 1px solid #ccc; margin-top: 25px; margin-bottom: 15px;" />

    <!-- F. Detailed Search Forms (Always rendered at the bottom) -->
    <h3 class="section_title">Find Characters</h3>
    <div class="search_form_box">
        <table border="0">
            <!-- 1. Find Block Dropdown -->
            <form action="<%= request.getContextPath() + request.getServletPath() %>" method="get">
                <tr>
                    <td><label for="search_block">Block: </label></td>
                    <td>
                        <select id="search_block" name="scr">
                            <% for (BlockInfo bi : sortedBlocks) { %>
                                <option value="<%= bi.name %>"><%= bi.name %></option>
                            <% } %>
                        </select>
                    </td>
                    <td><input type="submit" value="Browse Block" /></td>
                </tr>
            </form>
            <!-- 2. Find Category Dropdown -->
            <form action="<%= request.getContextPath() + request.getServletPath() %>" method="get">
                <tr>
                    <td><label for="search_category">Category: </label></td>
                    <td>
                        <select id="search_category" name="typ">
                            <% for (int catId : validCatIds) { 
                                String catName = UCharacter.getPropertyValueName(UProperty.GENERAL_CATEGORY, catId, UProperty.NameChoice.LONG);
                            %>
                                <option value="<%= catId %>"><%= catName %></option>
                            <% } %>
                        </select>
                    </td>
                    <td><input type="submit" value="Browse Category" /></td>
                </tr>
            </form>
            <!-- 3. Find by Name input -->
            <form action="<%= request.getContextPath() + request.getServletPath() %>" method="get">
                <tr>
                    <td><label for="search_name">Name: </label></td>
                    <td>
                        <input id="search_name" type="text" name="s" size="25" />
                        <input id="search_exact" type="checkbox" name="sx" />
                        <label for="search_exact">Exact?</label>
                    </td>
                    <td><input type="submit" value="Search by Name" /></td>
                </tr>
            </form>
        </table>
    </div>

    <div class="poweredByIcu">
        Unicode Browser based on ICU4J <%= com.ibm.icu.util.VersionInfo.ICU_VERSION %>
    </div>
</body>
</html>
