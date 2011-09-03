//
//  NSString_AMAdditions.m
//  MausX
//
//  Created by Andreas on Mon Oct 20 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import "NSString_AMAdditions.h"

NSString *AMStringFromRect(NSRect rect)
{
	return [NSString stringWithFormat:@"%f %f %f %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

NSRect AMRectFromString(NSString *string)
{
	NSRect result;
	NSArray *values = [string componentsSeparatedByString:@" "];
	result = NSMakeRect([[values objectAtIndex:0] floatValue], [[values objectAtIndex:1] floatValue], [[values objectAtIndex:2] floatValue], [[values objectAtIndex:3] floatValue]);
	return result;
}


@implementation NSString (AMAdditions)

+ (NSString *)randomStringOfLength:(int)length withCharacters:(NSString *)characters
{
	NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
	int numberOfCharacters = [characters length];
	NSRange range = NSMakeRange(0, 1);
	// initialite random number generator
	srandom([[NSDate date] timeIntervalSince1970]);
	int i;
	for (i = 0; i<length; i++) {
		range.location = random()%numberOfCharacters;
		[result appendString:[characters substringWithRange:range]];
	}
	return result;
}

+ (NSString *)uniqueString
{
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	[(NSString *)uuidStr autorelease];
	return (NSString *)uuidStr;
}

+ (NSString *)validStringFromString:(NSString *)string
{
	// returns string if string is not nil, @"" otherwise
	return ((string) ? string : @"");
}

- (BOOL)isEmptyString
{
	return [self isEqualToString:@""];
}

- (NSString *)lastCharacter
{
	NSString *result = nil;
	int len;
	if ((len = [self length]) > 0) {
		result = [self substringWithRange:NSMakeRange(len-1, 1)];
	}
	return result;
}

- (NSString *)initialCharacters
{
	NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
	NSScanner *scanner = [NSScanner scannerWithString:self];
	NSString *buffer = [[[NSString alloc] init] autorelease];
	while (![scanner isAtEnd]) {
		// skip non letter characters
		[scanner scanUpToCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:nil];
		[scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&buffer];
		[result appendString:[buffer substringToIndex:1]];
	}
	return result;
}

- (NSArray *)componentsSeparatedByLineDelimiter
{
	NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
	unsigned start;
	unsigned end;
	unsigned next;
	unsigned stringLength;
	NSRange searchRange;
	NSRange lineRange;
	
	stringLength = [self length];
	searchRange = NSMakeRange(0, 0);
	do {
		[self getLineStart:&start end:&next contentsEnd:&end forRange:searchRange];
		lineRange.location =start;
		lineRange.length = end-start;
		[result addObject:[self substringWithRange:lineRange]];
		searchRange.location = next;
	} while (next < stringLength);
	return result;
}

- (unsigned long)unsignedLongValue
{
	long long result = 0;
	NSScanner *scanner = [NSScanner scannerWithString:self];
	if ([scanner scanLongLong:&result]) {
		if ((result < 0) || (result > ((unsigned long)LONG_MAX-(unsigned long)LONG_MIN))) {
			result = 0;
		}
	}
	return result;
}

- (NSString *)lastKeyComponent
{
	NSString *result = self;
	NSRange dotRange = [self rangeOfString:@"." options:NSBackwardsSearch];
	if (dotRange.location != NSNotFound) {
		result = [self substringFromIndex:dotRange.location+1];
	}
	return result;
}

- (BOOL)boolValue
{
	return ([[self uppercaseString] isEqualToString:@"YES"] || ![self isEqualToString:@"0"]);
}

- (NSString *)stringWithFirst:(unsigned int)number componentsSeparatedByString:(NSString *)separator
{
	return [self stringWithFirst:number componentsSeparatedByString:separator ellipsisString:@""];
}

- (NSString *)stringWithFirst:(unsigned int)number componentsSeparatedByString:(NSString *)separator ellipsisString:(NSString *)ellipsisString;
{
	NSString *result = self;
	NSArray *components = [self componentsSeparatedByString:separator];
	if ([components count] > number) {
		NSRange subrange = NSMakeRange(0, number);
		result = [[components subarrayWithRange:subrange] componentsJoinedByString:separator];
		result = [result stringByAppendingString:ellipsisString];
	}
	return result;
}

- (NSString *)stringByRemovingHTMLUsingDelimiter:(NSString *)delimiter
{
	NSString *result = @"";
	NSString *partialString;
	NSScanner *scanner = [NSScanner scannerWithString:self];
	BOOL found;
	do {
		found = [scanner scanUpToString:@"<" intoString:&partialString];
		//int loc = [scanner scanLocation];
		if ([scanner scanUpToString:@">" intoString:nil]) {
			[scanner scanString:@">" intoString:nil];
		}
		//loc = [scanner scanLocation];
		if (found) {
			if (![result isEmptyString] && delimiter) {
				result = [result stringByAppendingString:delimiter];
			}
			result = [result stringByAppendingString:partialString];
		}
	} while (found);
	return result;
}

- (NSString *)stringWithFirstURLComponent
{
	NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
	NSString *schemePart = @"";
	NSString *hostPart = @"";
	NSScanner *scanner = [NSScanner scannerWithString:self];
	if ([scanner scanUpToString:@"://" intoString:&schemePart]) {
		[scanner scanString:@"://" intoString:nil];
		[scanner scanUpToString:@"/" intoString:&hostPart];
	}
	[result appendString:schemePart];
	[result appendString:@"://"];
	[result appendString:hostPart];
	return [[result copy] autorelease];
}

- (NSString *)stringByEscapingEntities
{
	NSString *result;
	CFStringRef escapedStringRef = CFXMLCreateStringByEscapingEntities(NULL, (CFStringRef)self, NULL);
	result = [NSString stringWithString:(NSString *)escapedStringRef];
	CFRelease(escapedStringRef);
	return result;
}

- (NSString *)stringByEscapingEntities:(NSDictionary *)entities
{
	NSString *result;
	CFStringRef escapedStringRef = CFXMLCreateStringByEscapingEntities(NULL, (CFStringRef)self, (CFDictionaryRef)entities);
	result = [NSString stringWithString:(NSString *)escapedStringRef];
	CFRelease(escapedStringRef);
	return result;
}

- (NSString *)stringByUnescapingEntities
{
	NSString *result;
	CFStringRef unescapedStringRef = CFXMLCreateStringByUnescapingEntities(NULL, (CFStringRef)self, NULL);
	result = [NSString stringWithString:(NSString *)unescapedStringRef];
	CFRelease(unescapedStringRef);
	return result;
}

- (NSString *)stringByUnescapingEntities:(NSDictionary *)entities
{
	NSString *result;
	CFStringRef unescapedStringRef = CFXMLCreateStringByUnescapingEntities(NULL, (CFStringRef)self, (CFDictionaryRef)entities);
	result = [NSString stringWithString:(NSString *)unescapedStringRef];
	CFRelease(unescapedStringRef);
	return result;
}

- (NSString *)stringByTrimmingWhitespace
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)characterSet withString:(NSString *)string
{
	NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
	NSScanner *scanner = [NSScanner scannerWithString:self];
	NSString *buffer;
	NSString *delimiter;
	BOOL found = NO;
	while (![scanner isAtEnd]) {
		buffer = [[[NSString alloc] init] autorelease];
		[scanner scanUpToCharactersFromSet:characterSet intoString:&buffer];
		found = [scanner scanCharactersFromSet:characterSet intoString:&delimiter];
		[result appendString:buffer];
		if (found) {
			[result appendString:string];
		}
	}
	return result;
}


- (NSComparisonResult)numericCompare:(NSString *)string
{
	return [self compare:string options:NSNumericSearch];
}


@end
