//
//  CSSDataSource.h
//  PyHelp
//
//  Created by Michael Bianco on 7/30/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WHDataSource.h"

@class CSSHelpNode;

@interface CSSDataSource : WHPluginBase <WHDataSource> {}

// general information
- (NSString *) packageName;
- (NSString *) packageFullName;

// installation related methods
- (BOOL) isInstalled;
- (BOOL) containsSections;
- (void) performActionForStep:(int)step withController:(id <WHIndexer>)controller;

// data source methods
- (WHHelpNode *) generateRootNode;
- (NSArray *) searchResultsForString:(NSString *)searchString withAllPages:(NSArray *)allPages;
@end
