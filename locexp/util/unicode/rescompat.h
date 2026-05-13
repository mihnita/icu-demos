/**********************************************************************
*   Copyright (C) 2026, International Business Machines
*   Corporation and others.  All Rights Reserved.
***********************************************************************/

#ifndef RESCOMPAT_H
#define RESCOMPAT_H

#include "unicode/utypes.h"

/*
 * These are non-public APIs, originals declared in icu4c/source/common/uresimp.h
 */

U_CAPI UResourceBundle* U_EXPORT2
ures_findSubResource(const UResourceBundle *resB,
       char* pathToResource,
       UResourceBundle *fillIn, UErrorCode *status);

U_CAPI UEnumeration* U_EXPORT2
ures_getKeywordValues(const char *path, const char *keyword, UErrorCode *status);

#endif
