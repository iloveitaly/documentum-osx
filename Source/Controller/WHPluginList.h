//
//  WHPluginList.h
//  PyHelp
//
//  Created by Michael Bianco on 7/14/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WHDataSource.h"

@class WHHelpIndexer;

@interface WHPluginList : NSObject {
	NSMutableArray *_pluginList;
	id <WHDataSource> _selectedPlugin;
	BOOL _isEmpty;
}

+ (WHPluginList *) sharedController;

- (void) findAvailablePlugins;
- (Class) loadPlugin:(NSString*)path;

- (BOOL) isEmptyPlugin;
- (void) setIsEmptyPlugin:(BOOL)empty;

- (NSArray *) pluginList;
- (void) setPluginList:(NSArray *)aValue;

- (id <WHDataSource>) selectedPlugin;
- (void) setSelectedPlugin:(id <NSObject, WHDataSource>)aValue;

// delegate methods
- (void) indexingOperationComplete:(WHHelpIndexer *)indexer;

@end
