//
//  KHDataSource.m
//  PyHelp
//
//  Created by Michael Bianco on 6/5/09.
//  Copyright 2009 MAB Web Design. All rights reserved.
//

#import "KHDataSource.h"
#import "WHPluginXMLParser.h"
#import "WHIndexer.h"
#import "WHHelpNode.h"
#import "WHSupportFolder.h"
#import "FMDatabase.h"

@implementation KHDataSource
- (NSData *) indexScriptData {
	return DecryptData([NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"kohana_index" ofType:@""]], [NSString stringWithFormat:@"%c%c%c%c%c", 'h','o','k','a','n']);
}

- (void) performActionForStep:(int)step withController:(id <WHIndexer>)controller {
	switch(step) {
		case WHNothing:
		case WHUncompressHelpDocs: {
			/*
			NSData *commandData = INDEX_CMD_DATA;
			NSLog(@"%@", commandData);
			[controller runCommand:PYTHON_CMD_PATH withArgs:[NSArray arrayWithObjects:@"-c", [NSString stringWithCString:[commandData bytes] length:[commandData length]], [[WHSupportFolder sharedController] pythonSupportFolder], nil]];				
			[controller setCurrentStep:WHIndexHelpDocs];
			 */
			break;
		}
		case WHIndexHelpDocs:
			[controller setCurrentStep:WHComplete];
			break;
	}
}

- (NSArray *) searchResultsForString:(NSString *)searchString withAllPages:(NSArray *)allPages {
	/*
	if(!_searchDatabase) {
		_searchDatabase = [[FMDatabase alloc] initWithPath:KHKeywordDBPath];
		[_searchDatabase setLogsErrors:YES];
		[_searchDatabase open];
	}
	
	FMResultSet *set = [_searchDatabase executeQuery:@"SELECT * from keyword_index where keyword like ? order by keyword != ?, keyword like ? desc, length(keyword) asc",
						[NSString stringWithFormat:@"%%%@%%", searchString],
						searchString,
						[NSString stringWithFormat:@"%@%%", searchString], nil];
	
	NSMutableArray *results = [NSMutableArray array];
	
	while([set next]) {
		NSLog(@"Res %@", [set stringForColumn:@"keyword"]);
		[results addObject:[KHHelpNode nodeWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[set stringForColumn:@"keyword"], WHHelpNodeTitleKey, [set stringForColumn:@"filename"], WHHelpNodeFileKey, [set stringForColumn:@"anchor"], WHHelpNodeAnchorKey, nil]]];
	}
	
	return results;
	 */
}
@end
