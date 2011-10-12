//
//  PHDataSource.m
//  PyHelp
//
//  Created by Michael Bianco on 5/30/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "PHDataSource.h"
#import "FMDatabase.h"
#import "WHSupportFolder.h"
#import "WHPluginXMLParser.h"
#import "MABEncrypt.h"
#import "WHHelpNode.h"

#define PHXMLStructurePath [[[WHSupportFolder sharedController] supportFolderForPlugin:self] stringByAppendingPathComponent:@"structure.xml"]
#define PHKeywordDBPath [[[WHSupportFolder sharedController] supportFolderForPlugin:self] stringByAppendingPathComponent:@"keywords.db"]
#define PHHelpFilesDownloadURL @"http://docs.python.org/ftp/python/doc/2.5/html-2.5.zip"

#define INDEX_CMD_DATA DecryptData([NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"py_index" ofType:@""]],\
								   [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c%c", 's','l','i','t','h','e','r','y','p','y','t','h','o','n'])
#define PYTHON_CMD_PATH @"/usr/bin/python"

@implementation PHDataSource
- (NSString *) packageName {
	return @"python";	
}

- (NSString *) packageFullName {
	return @"Python";
}

- (BOOL) isInstalled {
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if([fm fileExistsAtPath:PHXMLStructurePath] && [fm fileExistsAtPath:PHKeywordDBPath]) {
		return YES;
	} else {
		return NO;
	}	
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
			[controller downloadHelpArchiveAtURL:[NSURL URLWithString:PHHelpFilesDownloadURL]];
			[controller setCurrentStep:WHDownloadHelpDocs];
			break;
		case WHDownloadHelpDocs:
			[controller runCommand:@"/usr/bin/unzip" withArgs:[NSArray arrayWithObjects:@"-qo", [controller archivePath], nil]];
			break;
		case WHUncompressHelpDocs: {
			/*
			NSData *commandData = INDEX_CMD_DATA;
			[controller runCommand:PYTHON_CMD_PATH withArgs:[NSArray arrayWithObjects:@"-c", [NSString stringWithCString:[commandData bytes] encoding:NSASCIIStringEncoding], [[WHSupportFolder sharedController] pythonSupportFolder], nil]];				
			[controller setCurrentStep:WHIndexHelpDocs];
			 */
			break;
		}
		case WHIndexHelpDocs:
			[controller setCurrentStep:WHComplete];
			break;
	}
}

- (WHHelpNode *) generateRootNode {
	if(!_rootNode) _rootNode = [[WHPluginXMLParser nodeWithXMLFile:PHXMLStructurePath withNodeClass:[WHHelpNode class]] retain];
	
	return _rootNode;
}

- (NSArray *) searchResultsForString:(NSString *)searchString withAllPages:(NSArray *)allPages {
	if(!_searchDatabase) {
		_searchDatabase = [[FMDatabase alloc] initWithPath:PHKeywordDBPath];
		[_searchDatabase setLogsErrors:YES];
		[_searchDatabase open];
	}
	
	FMResultSet *set = [_searchDatabase executeQuery:@"select * from keyword_index where keyword like ? order by keyword != ?, keyword like ? desc, length(keyword) asc", [NSString stringWithFormat:@"%%%@%%", searchString], searchString, [NSString stringWithFormat:@"%@%%", searchString], nil];
	NSMutableArray *results = [NSMutableArray array];
	
	while([set next]) {
		[results addObject:[WHHelpNode nodeWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[set stringForColumn:@"keyword"], @"title", [set stringForColumn:@"filename"], @"path", @"anchor", @"", nil]]];
	}

	return results;
}
@end
