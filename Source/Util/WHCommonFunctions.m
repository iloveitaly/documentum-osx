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

NSInteger lengthSort(id ob1, id ob2, void *context) {
	return [[[ob1 name] length] compare:[[ob2 name] length]];
}
