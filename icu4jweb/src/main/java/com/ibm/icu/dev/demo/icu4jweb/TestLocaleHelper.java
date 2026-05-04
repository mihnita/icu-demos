// Copyright (c) 2008-2026 Unicode, Inc. and others. All Rights Reserved.
package com.ibm.icu.dev.demo.icu4jweb;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public final class TestLocaleHelper {

    private static final String[] INPUT_LOCALES = {
        "en", "en_US", "en_US_POSIX", "en_Latn", "en_Latn_US", "zh_CN",
        "zh_CN_Beijing", "zh_Hans_CN", "zh_Hant_CN", "zh_Hant", "pa",
        "pa_IN", "pa_PK", "no", "nb", "no_NO", "nb_NO", "nn_NO", "no_NO_NY",
        "en_US__@x=new-user", "ja_JP_JP", "ja_JP_JP_@currency=JPY",
        "ja_JP_JP_@calendar=gregorian"
    };

    private static final String[][] CANDIDATE_LOCALES = {
        {"en"},
        {"en_US", "en"},
        {"en_US_POSIX", "en_US", "en"},
        {"en_Latn", "en"},
        {"en_Latn_US", "en_Latn", "en_US", "en"},
        {"zh_CN", "zh_Hans_CN", "zh_Hans", "zh"},
        {"zh_CN_Beijing", "zh_Hans_CN_Beijing", "zh_Hans_CN", "zh_Hans", "zh_CN", "zh"},
        {"zh_Hans_CN", "zh_Hans", "zh_CN", "zh"},
        {"zh_Hant_CN", "zh_Hant", "zh_CN", "zh"},
        {"zh_Hant", "zh_Hant_TW", "zh_TW", "zh"},
        {"pa", "pa_Guru"},
        {"pa_IN", "pa_Guru_IN", "pa_Guru", "pa"},
        {"pa_PK", "pa_Arab_PK", "pa_Arab", "pa"},
        {"no", "nb"},
        {"nb", "no"},
        {"no_NO", "nb_NO", "nb", "no"},
        {"nb_NO", "nb", "no_NO", "no"},
        {"nn_NO", "nn", "no_NO", "no"},
        {"no_NO_NY", "nn_NO_NY", "nn_NO", "nn", "no_NO", "no"},
        {"en_US", "en"},
        {"ja_JP_JP", "ja_JP", "ja"},
        {"ja_JP_JP", "ja_JP", "ja"},
        {"ja_JP_JP", "ja_JP", "ja"}
    };

    private static final String[] COMPATIBILITY_KEY_FORM_A = {
        "ja_JP_JP", "th_TH_TH"
    };

    private static final String[] COMPATIBILITY_KEY_FORM_B = {
        "_@calendar=japanese", "_@digit=Thai"
    };

    private static final String[] LOCALE_MAPPING_FORM_A = {
        "no", "zh_CN", "zh_SG", "zh_HK", "zh_TW"
    };

    private static final String[] LOCALE_MAPPING_FORM_B = {
        "nn", "zh_Hans_CN", "zh_Hans_SG", "zh_Hant_HK", "zh_Hant_TW"
    };

    private static final String[] LANGUAGE_MAPPING_FORM_A = {
        "zh_Hans", "zh_Hant"
    };

    private static final String[] LANGUAGE_MAPPING_FORM_B = {
        "zh_Hans_CN", "zh_Hant_TW"
    };

    private static final String[] SCRIPT_MAPPING_FORM_A = {
        "pa_PK", "pa", "uz_AF", "uz"
    };

    private static final String[] SCRIPT_MAPPING_FORM_B = {
        "pa_Arab_PK", "pa_Guru", "uz_Arab_AF", "uz_Cyrl"
    };

    private static final String[] MACRO_LANGUAGE_FORM_A = {
        "no", "sh"
    };

    private static final String[][] INDIVIDUAL_LANGUAGE_FORM_B = {
        {"nb", "no"}, {"nn", "no"}, {"bs", "sh"}, {"hr", "sh"}, {"sr", "sh"}
    };

    private static final String[] INDIVIDUAL_LANGUAGE_FORM_C = {
        "nb", "sr"
    };

    private static final List<String> INPUT_LIST = new ArrayList<>();
    private static final List<String> FORM_A_LIST = new ArrayList<>();
    private static final List<String> FORM_B_LIST = new ArrayList<>();
    private static final List<String> LOCALE_FORM_A_LIST = new ArrayList<>();
    private static final List<String> LOCALE_FORM_B_LIST = new ArrayList<>();
    private static final List<String> LANGUAGE_MAPPING_FORM_A_LIST = new ArrayList<>();
    private static final List<String> LANGUAGE_MAPPING_FORM_B_LIST = new ArrayList<>();
    private static final List<String> SCRIPT_MAPPING_FORM_A_LIST = new ArrayList<>();
    private static final List<String> SCRIPT_MAPPING_FORM_B_LIST = new ArrayList<>();
    private static final List<String> MACRO_LANGUAGE_FORM_A_LIST = new ArrayList<>();
    private static final Map<String, String> MACRO_LANGUAGE_FORM_A_TABLE = new HashMap<>();

    static {
        for (String s : INPUT_LOCALES) {
            INPUT_LIST.add(s);
        }
        for (String s : COMPATIBILITY_KEY_FORM_A) {
            FORM_A_LIST.add(s);
        }
        for (String s : COMPATIBILITY_KEY_FORM_B) {
            FORM_B_LIST.add(s);
        }
        for (String s : LOCALE_MAPPING_FORM_A) {
            LOCALE_FORM_A_LIST.add(s);
        }
        for (String s : LOCALE_MAPPING_FORM_B) {
            LOCALE_FORM_B_LIST.add(s);
        }
        for (String s : LANGUAGE_MAPPING_FORM_A) {
            LANGUAGE_MAPPING_FORM_A_LIST.add(s);
        }
        for (String s : LANGUAGE_MAPPING_FORM_B) {
            LANGUAGE_MAPPING_FORM_B_LIST.add(s);
        }
        for (String s : SCRIPT_MAPPING_FORM_A) {
            SCRIPT_MAPPING_FORM_A_LIST.add(s);
        }
        for (String s : SCRIPT_MAPPING_FORM_B) {
            SCRIPT_MAPPING_FORM_B_LIST.add(s);
        }
        for (String s : MACRO_LANGUAGE_FORM_A) {
            MACRO_LANGUAGE_FORM_A_LIST.add(s);
        }
        for (String[] mapping : INDIVIDUAL_LANGUAGE_FORM_B) {
            MACRO_LANGUAGE_FORM_A_TABLE.put(mapping[0], mapping[1]);
        }
    }

    private TestLocaleHelper() {
        // Prevent instantiation
    }

    public static class Result {
        public final String[] candidates;
        public final String extension;

        public Result(String[] candidates, String extension) {
            this.candidates = candidates;
            this.extension = extension;
        }
    }

    public static Result getCandidateList(String localeInput) {
        List<String> resultCandidateList = new ArrayList<>();
        String baseLocaleOrg;
        String baseLocaleTemp = null;
        String[] script;
        String extension = null;
        String baseLocale;
        String localeMapping;
        int step = 10;
        int indexOfVariant = 0;
        int indexOfCountry = 0;

        if (localeInput.contains("@")) {
            baseLocaleOrg = baseLocale = localeInput.substring(0, localeInput.indexOf("@") - 1);
            extension = localeInput.substring(localeInput.indexOf("@") + 1);
            while (baseLocale.charAt(baseLocale.length() - 1) == '_') {
                baseLocaleOrg = baseLocale = baseLocale.substring(0, baseLocale.length() - 1);
            }
        } else {
            baseLocaleOrg = baseLocale = localeInput;
            while (baseLocale.charAt(baseLocale.length() - 1) == '_') {
                baseLocaleOrg = baseLocale = baseLocale.substring(0, baseLocale.length() - 1);
            }
        }

        int numberOFUnderscore = baseLocaleOrg.length() - baseLocaleOrg.replaceAll("_", "").length();
        script = baseLocaleOrg.split("_", 4);
        
        resultCandidateList.add(baseLocaleOrg);

        if (FORM_A_LIST.contains(baseLocaleOrg)) {
            String tempExtension = FORM_B_LIST.get(FORM_A_LIST.indexOf(baseLocaleOrg));
            String key = tempExtension.substring(tempExtension.indexOf("@") + 1, tempExtension.indexOf("="));
            if (extension == null) {
                baseLocale += tempExtension;
                extension = tempExtension.substring(2);
            } else {
                if (!extension.contains(key)) {
                    extension = tempExtension + ";" + extension;
                    baseLocale += extension;
                    extension = extension.substring(2);
                }
            }
        }

        if (script.length > 1 && ((LOCALE_FORM_A_LIST.contains(script[0]) && script.length >= 3) 
                || LOCALE_FORM_A_LIST.contains(script[0] + "_" + script[1]))) {
            if (!LOCALE_FORM_A_LIST.contains(localeMapping = baseLocaleOrg.substring(0, 5))) {
                baseLocale = baseLocaleOrg.replaceFirst(script[0], LOCALE_FORM_B_LIST.get(LOCALE_FORM_A_LIST.indexOf(script[0])));
            } else {
                baseLocale = baseLocaleOrg.replaceFirst(localeMapping, LOCALE_FORM_B_LIST.get(LOCALE_FORM_A_LIST.indexOf(localeMapping)));
            }
            step = 9;
        } else if (script.length >= 2 && LANGUAGE_MAPPING_FORM_A_LIST.contains(script[0] + "_" + script[1])) {
            if (script.length >= 3 && script[2] == null) {
                baseLocale = baseLocaleOrg.replaceFirst(baseLocaleOrg.substring(0, 8), LANGUAGE_MAPPING_FORM_B_LIST.get(LANGUAGE_MAPPING_FORM_A_LIST.indexOf(baseLocaleOrg.substring(0, 7))));
            } else if (script.length == 2) {
                baseLocale = baseLocaleOrg.replaceFirst(baseLocale.substring(0, 7), LANGUAGE_MAPPING_FORM_B_LIST.get(LANGUAGE_MAPPING_FORM_A_LIST.indexOf(baseLocaleOrg.substring(0, 7))));
            }
            step = 9;
        } else if ((script.length >= 2 && script[1].length() != 4 && SCRIPT_MAPPING_FORM_A_LIST.contains(script[0])) 
                || SCRIPT_MAPPING_FORM_A_LIST.contains(script[0])) {
            if (script.length > 1 && SCRIPT_MAPPING_FORM_A_LIST.contains(script[0] + "_" + script[1])) {
                baseLocale = baseLocaleOrg.replaceFirst(script[0] + "_" + script[1], SCRIPT_MAPPING_FORM_B_LIST.get(SCRIPT_MAPPING_FORM_A_LIST.indexOf(script[0] + "_" + script[1])));
            } else {
                baseLocale = baseLocaleOrg.replaceFirst(script[0], SCRIPT_MAPPING_FORM_B_LIST.get(SCRIPT_MAPPING_FORM_A_LIST.indexOf(script[0])));
            }
            step = 9;
        } else if (script.length > 0 && MACRO_LANGUAGE_FORM_A_LIST.contains(script[0])) {
            baseLocale = baseLocaleOrg.replaceFirst(script[0], INDIVIDUAL_LANGUAGE_FORM_C[MACRO_LANGUAGE_FORM_A_LIST.indexOf(script[0])]);
            step = 9;
        } else {
            baseLocale = baseLocaleOrg;
        }

        boolean gotCompleteResult = false;
        while (!gotCompleteResult) {
            boolean hasScript = false;
            boolean hasCountry = false;
            switch (step) {
                case 9:
                    resultCandidateList.add(baseLocale);
                case 10:
                    baseLocaleTemp = baseLocale;
                    numberOFUnderscore = baseLocaleTemp.length() - baseLocaleTemp.replaceAll("_", "").length();
                    script = baseLocaleTemp.split("_", 4);
                case 11:
                    resultCandidateList.add(baseLocaleTemp);
                    String candidateList = null;
                    numberOFUnderscore = baseLocaleTemp.length() - baseLocaleTemp.replaceAll("_", "").length();
                    if (numberOFUnderscore >= 2) {
                        if (script[1].length() == 4) {
                            hasScript = true;
                            if (numberOFUnderscore >= 3 && (script[2].length() == 2 || script[2].length() == 3)) {
                                indexOfVariant = baseLocaleTemp.indexOf(script[3]);
                                hasCountry = true;
                                indexOfCountry = baseLocaleTemp.indexOf(script[2]);
                            } else {
                                if (numberOFUnderscore >= 3) {
                                    indexOfVariant = baseLocaleTemp.indexOf(script[3]);
                                } else {
                                    indexOfVariant = 0;
                                }
                            }
                        } else if (numberOFUnderscore >= 3 && script[1].equals("") 
                                && (script[2].length() == 2 || script[2].length() == 3)) {
                            hasScript = true;
                        } else {
                            if (script[1].length() == 2 || script[1].length() == 3) {
                                hasCountry = true;
                                indexOfCountry = baseLocaleTemp.indexOf(script[1]);
                            }
                            indexOfVariant = baseLocaleTemp.indexOf(script[2]);
                        }
                        if (indexOfVariant != 0) {
                            String variantCandidateList = baseLocaleTemp.substring(indexOfVariant);
                            while (variantCandidateList.length() != 0) {
                                if (variantCandidateList.contains("_")) {
                                    variantCandidateList = variantCandidateList.substring(0, variantCandidateList.lastIndexOf("_"));
                                    candidateList = baseLocaleTemp.replaceAll(baseLocaleTemp.substring(indexOfVariant), variantCandidateList);
                                } else {
                                    candidateList = baseLocaleTemp.substring(0, baseLocaleTemp.lastIndexOf("_"));
                                    while (candidateList.charAt(candidateList.length() - 1) == '_') {
                                        candidateList = candidateList.substring(0, candidateList.length() - 1);
                                    }
                                    variantCandidateList = "";
                                }
                                resultCandidateList.add(candidateList);
                            }
                        }
                    }

                    if (script.length > 1 && script[1].length() == 4) {
                        hasScript = true;
                        if (script.length > 2 && (script[2].length() == 2 || script[2].length() == 3)) {
                            hasCountry = true;
                            indexOfCountry = baseLocaleTemp.indexOf(script[2]);
                        }
                    } else {
                        if (script.length > 1 && (script[1].length() == 2 || script[1].length() == 3)) {
                            hasCountry = true;
                            indexOfCountry = baseLocaleTemp.indexOf(script[1]);
                        }
                    }

                    if (hasCountry) {
                        candidateList = baseLocaleTemp.substring(0, indexOfCountry - 1);
                        resultCandidateList.add(candidateList);
                    } else {
                        if (!hasScript) {
                            candidateList = baseLocaleTemp.substring(0, 2);
                            resultCandidateList.add(candidateList);
                        }
                    }

                    if (hasScript) {
                        baseLocaleTemp = baseLocale;
                        baseLocaleTemp = baseLocaleTemp.replaceFirst("_" + script[1], "");
                        script = baseLocaleTemp.split("_", 4);
                        step = 11;
                        break;
                    }

                    String languageToReplace;
                    if (MACRO_LANGUAGE_FORM_A_TABLE.containsKey(languageToReplace = baseLocaleTemp.substring(0, 2))) {
                        baseLocaleTemp = baseLocale;
                        baseLocaleTemp = baseLocaleTemp.replaceFirst(languageToReplace, MACRO_LANGUAGE_FORM_A_TABLE.get(languageToReplace));
                        script = baseLocaleTemp.split("_", 4);
                        step = 11;
                        break;
                    }

                    if (candidateList == null || (candidateList.length() == 2 && !hasScript) || candidateList.equals("")) {
                        gotCompleteResult = true;
                    }
            }
        }

        List<String> finalCandidates = new ArrayList<>();
        for (String temp : resultCandidateList) {
            if (!finalCandidates.contains(temp)) {
                finalCandidates.add(temp);
            }
        }

        return new Result(finalCandidates.toArray(new String[0]), extension);
    }

    public static String[] getJDKLocales(String locale) {
        List<String> jdkCandidateList = new ArrayList<>();
        String tempLocale = locale;

        if (tempLocale.contains("@")) {
            tempLocale = tempLocale.substring(0, tempLocale.indexOf('@') - 1);
        }

        jdkCandidateList.add(tempLocale);

        while (tempLocale.contains("_")) {
            tempLocale = tempLocale.substring(0, tempLocale.lastIndexOf('_'));
            if (tempLocale.charAt(tempLocale.length() - 1) == '_') {
                while (tempLocale.charAt(tempLocale.length() - 1) == '_') {
                    tempLocale = tempLocale.substring(0, tempLocale.lastIndexOf('_'));
                }
            }
            jdkCandidateList.add(tempLocale);
        }

        return jdkCandidateList.toArray(new String[0]);
    }
}
