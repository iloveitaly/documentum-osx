//
//  NSString_AMAdditions.h
//  MausX
//
//  Created by Andreas on Mon Oct 20 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//
//	2005-12-15	Andreas Mayer
//	- added -validStringFromString:
//	- added -stringByEscapingEntities and -stringByEscapingEntities:
//	2006-07-20	Andreas Mayer
//	- added -numericCompare:
//	2006-11-18	Andreas Mayer
//	- added -stringByTrimmingWhitespace


#import <Foundation/Foundation.h>

extern NSString *AMStringFromRect(NSRect rect);

extern NSRect AMRectFromString(NSString *string);


@interface NSString (AMAdditions)

+ (NSString *)randomStringOfLength:(int)length withCharacters:(NSString *)characters;

+ (NSString *)uniqueString;

+ (NSString *)validStringFromString:(NSString *)string;
// returns string if string is not nil, @"" otherwise

- (BOOL)isEmptyString;

- (NSString *)lastCharacter;

- (NSString *)initialCharacters;

- (NSArray *)componentsSeparatedByLineDelimiter;

- (unsigned long)unsignedLongValue;

- (NSString *)lastKeyComponent;

- (BOOL)boolValue;

- (NSString *)stringWithFirst:(unsigned int)number componentsSeparatedByString:(NSString *)separator;

- (NSString *)stringWithFirst:(unsigned int)number componentsSeparatedByString:(NSString *)separator ellipsisString:(NSString *)ellipsisString;

- (NSString *)stringByRemovingHTMLUsingDelimiter:(NSString *)delimiter;

- (NSString *)stringWithFirstURLComponent;

- (NSString *)stringByEscapingEntities;

- (NSString *)stringByEscapingEntities:(NSDictionary *)entities;

- (NSString *)stringByUnescapingEntities;

- (NSString *)stringByUnescapingEntities:(NSDictionary *)entities;

- (NSString *)stringByTrimmingWhitespace;

- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)characterSet withString:(NSString *)string;

- (NSComparisonResult)numericCompare:(NSString *)string;


@end
