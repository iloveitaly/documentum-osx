 //
//  CSSDataSource.m
//  PyHelp
//
//  Created by Michael Bianco on 7/30/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "CSSDataSource.h"
#import "WHPluginXMLParser.h"

#import "NSString+SearchAdditions.h"
#import "WHSupportFolder.h"
#import "WHCommonFunctions.h"

#define CSSXMLStructurePath [[[WHSupportFolder sharedController] supportFolderForPlugin:self] stringByAppendingPathComponent:@"structure.xml"]
#define CSSHelpFilesDownloadURL @"http://www.w3.org/TR/1998/REC-CSS2-19980512/css2.zip"

#define INDEX_CMD_DATA DecryptData([NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"css_index" ofType:@""]],\
								   [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c", 's','n','e','a','k','y','c','s','s'])
#define PYTHON_CMD_PATH @"/usr/bin/python"

@implementation CSSDataSource
// general information
- (NSString *) packageName {
	return @"css";
}

- (NSString *) packageFullName {
	return @"CSS";
}

// installation related methods
- (BOOL) isInstalled {
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if([fm fileExistsAtPath:CSSXMLStructurePath]) {
		return YES;
	} else {
		return NO;
	}	
}

- (BOOL) containsSections {
	return NO;	
}

- (BOOL) isTreeStructure {
	return NO;	
}

- (void) performActionForStep:(int)step withController:(id <WHIndexer>)controller {
	switch(step) {
		case WHNothing:
			[controller downloadHelpArchiveAtURL:[NSURL URLWithString:CSSHelpFilesDownloadURL]];
			[controller setCurrentStep:WHDownloadHelpDocs];
			break;
		case WHDownloadHelpDocs:
			[controller runCommand:@"/usr/bin/unzip" withArgs:[NSArray arrayWithObjects:@"-qo", @"-d", @"cssdocs", [controller archivePath], nil]];
			break;
		case WHUncompressHelpDocs: {
			NSData *commandData = INDEX_CMD_DATA;
			[controller runCommand:PYTHON_CMD_PATH withArgs:[NSArray arrayWithObjects:@"-c", [NSString stringWithCString:[commandData bytes] length:[commandData length]], [[WHSupportFolder sharedController] pythonSupportFolder], nil]];				
			[controller setCurrentStep:WHIndexHelpDocs];
			break;
		}
		case WHIndexHelpDocs:
			[controller setCurrentStep:WHComplete];
			break;
	}
}

// data source methods
- (WHHelpNode *) generateRootNode {
	if(!_rootNode) _rootNode = [[WHPluginXMLParser nodeWithXMLFile:[self _supportFilePath:@"structure.xml"] withNodeClass:[WHHelpNode class]] retain];

	return _rootNode;
}

- (NSArray *) searchResultsForString:(NSString *)searchString withAllPages:(NSArray *)allPages {
	NSMutableArray *results = [NSMutableArray array];
	
	int a = 0, l = [allPages count];
	CSSHelpNode *tempNode;
	for(; a < l; a++) {
		tempNode = [allPages objectAtIndex:a];

		if([[tempNode name] containsString:searchString]) {
			[results addObject:tempNode];
		}
	}
	
	return [results sortedArrayUsingFunction:lengthSort context:NULL];
}
@end
