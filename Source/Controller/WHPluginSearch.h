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
	
	NSString *_searchString;
	NSArray *_searchResults;
}

- (IBAction) quickSearchReturn:(id)sender;
- (IBAction) switchPlugin:(id)sender;

// accessors
- (BOOL) isSearching;
- (void) setIsSearching:(BOOL)aValue;

- (NSArray *) searchResults;
- (void) setSearchResults:(NSArray *)aValue;

- (NSString *) searchString;
- (void) setSearchString:(NSString *)aValue;

@end
