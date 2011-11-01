//
//  WHWebController.h
//  PyHelp
//
//  Created by Michael Bianco on 4/11/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView, WHHelpNode, WebPreferences;

@interface WHWebController : NSObject {
	IBOutlet NSOutlineView *oHelpTree;
	IBOutlet WebView *oWebView;
	IBOutlet NSWindow *oMainWindow;
	
	NSArray *_allPages;
	WebPreferences *_webPreferences;
	WHHelpNode *_selectedNode;
	BOOL _emptyPlugin;
}

+ (WHWebController *) sharedController;

- (IBAction) setHelpPage:(id)sender;

// Accessors
- (WHHelpNode *) selectedNode;
- (void) setSelectedNode:(WHHelpNode *)aValue;

- (NSArray *) allPages;
- (void) setAllPages:(NSArray *)aValue;
@end
