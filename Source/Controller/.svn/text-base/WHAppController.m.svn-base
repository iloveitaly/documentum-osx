//
//  WHAppController.m
//  PyHelp
//
//  Created by Michael Bianco on 4/9/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "WHAppController.h"

#import "WHSupportFolder.h"
#import "WHPluginXMLParser.h"
#import "WHHelpNode.h"
#import "FMDatabase.h"
#import "WHHelpIndexer.h"
#import "WHShared.h"

#define HOME_PAGE_URL @"http://prosit-software.com/webhelp.html"
#define MIN_LEFT_PANEL_W 200

@implementation WHAppController
- (id) init {
	if(self = [super init]) {
		/*
		FMDatabase *pythonDatabase = [[FMDatabase alloc] initWithPath:@"/test.db"];
		[pythonDatabase open];
		
		NSLog(@"%@", pythonDatabase);
		FMResultSet *set = [pythonDatabase executeQuery:@"select * from keyword_index where type = 'module'", nil];
		
		while([set next]) {
			NSLog(@"%@", [set stringForColumn:@"keyword"]);
		}
		*/		
	}
	
	return self;
}

- (void) awakeFromNib {
	[[WHSupportFolder sharedController] createSupportFolder];
	[oMainWindow setExcludedFromWindowsMenu:YES];
}

- (IBAction) gotoHomePage:(id)sender {
	OPEN_URL(HOME_PAGE_URL);
}

#pragma mark -
#pragma mark Split View

- (float) splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset {
	if(offset == 0) {
		return MIN_LEFT_PANEL_W;
	} else {
		return 0; //this never happens so....
	}
}

- (void) splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
	// http://www.wodeveloper.com/omniLists/macosx-dev/2003/May/msg00261.html
	
	// grab the splitviews
    NSView *left = [[sender subviews] objectAtIndex:0];
    NSView *right = [[sender subviews] objectAtIndex:1];
	
    float dividerThickness = [sender dividerThickness];
	
	// get the different frames
    NSRect newFrame = [sender frame];
    NSRect leftFrame = [left frame];
    NSRect rightFrame = [right frame];
	
	// change in width for this redraw
	int	dWidth  = newFrame.size.width - oldSize.width;
	
	// ratio of the left frame width to the right used for resize speed when both panes are being resized
	float rLeftRight = (leftFrame.size.width - MIN_LEFT_PANEL_W) / rightFrame.size.width;

	// resize the height of the left
    leftFrame.size.height = newFrame.size.height;
    leftFrame.origin = NSMakePoint(0,0);
	
	// resize the left & right pane equally if we are shrinking the frame
	// resize the right pane only if we are increasing the frame
	// when resizing lock at minimum width for the left panel
	if(leftFrame.size.width <= MIN_LEFT_PANEL_W && dWidth < 0) {
		rightFrame.size.width += dWidth;
	} else if(dWidth > 0) {
		rightFrame.size.width += dWidth;
	} else {
		leftFrame.size.width += floor(dWidth * rLeftRight);
		rightFrame.size.width += ceil(dWidth * (1 - rLeftRight));
	}

    rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
    rightFrame.size.height = newFrame.size.height;
    rightFrame.origin.x = leftFrame.size.width + dividerThickness;

    [left setFrame:leftFrame];
    [right setFrame:rightFrame];
}

@end
