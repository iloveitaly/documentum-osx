//
//  WHPluginBase.m
//  PyHelp
//
//  Created by Michael Bianco on 5/30/09.
//  Copyright 2009 MAB Web Design. All rights reserved.
//

#import "WHPluginBase.h"
#import "WHDataSource.h"
#import "WHSupportFolder.h"
#import "WHHelpNode.h"
#import "WHPluginXMLParser.h"
#import "WHCommonFunctions.h"
#import "WHShared.h"

@implementation WHPluginBase
- (id) init {
	if(self = [super init]) {
		_rootNode = nil;
		
		NSLog(@"PATH :: %@", [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHDocumentationDownloadLink]);
	}
	
	return self;
}

// options / configuration

- (NSString *) packageName {
	return [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginShortName];
}

- (NSString *) packageFullName {
	return [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginFullName];
}

- (NSString *) documentationDownloadPath {
	return [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHDocumentationDownloadLink];
}

- (NSString *) pluginStructurePath {
	return [self _supportFilePath:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginStructureFileName]];
}

- (NSString *) pluginKeywordDatabasePath {
	return [self _supportFilePath:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginKeywordDatabaseFileName]];
}

- (BOOL) isInstalled {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *structure = [self pluginStructurePath],
			 *keywords = [self pluginKeywordDatabasePath];
	
	return !isEmpty(keywords) ? [fm fileExistsAtPath:structure] && [fm fileExistsAtPath:keywords] : [fm fileExistsAtPath:structure];
}

- (BOOL) containsSections {
	return [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginHasSections];
}

- (BOOL) isTreeStructure {
	return [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginHasTreeStructure];
}


- (NSString *) _supportFilePath:(NSString *) name {
	return [[[WHSupportFolder sharedController] supportFolderForPlugin:self] stringByAppendingPathComponent:name];
}

- (NSString *) customCSSFilePath {
	return [[NSBundle bundleForClass:[self class]] pathForResource:@"override" ofType:@"css"];
}

- (NSString *) indexFileName {
	return @"index";
}

- (WHHelpNode *) generateRootNode {
	if(!_rootNode) _rootNode = [[WHPluginXMLParser nodeWithXMLFile:[self pluginStructurePath] withNodeClass:[WHHelpNode class]] retain];

	return _rootNode;
}

- (void) performActionForStep:(int)step withController:(id <WHIndexer>)controller {
	switch(step) {
		case WHNothing: {
			NSString *downloadPath = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHDocumentationDownloadLink];
			[controller downloadHelpArchiveAtURL:[NSURL URLWithString:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHDocumentationDownloadLink]]];
			[controller setCurrentStep:WHDownloadHelpDocs];
			break;
		}
			
		case WHDownloadHelpDocs: {
			// /bin/sh (c = executes the following string and exits instead of going into the interactive shell)
			// gzip (c = dont modify file, output to stdout; f = force; d = decompress)
			NSString *extension = [[controller archivePath] pathExtension],
					 *fileName = [[controller archivePath] lastPathComponent];
			
			if([extension isEqualToString:@"zip"]) {
				
			} else if([fileName hasSuffix:@".tar.gz"]) {
				[controller runCommand:@"/usr/bin/tar" withArgs:[NSArray arrayWithObjects:@"xzf", [controller archivePath], nil]];
			} else {
				NSLog(@"Uncaught file name");
			}
		}

			break;
		case WHUncompressHelpDocs: {
			NSString *scriptString = [NSString stringWithCString:[[self indexScriptData] bytes] length:[[self indexScriptData] length]];
			[controller runCommand:@"/usr/bin/python" withArgs:[NSArray arrayWithObjects:@"-c", scriptString, [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pymodules"], nil]];				
			[controller setCurrentStep:WHIndexHelpDocs];
			break;
		}
		case WHIndexHelpDocs:
			[controller setCurrentStep:WHComplete];
			break;
	}
}

// automatic 'best attempt' help function
- (NSArray *) searchResultsForString:(NSString *)searchString withAllPages:(NSArray *)allPages {
	NSMutableArray *results = [NSMutableArray array];
	
	int a = 0, l = [allPages count];
	WHHelpNode *tempNode;
	for(; a < l; a++) {
		tempNode = [allPages objectAtIndex:a];
		
		if([[tempNode name] containsString:searchString ignoringCase:YES]) {
			[results addObject:tempNode];
		}
	}
	
	return [results sortedArrayUsingFunction:lengthSort context:NULL];	
}
@end
