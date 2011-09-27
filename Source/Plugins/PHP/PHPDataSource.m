//
//  PHPDataSource.m
//  PyHelp
//
//  Created by Michael Bianco on 8/1/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "PHPDataSource.h"

#import "NSString+SearchAdditions.h"
#import "WHHelpNode.h"
#import "WHPluginXMLParser.h"
#import "WHCommonFunctions.h"
#import "WHShared.h"

@implementation PHPDataSource
- (id) init {
	if(self = [super init]) {
		NSLog(@"PHP init! %@", [self packageName]);
	}
	
	return self;
}

- (NSData *) indexScriptData {
	return DecryptData([NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"php_index" ofType:@""]],
					   [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c", 'p','o','o','p','y','p','h','p']);
}

- (NSArray *) searchResultsForString:(NSString *)searchString withAllPages:(NSArray *)allPages {
	NSMutableArray *results = [NSMutableArray array];
	
	int a = 0, l = [allPages count];
	WHHelpNode *tempNode;
	for(; a < l; a++) {
		tempNode = [allPages objectAtIndex:a];

		if([[tempNode name] containsString:searchString]) {
			[results addObject:tempNode];
		}
	}
	
	return [results sortedArrayUsingFunction:lengthSort context:NULL];
}
@end
