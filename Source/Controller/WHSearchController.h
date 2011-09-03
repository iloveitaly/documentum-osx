//
//  WHSearchController.h
//  PyHelp
//
//  Created by Michael Bianco on 7/29/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;

@interface WHSearchController : NSObject {
	NSString *_searchString;
	NSArray *_searchResults;
	BOOL _isSearching;
	
	IBOutlet WebView *oWebView;
	IBOutlet NSOutlineView *oHelpTree;
	
	IBOutlet NSWindow *oFindPanel;
	IBOutlet NSTextField *oFindStringField;
	IBOutlet NSButton *oFindNextButton;
}

- (IBAction) quickSearchReturn:(id)sender;
- (IBAction) openWebViewFindPanel:(id)sender;

- (IBAction) findNext:(id)sender;
- (IBAction) findPrevious:(id)sender;

// accessors
- (BOOL) isSearching;
- (void) setIsSearching:(BOOL)aValue;

- (NSArray *) searchResults;
- (void) setSearchResults:(NSArray *)aValue;

- (NSString *) searchString;
- (void) setSearchString:(NSString *)aValue;
@end
