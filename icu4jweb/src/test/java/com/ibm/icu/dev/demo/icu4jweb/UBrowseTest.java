package com.ibm.icu.dev.demo.icu4jweb;

import org.junit.Test;
import com.ibm.icu.lang.UCharacter;
import com.ibm.icu.lang.UProperty;
import com.ibm.icu.lang.UScript;
import com.ibm.icu.text.UnicodeSet;
import java.lang.reflect.Field;

public class UBrowseTest {
    @Test
    public void testBlocks() throws Exception {
        System.out.println("=================== START ICU4J API TEST ===================");
        
        // 1. Test reflection of UnicodeBlock
        Field[] fields = UCharacter.UnicodeBlock.class.getFields();
        System.out.println("Total UCharacter.UnicodeBlock fields: " + fields.length);
        int blockCount = 0;
        for (Field f : fields) {
            if (f.getType() == UCharacter.UnicodeBlock.class) {
                UCharacter.UnicodeBlock block = (UCharacter.UnicodeBlock) f.get(null);
                String name = f.getName();
                System.out.println("Block Field: " + name + " = " + block.toString());
                blockCount++;
                if (blockCount <= 3) {
                    // Try to query the range of this block
                    try {
                        UnicodeSet set = new UnicodeSet("[:Block=" + name + ":]");
                        System.out.println("  Set size: " + set.size());
                        for (int r = 0; r < set.getRangeCount(); r++) {
                            System.out.println("  Range " + r + ": U+" + Integer.toHexString(set.getRangeStart(r)).toUpperCase() 
                                + " .. U+" + Integer.toHexString(set.getRangeEnd(r)).toUpperCase());
                        }
                    } catch (Exception e) {
                        System.out.println("  Could not query set for block: " + name + " (" + e.getMessage() + ")");
                    }
                }
            }
        }
        
        // 2. Test general categories
        System.out.println("------------------- GENERAL CATEGORIES -------------------");
        for (int i = 0; i < 40; i++) {
            try {
                String catName = UCharacter.getPropertyValueName(UProperty.GENERAL_CATEGORY, i, UProperty.NameChoice.LONG);
                if (catName != null) {
                    System.out.println("Category ID: " + i + " = " + catName);
                    // Query a UnicodeSet for it
                    try {
                        UnicodeSet set = new UnicodeSet("[:General_Category=" + catName + ":]");
                        System.out.println("  Set size: " + set.size());
                    } catch (Exception e) {
                        System.out.println("  Failed for " + catName + ": " + e.getMessage());
                    }
                }
            } catch (IllegalArgumentException e) {
                // Ignore invalid property value
            }
        }

        // 3. Test querying U+0041 properties
        System.out.println("------------------- U+0041 PROPERTIES -------------------");
        int cp = 0x0041;
        System.out.println("Character: " + (char)cp);
        System.out.println("Name: " + UCharacter.getName(cp));
        System.out.println("Block: " + UCharacter.UnicodeBlock.of(cp));
        System.out.println("General Category: " + UCharacter.getPropertyValueName(UProperty.GENERAL_CATEGORY, UCharacter.getType(cp), UProperty.NameChoice.LONG));
        System.out.println("Script: " + UScript.getName(UScript.getScript(cp)));
        System.out.println("Numeric Value: " + UCharacter.getNumericValue(cp));
        System.out.println("Bidi Class: " + UCharacter.getPropertyValueName(UProperty.BIDI_CLASS, UCharacter.getIntPropertyValue(cp, UProperty.BIDI_CLASS), UProperty.NameChoice.LONG));

        // Let's list some binary properties
        System.out.println("Binary Properties:");
        for (int prop = UProperty.BINARY_START; prop < UProperty.BINARY_LIMIT; prop++) {
            try {
                String propName = UCharacter.getPropertyName(prop, UProperty.NameChoice.LONG);
                boolean val = UCharacter.hasBinaryProperty(cp, prop);
                if (val) {
                    System.out.println("  " + propName + " = " + val);
                }
            } catch (IllegalArgumentException e) {
                // Ignore
            }
        }

        System.out.println("=================== END ICU4J API TEST ===================");
    }
}
