//
//  WHIndexerInformation.h
//  PyHelp
//
//  Created by Michael Bianco on 5/30/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WHIndexer.h"
#import "WHPluginBase.h"

@class WHHelpNode;

enum {
	WHNothing = 0,
	WHDownloadHelpDocs,
	WHUncompressHelpDocs,
	WHIndexHelpDocs,
	WHIndexComplete,
	WHComplete,
	WHError
};

#define WHDocumentationDownloadLink @"WHDocumentationDownloadLink"
#define WHPluginShortName @"WHPluginShortName"
#define WHPluginFullName @"WHPluginFullName"
#define WHPluginStructureFileName @"WHPluginStructureFileName"
#define WHPluginKeywordDatabaseFileName @"WHPluginKeywordDatabaseFileName"
#define WHPluginHasTreeStructure @"WHPluginHasTreeStructure"
#define WHPluginHasSections @"WHPluginHasSections"

@protocol WHDataSource <NSObject>
// general information
- (NSString *) packageName;
- (NSString *) packageFullName;

// structure information
- (BOOL) containsSections;
- (BOOL) isTreeStructure;

// optional information
- (NSString *) customCSSFilePathPath;
- (NSString *) indexFileName;

// installation related methods
- (BOOL) isInstalled;
- (void) performActionForStep:(int)step withController:(id <WHIndexer>)controller;

// generates the 'root' (ie main parent node)
// this method is called everytime the plugin is chosen
- (WHHelpNode *) generateRootNode;

// called everytime a search is performed
- (NSArray *) searchResultsForString:(NSString *)searchString withAllPages:(NSArray *)allPages;
@end