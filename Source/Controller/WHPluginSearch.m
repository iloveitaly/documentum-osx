//
//  WHPluginSearch.m
//  PyHelp
//
//  Created by Michael Bianco on 12/2/11.
//  Copyright (c) 2011 MAB Web Design. All rights reserved.
//

#import "WHPluginSearch.h"
#import "WHAppController.h"
#import "WHPluginList.h"
#import "WHShared.h"
#import "NSString+Levenshtein.h"

@implementation WHPluginSearch

- (id) init {
	if(self = [super init]) {
		[self setSearchString:@""];
		
		_defaultResults = nil;
	}
	
	return self;
}

- (NSArray *) defaultPluginList {
	if(isEmpty(_defaultResults)) {
		NSArray *availablePlugins = [[WHPluginList sharedController] pluginList];
		_defaultResults = [[NSMutableArray alloc] initWithCapacity:[availablePlugins count]];
		
		for (WHPluginBase *plugin in [[WHPluginList sharedController] pluginList]) {
			[_defaultResults addObject:[NSDictionary dictionaryWithObject:plugin forKey:@"plugin"]];
		}
	}
	
	return _defaultResults;
}

- (IBAction) quickSearchReturn:(id)sender {
	if(![sender currentEditor]) {//then they pressed enter
		[oPluginListController setSelectionIndex:0];
		[self selectPlugin:self];
		[oPluginSearchWindow close];
	}
}

- (IBAction)selectPlugin:(id)sender {
	[[WHPluginList sharedController] setSelectedPlugin:[[[oPluginListController selectedObjects] lastObject] valueForKey:@"plugin"]];
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
		[oPluginTable reloadData];
		[self setSearchResults:[self defaultPluginList]];
	} else {
		NSMutableArray *results = [NSMutableArray array];
		
		for (id plugin in [[WHPluginList sharedController] pluginList]) {
			// modified levenshtein algorithm
			NSInteger score = [_searchString compareWithWord:[plugin packageFullName] matchGain:10 missingCost:1];
			
			[results addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:score], @"score", plugin, @"plugin", nil]];
		}
		
		// sort list
		results = [results sortedArrayUsingComparator: (NSComparator)^(id obj1, id obj2) {
			return [[obj1 valueForKey:@"score"] compare:[obj2 valueForKey:@"score"]];
		}];
		
		// NSLog(@"Results %@", results);
		
		// possibly display a limited number of results?
		
		[self setSearchResults:results];
		[oPluginTable reloadData];
	}
}

@end
