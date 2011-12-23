/*
 *  CommonFunctions.h
 *  PyHelp
 *
 *  Created by Michael Bianco on 1/4/09.
 *  Copyright 2009 MAB Web Design. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

#define NUMERIC_COMPARE(x, y) (x == y ? NSOrderedSame : (x > y ? NSOrderedDescending : NSOrderedAscending))

NSInteger lengthSort(id ob1, id ob2, void *context);