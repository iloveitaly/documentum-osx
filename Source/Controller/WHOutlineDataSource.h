//
//  WHOutlineDataSource.h
//  PyHelp
//
//  Created by Michael Bianco on 4/10/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WHHelpNode, WHSearchController;

@interface WHOutlineDataSource : NSObject {
	IBOutlet NSOutlineView *oHelpTree;
	IBOutlet NSSearchField *oSearchField;
	
	IBOutlet WHSearchController *oSearchController;
	WHHelpNode *_rootNode;
	int _selectedSection;
}

+ (WHOutlineDataSource *) sharedController;

- (void) activateSelectedPlugin;

- (WHHelpNode *) currentRootNode;
- (NSArray *) helpSections;
- (WHSearchController *) searchController;

- (int) selectedSection;
- (void) setSelectedSection:(int)aValue;
@end
