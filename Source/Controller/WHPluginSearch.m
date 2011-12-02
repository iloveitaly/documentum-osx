//
//  WHPluginSearch.m
//  PyHelp
//
//  Created by Michael Bianco on 12/2/11.
//  Copyright (c) 2011 MAB Web Design. All rights reserved.
//

#import "WHPluginSearch.h"

@implementation WHPluginSearch

- (id) init {
	if(self = [super init]) {
		[self setSearchString:@""];
	}
	
	return self;
}

- (IBAction) quickSearchReturn:(id)sender {
	if(![sender currentEditor]) {//then they pressed enter
		[oHelpTree selectRow:0 byExtendingSelection:NO];
		[[oHelpTree target] performSelector:[oHelpTree action] withObject:self];
		
		// focus on the search field after text is typed in
		[[[WHAppController sharedController] mainWindow] makeFirstResponder:oHelpTree];
	}
}

- (IBAction) openWebViewFindPanel:(id)sender {
	if(!oFindPanel) {
		[NSBundle loadNibNamed:@"Find" owner:self];
	}
	
	[oFindPanel makeKeyAndOrderFront:self];
}

- (IBAction) findNext:(id)sender {
	[oWebView searchFor:[oFindStringField stringValue] direction:YES caseSensitive:NO wrap:YES];
}

- (IBAction) findPrevious:(id)sender {
	[oWebView searchFor:[oFindStringField stringValue] direction:NO caseSensitive:NO wrap:YES];
}

#pragma mark -
#pragma mark Accessors

- (BOOL) isSearching {
	return _isSearching;
}

- (void) setIsSearching:(BOOL)aValue {
	_isSearching = aValue;
}

- (NSArray *) searchResults {
	return _searchResults;
}

- (void) setSearchResults:(NSArray *)aValue {
	[aValue retain];
	[_searchResults release]; 
	_searchResults = aValue;
}

- (NSString *) searchString {
	return _searchString;
}

- (void) setSearchString:(NSString *)aValue {
	[aValue retain];
	[_searchString release]; 
	_searchString = aValue;
	
	// the following is kind of sneaky code
	// the reason I set _isSearching before [self setIsSearching:] is b/c of the data source
	// it looks at _isSearching, so we need to make sure that is set correctly before -reloadData is called
	// but we dont want the noficiations to go out until the -reloadData is called
	
	if(isEmpty(_searchString)) {
		_isSearching = NO;
		[oHelpTree reloadData];
		
		[self setIsSearching:NO];
		[self setSearchResults:nil];
	} else {
		NSArray *resultSet = [[[WHPluginList sharedController] selectedPlugin] searchResultsForString:_searchString withAllPages:[[WHWebController sharedController] allPages]];
		[self setSearchResults:resultSet];
		
		if(_isSearching) {
			[oHelpTree reloadData];
		} else {
			_isSearching = YES;
			[oHelpTree reloadData];
			[self setIsSearching:YES];
		}
	}
}

@end
