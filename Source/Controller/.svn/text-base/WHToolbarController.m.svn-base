//
//  WHToolbarController.m
//  PyHelp
//
//  Created by Michael Bianco on 7/29/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "WHToolbarController.h"


@implementation WHToolbarController
- (void) awakeFromNib {
	NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	[oMainWindow setToolbar:[toolbar autorelease]];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
	 itemForItemIdentifier:(NSString *)itemIdentifier
	willBeInsertedIntoToolbar:(BOOL)flag {
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	if ([itemIdentifier isEqualToString:@"NavItem"]) {
		[item setLabel:@"Back/Forward"];
		[item setPaletteLabel:[item label]];
		//[item setView:oNavView];
		
		/*
		NSRect fRect = [oNavView frame];
		[item setMinSize:fRect.size];
		[item setMaxSize:fRect.size];
		 */
	} else if ([itemIdentifier isEqualToString:@"SearchItem"]) {
		[item setLabel:@"Search"];
		[item setPaletteLabel:[item label]];
		[item setView:oSearchFieldView];
		
		NSRect fRect = [oSearchFieldView frame];
		[item setMinSize:fRect.size];
		[item setMaxSize:fRect.size];
	} else if([itemIdentifier isEqualToString:@"PluginPopup"]) {
		[item setLabel:@"Plugin List"];
		[item setPaletteLabel:[item label]];
		[item setView:oPluginPopup];
		
		NSRect fRect = [oPluginPopup frame];
		[item setMinSize:fRect.size];
		[item setMaxSize:fRect.size];
		
	}
	
	return [item autorelease];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
	return [NSArray arrayWithObjects:NSToolbarSeparatorItemIdentifier, NSToolbarSpaceItemIdentifier,
									 NSToolbarFlexibleSpaceItemIdentifier, NSToolbarCustomizeToolbarItemIdentifier, 
									 @"AddItem", @"RemoveItem", @"SearchItem", @"PluginPopup", nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
	return [NSArray arrayWithObjects:@"SearchItem", @"PluginPopup", /* @"NavItem", */ NSToolbarFlexibleSpaceItemIdentifier, nil];
}

@end
