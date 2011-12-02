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

static int searchSort(id ob1, id ob2, void *searchString) {
	// the shorter string is a better match, but exact match is best
	
	// try for exact match
	if([[ob1 name] isEqualToString:searchString]) return NSOrderedAscending;
	if([[ob2 name] isEqualToString:searchString]) return NSOrderedDescending;
	
	// sort by shortest string
	int l1 = [[ob1 name] length], l2 = [[ob2 name] length];
	if(l1 < l2) return NSOrderedAscending;
	else if(l1 > l2) return NSOrderedDescending;
	else return NSOrderedSame;
}

@implementation WHPluginBase
- (id) init {
	if(self = [super init]) {
		_rootNode = nil;
		_hasBundle = ![[NSBundle bundleForClass:[self class]] isEqual:[NSBundle mainBundle]];
		_parserStructureHint = NO;
		
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

	return !isEmpty(keywords) ? [fm fileExistsAtPath:structure] && [fm fileExistsAtPath:keywords] : [fm fileExistsAtPath:structure];
}

- (BOOL) containsSections {
	return [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginHasSections];
}

- (BOOL) isTreeStructure {
	if(_hasBundle) {
		return [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:WHPluginHasTreeStructure];
	}
	
	return _parserStructureHint;
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
		WHPluginStructureParser *parser;
		
		if([[structureFileName pathExtension] isEqualToString:@"xml"]) {
			_rootNode = [[WHPluginXMLParser nodeWithXMLFile:structureFileName withNodeClass:[WHHelpNode class]] retain];
		} else if ([[structureFileName pathExtension] isEqualToString:@"json"]) {
			parser = [[[WHPluginJSONParser alloc] initWithJSONData:[NSData dataWithContentsOfFile:structureFileName] withNodeClass:[WHHelpNode class]] autorelease];
			_rootNode = [parser.rootNode retain];
			_parserStructureHint = [parser isStructured];
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
			
			if(isEmpty(downloadPath)) {
				[self performActionForStep:WHUncompressHelpDocs withController:controller];
			} else {
				[controller downloadHelpArchiveAtURL:[NSURL URLWithString:downloadPath]];
				[controller setCurrentStep:WHDownloadHelpDocs];
			}
			
			break;
		}
			
		case WHDownloadHelpDocs: {
			// /bin/sh (c = executes the following string and exits instead of going into the interactive shell)
			// gzip (c = dont modify file, output to stdout; f = force; d = decompress)
			NSString *extension = [[controller archivePath] pathExtension],
					 *fileName = [[controller archivePath] lastPathComponent];
			
			if([extension isEqualToString:@"zip"]) {
				// TODO: handle unzip
				[controller runCommand:@"/usr/bin/unzip" withArgs:[NSArray arrayWithObjects:@"-o", @"-d", @"docs", [controller archivePath], nil]];
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
					// determine the file extension
					NSString *indexExtension = [indexScriptPath pathExtension];
					
					// TODO: detect shebang / executable bit
					if([indexExtension isEqualToString:@"rb"]) {
						[controller runCommand:@"/usr/bin/ruby" withArgs:[NSArray arrayWithObject:indexScriptPath]];
					} else if([indexExtension isEqualToString:@"py"]) {
						NSLog(@"Runing PYTHON");
						[controller runCommand:@"/usr/bin/python" withArgs:[NSArray arrayWithObject:indexScriptPath]];
					}
					
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
	// use distance algorithm: http://weblog.wanderingmango.com/articles/14/fuzzy-string-matching-and-the-principle-of-pleasant-surprises?commented=0
	
	NSMutableArray *results = [NSMutableArray array], *firstPassContents = [NSMutableArray array];
	int a = 0, l = [allPages count];
	WHHelpNode *tempNode;
	
	// run through the array being case sensative
	for(; a < l; a++) {
		tempNode = [allPages objectAtIndex:a];
		
		if([[tempNode name] containsString:searchString ignoringCase:NO]) {
			[results addObject:tempNode];
			[firstPassContents addObject:tempNode];
		}
	}
	
	// run through the array disregarding case
	a = 0, l = [allPages count];
	for(; a < l; a++) {
		tempNode = [allPages objectAtIndex:a];
		if(![firstPassContents containsObject:tempNode] && [[tempNode name] containsString:searchString ignoringCase:YES]) {
			[results addObject:tempNode];
		}
	}
	
	return [results sortedArrayUsingFunction:searchSort context:searchString];	
}
@end
