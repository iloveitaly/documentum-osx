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
#import "WHPluginJSONParser.h"
#import "WHCommonFunctions.h"
#import "WHShared.h"

@implementation WHPluginBase
- (id) init {
	if(self = [super init]) {
		_rootNode = nil;
		_hasBundle = ![[NSBundle bundleForClass:[self class]] isEqual:[NSBundle mainBundle]];
		
		// NSLog(@"PATH :: %@", [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHDocumentationDownloadLink]);
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
	if(_hasBundle) {
		return [self _supportFilePath:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginStructureFileName]];
	} else {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *structurePath = [self _supportFilePath:@"structure.xml"];
		
		// try xml first, default to json
		if([fm fileExistsAtPath:structurePath isDirectory:NO]) {
			return structurePath;
		} else {
			return [self _supportFilePath:@"structure.json"];
		}
	}
}

- (NSString *) pluginKeywordDatabasePath {
	// default to no keywords.db, isn't required for a bundle so don't default to it
	return _hasBundle ? [self _supportFilePath:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginKeywordDatabaseFileName]] : nil;
}

- (NSString *) indexScriptPath {
	return nil;
}

- (BOOL) isInstalled {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *structure = [self pluginStructurePath],
			 *keywords = [self pluginKeywordDatabasePath];
	NSLog(@"Structure Path %@", structure);
	return !isEmpty(keywords) ? [fm fileExistsAtPath:structure] && [fm fileExistsAtPath:keywords] : [fm fileExistsAtPath:structure];
}

- (BOOL) containsSections {
	return [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginHasSections];
}

- (BOOL) isTreeStructure {
	return true;
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
	if(!_rootNode) {
		// we accept two types of structures: json & xml
		// determine which teh plugin is using
		NSString *structureFileName = [self pluginStructurePath];
		
		if([[structureFileName pathExtension] isEqualToString:@"xml"]) {
			_rootNode = [[WHPluginXMLParser nodeWithXMLFile:structureFileName withNodeClass:[WHHelpNode class]] retain];
		} else if ([[structureFileName pathExtension] isEqualToString:@"json"]) {
			_rootNode = [[WHPluginJSONParser nodeWithJSONData:[NSData dataWithContentsOfFile:structureFileName] withNodeClass:[WHHelpNode class]] retain];
		} else {
			NSLog(@"Error: uncaught structure type");
		}
	}

	return _rootNode;
}

- (void) performActionForStep:(int)step withController:(id <WHIndexer>)controller {
	switch(step) {
		case WHNothing: {
			NSString *downloadPath = [self documentationDownloadPath];
			[controller downloadHelpArchiveAtURL:[NSURL URLWithString:downloadPath]];
			[controller setCurrentStep:WHDownloadHelpDocs];
			break;
		}
			
		case WHDownloadHelpDocs: {
			// /bin/sh (c = executes the following string and exits instead of going into the interactive shell)
			// gzip (c = dont modify file, output to stdout; f = force; d = decompress)
			NSString *extension = [[controller archivePath] pathExtension],
					 *fileName = [[controller archivePath] lastPathComponent];
			
			if([extension isEqualToString:@"zip"]) {
				// TODO: handle unzip
			} else if([fileName hasSuffix:@".tar.gz"] || [fileName hasSuffix:@".tgz"]) {
				[controller runCommand:@"/usr/bin/tar" withArgs:[NSArray arrayWithObjects:@"xzf", [controller archivePath], nil]];
			} else {
				NSLog(@"Uncaught uncompress extension: %@", fileName);
			}
		}

			break;
		case WHUncompressHelpDocs: {
			// eventually there will be three options: encrypted index script, decrypted index script, and some pre-wrapped commands for common use cases
			NSString *indexScriptPath = [self indexScriptPath];
			NSFileManager *fm = [NSFileManager defaultManager];
			NSLog(@"Index Script %@", indexScriptPath);
			if(!isEmpty(indexScriptPath)) {
				if([fm isExecutableFileAtPath:indexScriptPath]) {
					[controller runCommand:indexScriptPath withArgs:nil];
				} else {
					// determine the file extensive
				}
			} else {
				NSString *scriptString = [NSString stringWithCString:[[self indexScriptData] bytes] length:[[self indexScriptData] length]];
				[controller runCommand:@"/usr/bin/python" withArgs:[NSArray arrayWithObjects:@"-c", scriptString, [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pymodules"], nil]];				
			}
			
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
