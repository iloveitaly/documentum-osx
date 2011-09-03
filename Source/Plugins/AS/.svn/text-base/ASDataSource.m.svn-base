//
//  ASDataSource.m
//  PyHelp
//
//  Created by Michael Bianco on 4/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ASDataSource.h"
#import "WHIndexer.h"
#import "WHPluginXMLParser.h"
#import "WHCommonFunctions.h"
#import "WHSupportFolder.h"
#import "ASHelpNode.h"

// AS3 Download: http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3.zip
// AS2 Download: http://download.macromedia.com/pub/documentation/en/flash/mx2004/fl_actionscript_reference.zip
// more?		http://download.macromedia.com/pub/documentation/en/flash/fl8/flash_as2lr.zip
// ??			http://help.adobe.com/en_US/AS2LCR/Addendum_10.0/

#define ASXMLStructurePath [[[WHSupportFolder sharedController] supportFolderForPlugin:self] stringByAppendingPathComponent:@"structure.xml"]
#define ASKeywordDBPath [[[WHSupportFolder sharedController] supportFolderForPlugin:self] stringByAppendingPathComponent:@"keywords.db"]
#define ASHelpFilesDownloadURL @"http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3.zip"
#define INDEX_CMD_DATA DecryptData([NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"py_index" ofType:@""]],\
	[NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c", 's','c','r','i','p','t','a','c','t','i','o','n'])
#define PYTHON_CMD_PATH @"/usr/bin/python"

#define XASH_FLASH_PATH_9 @"/Library/Application Support/Adobe/Flash CS3/en/Configuration/HelpPanel/Help/"
#define XASH_FLASH_PATH_8 @"/Users/Shared/Library/Application Support/Macromedia/Flash 8/en/Configuration/HelpPanel/Help/"
#define XASH_FLASH_PATH_7 @"/Users/Shared/Library/Application Support/Macromedia/Flash MX 2004/en/Configuration/HelpPanel/Help/"

#define XASH_FLASH_INDEX_9 @"file:///Library/Application Support/Adobe/Flash CS3/en/Configuration/HelpPanel/Help/Welcome/Welcome_help.html"
#define XASH_FLASH_INDEX_8 @"file:///Users/Shared/Library/Application%20Support/Macromedia/Flash%208/en/Configuration/HelpPanel/Help/Welcome/Welcome_help.html"
#define XASH_FLASH_INDEX_7 @"file:///Users/Shared/Library/Application%20Support/Macromedia/Flash%20MX2004/en/Configuration/HelpPanel/Help/Welcome/Welcome_help.html"

#define TOC_PATH @"/help_toc.xml"

#define AS3XMLStructurePath @"/Users/Mike/Library/Application Support/Adobe/Flash CS3/en/Configuration/HelpPanel/Help/ProgrammingActionScript3/help_toc.xml"

// alternative documenation packages: http://www.actionscript.org/forums/archive/index.php3/t-35181.html

@implementation ASDataSource
- (NSString *) packageName {
	return @"actionscript";	
}

- (NSString *) packageFullName {
	return @"Actionscript";
}

- (BOOL) isInstalled {
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if([fm fileExistsAtPath:ASXMLStructurePath]/* && [fm fileExistsAtPath:PHKeywordDBPath]*/) {
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
			// here we have to determine if the user has the flash ide installed
			[controller downloadHelpArchiveAtURL:[NSURL URLWithString:ASHelpFilesDownloadURL]];
			[controller setCurrentStep:WHDownloadHelpDocs];
			break;
		case WHDownloadHelpDocs:
			[controller runCommand:@"/usr/bin/unzip" withArgs:[NSArray arrayWithObjects:@"-qo", [controller archivePath], nil]];
			break;
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
	if(!_rootNode) _rootNode = [[WHPluginXMLParser nodeWithXMLFile:[self _supportFilePath:@"structure.xml"] withNodeClass:[ASHelpNode class]] retain];
	NSLog(@"ROOT NODE %@", _rootNode);
	return _rootNode;
}

- (NSArray *) searchResultsForString:(NSString *)searchString withAllPages:(NSArray *)allPages {
	NSMutableArray *results = [NSMutableArray array];
	
	int a = 0, l = [allPages count];
	ASHelpNode *tempNode;
	for(; a < l; a++) {
		tempNode = [allPages objectAtIndex:a];
		
		if([[tempNode name] containsString:searchString ignoringCase:YES]) {
			[results addObject:tempNode];
		}
	}
	
	return [results sortedArrayUsingFunction:lengthSort context:NULL];	
}

@end
