//
//  WHPluginSearch.h
//  PyHelp
//
//  Created by Michael Bianco on 12/2/11.
//  Copyright (c) 2011 MAB Web Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WHPluginSearch : NSObject {
	IBOutlet NSWindow *oPluginSearchWindow;
	IBOutlet NSTableView *oPluginTable;
	IBOutlet NSArrayController *oPluginListController;
	
	IBOutlet NSWindow *oMainWindow;
	IBOutlet NSTextField *oSearchField;
	
	NSString *_searchString;
	NSArray *_searchResults;
	NSArray *_defaultResults;
}

- (IBAction) quickSearchReturn:(id)sender;
- (IBAction) selectPlugin:(id)sender;

// accessors
- (BOOL) isSearching;
- (void) setIsSearching:(BOOL)aValue;

- (NSArray *) searchResults;
- (void) setSearchResults:(NSArray *)aValue;

- (NSString *) searchString;
- (void) setSearchString:(NSString *)aValue;

@end
