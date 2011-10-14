//
//  WHOutlineDataSource.m
//  PyHelp
//
//  Created by Michael Bianco on 4/10/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "WHOutlineDataSource.h"

#import "WHSupportFolder.h"
#import "WHPluginList.h"
#import "PHDataSource.h"
#import "WHWebController.h"
#import "WHSearchController.h"
#import "WHHelpNode.h"
#import "WHShared.h"

#define CELL_INDENT 16.0F
#define DATA_SOURCE_CHECK_NIL \
if(item == nil) {\
	item = [self currentRootNode];\
}

static WHOutlineDataSource *_sharedController;

@implementation WHOutlineDataSource
+ (WHOutlineDataSource *) sharedController {
	extern WHOutlineDataSource *_sharedController;
	if(!_sharedController) [self new];
	return _sharedController;	
}

- (id) init {
	if(self = [super init]) {
		extern WHOutlineDataSource *_sharedController;
		_sharedController = self;

		_selectedSection = 0;
	}
	
	return self;
}

- (void) awakeFromNib {
	OB_OBSERVE_VALUE(@"isSearching", self, oSearchController);
}

- (void) activateSelectedPlugin {
	// this is basically the 'load new plugin' command
	
	[_rootNode release];
	
	// I believe the only thing tied to helpSections is the popup
	[self willChangeValueForKey:@"helpSections"];
	
	if([[WHPluginList sharedController] isEmptyPlugin]) {
		_rootNode = nil;
	} else {
		_rootNode = [[[[WHPluginList sharedController] selectedPlugin] generateRootNode] retain];
		NSLog(@"Root Node %@", _rootNode);
		NSLog(@"Children? %@", [_rootNode allChildren]);
	}
	
	[[WHWebController sharedController] setAllPages:[_rootNode allChildren]];
	
	[oHelpTree reloadData];
	//if(!isEmpty(overrideCSSPath))
	//	[[WHWebController sharedController] setStyleSheet:[NSURL URLWithString:overrideCSSPath]];
	
	
	[self didChangeValueForKey:@"helpSections"];
	
	if([[[WHPluginList sharedController] selectedPlugin] isTreeStructure]) {
		[oHelpTree setIndentationPerLevel:CELL_INDENT];
		[oHelpTree setUsesAlternatingRowBackgroundColors:NO];		
	} else {
		[oHelpTree setIndentationPerLevel:0.0];
		[oHelpTree setUsesAlternatingRowBackgroundColors:YES];		
	}
	
	[oSearchController setSearchString:@""];
}

#pragma mark -
#pragma mark Accessors

- (WHHelpNode *) currentRootNode {
	if(_selectedSection != 0) {
		return [[_rootNode children] objectAtIndex:_selectedSection - 1];
	} else {
		return _rootNode;	
	}
}

- (NSArray *) helpSections {
	if([[[WHPluginList sharedController] selectedPlugin] containsSections]) {
		NSMutableArray *sections = [[_rootNode children] mutableCopy];
		[sections insertObject:[NSDictionary dictionaryWithObject:@"All Sections" forKey:@"name"] atIndex:0];
		return [sections autorelease];
	} else {
		return [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:@"No Sections" forKey:@"name"]];	
	}
}

- (WHSearchController *) searchController {
	return oSearchController;	
}

- (int) selectedSection {
	return _selectedSection;
}

- (void) setSelectedSection:(int)section {
	_selectedSection = section;
	[oHelpTree reloadData];
}

#pragma mark -
#pragma mark Data Source Methods

- (id) outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	DATA_SOURCE_CHECK_NIL;

	if([oSearchController isSearching]) return [[oSearchController searchResults] objectAtIndex:index];
	
	return [[item children] objectAtIndex:index];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	DATA_SOURCE_CHECK_NIL;
	
	//when we are searching no items are expandable
	if([oSearchController isSearching]) return NO;
	
	return [[item children] count] != 0;
}

- (int) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if([oSearchController isSearching]) {
		if(item != nil) {//while searching there is never any children
			return 0;
		}
		
		return [[oSearchController searchResults] count];
	}
	
	DATA_SOURCE_CHECK_NIL;
	
	return [[(WHHelpNode*)item children] count]; 
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	return [item valueForKey:@"name"];
}

- (void) outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	[cell setControlSize:NSSmallControlSize];
	[cell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([oSearchController isSearching]) {
		[oHelpTree setIndentationPerLevel:0.0];
		[oHelpTree setUsesAlternatingRowBackgroundColors:YES];	
	} else if([[[WHPluginList sharedController] selectedPlugin] isTreeStructure]) {
		[oHelpTree setIndentationPerLevel:CELL_INDENT];
		[oHelpTree setUsesAlternatingRowBackgroundColors:NO];
	}	
}
@end
