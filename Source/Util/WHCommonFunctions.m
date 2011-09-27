/*
 *  CommonFunctions.c
 *  PyHelp
 *
 *  Created by Michael Bianco on 1/4/09.
 *  Copyright 2009 MAB Web Design. All rights reserved.
 *
 */

#include "WHCommonFunctions.h"

// trouble linking to C function from child plugin:
//	http://stackoverflow.com/questions/3212901/symbol-not-found-objc-class-article

int lengthSort(id ob1, id ob2, void *context) {
	int l1 = [[ob1 name] length], l2 = [[ob2 name] length];

	if(l1 < l2) return NSOrderedAscending;
	else if(l1 > l2) return NSOrderedDescending;
	else return NSOrderedSame;
}
