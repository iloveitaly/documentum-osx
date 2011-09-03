//
//  WHPluginBase.h
//  PyHelp
//
//  Created by Michael Bianco on 5/30/09.
//  Copyright 2009 MAB Web Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WHIndexer.h"

@class WHHelpNode;

@interface WHPluginBase : NSObject {
	WHHelpNode *_rootNode;
	
}

- (NSString *) packageName;
- (NSString *) packageFullName;
- (NSString *) documentationDownloadPath;
- (NSString *) pluginStructurePath;
- (NSString *) customCSSFilePathPath;
- (NSString *) indexFileName;

- (BOOL) isInstalled;
- (BOOL) containsSections;
- (BOOL) isTreeStructure;


- (void) performActionForStep:(int)step withController:(id <WHIndexer>)controller;
- (NSArray *) searchResultsForString:(NSString *)searchString withAllPages:(NSArray *)allPages;
- (NSString *) _supportFilePath:(NSString *) name;

@end
