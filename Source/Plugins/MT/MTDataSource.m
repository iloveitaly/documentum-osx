//
//  ASDataSource.m
//  PyHelp
//
//  Created by Michael Bianco on 4/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MTDataSource.h"
#import "WHIndexer.h"
#import "WHSupportFolder.h"
#import "WHPluginXMLParser.h"
#import "FMDatabase.h"

#define MTXMLStructurePath [[[WHSupportFolder sharedController] supportFolderForPlugin:self] stringByAppendingPathComponent:@"structure.xml"]
#define MTKeywordDBPath [[[WHSupportFolder sharedController] supportFolderForPlugin:self] stringByAppendingPathComponent:@"keywords.db"]

#define INDEX_CMD_DATA DecryptData([NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"mt_index" ofType:@""]],\
[NSString stringWithFormat:@"%c%c%c%c%c%c", 'm','o','o','c','o','w'])
#define PYTHON_CMD_PATH @"/usr/bin/python"

@implementation MTDataSource
- (NSString *) packageName {
	return @"mt";	
}

- (NSString *) packageFullName {
	return @"MooTools";
}

- (BOOL) isInstalled {
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if([fm fileExistsAtPath:MTXMLStructurePath] && [fm fileExistsAtPath:MTKeywordDBPath]) {
		return YES;
	} else {
		return NO;
	}
	
	return YES;
}

- (BOOL) containsSections {
	return YES;	
}

- (BOOL) isTreeStructure {
	return YES;	
}

- (void) performActionForStep:(int)step withController:(id <WHIndexer>)controller {
	switch(step) {
		case WHNothing:
		case WHUncompressHelpDocs: {
			NSData *commandData = INDEX_CMD_DATA;
			[controller runCommand:PYTHON_CMD_PATH withArgs:[NSArray arrayWithObjects:@"-c", [NSString stringWithCString:[commandData bytes] length:[commandData length]], [[NSBundle mainBundle] resourcePath], nil]];				
			[controller setCurrentStep:WHIndexHelpDocs];
			break;
		}
		case WHIndexHelpDocs:
			[controller setCurrentStep:WHComplete];
			break;
	}
}

- (WHHelpNode *) generateRootNode {
	if(!_rootNode) _rootNode = [[WHPluginXMLParser nodeWithXMLFile:MTXMLStructurePath withNodeClass:[WHHelpNode class]] retain];

	return _rootNode;
}

- (NSArray *) searchResultsForString:(NSString *)searchString withAllPages:(NSArray *)allPages {
	if(!_searchDatabase) {
		_searchDatabase = [[FMDatabase alloc] initWithPath:MTKeywordDBPath];
		[_searchDatabase setLogsErrors:YES];
		[_searchDatabase open];
	}
	
	FMResultSet *set = [_searchDatabase executeQuery:@"SELECT * from keyword_index where keyword like ? order by keyword != ?, keyword like ? desc, length(keyword) asc", [NSString stringWithFormat:@"%%%@%%", searchString], searchString, [NSString stringWithFormat:@"%@%%", searchString], nil];
	NSMutableArray *results = [NSMutableArray array];
	
	while([set next]) {
		[results addObject:[WHHelpNode nodeWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[set stringForColumn:@"keyword"], WHHelpNodeTitleKey, [set stringForColumn:@"filename"], WHHelpNodeFileKey, [set stringForColumn:@"anchor"], WHHelpNodeAnchorKey, nil]]];
	}
	
	return results;
}

@end
