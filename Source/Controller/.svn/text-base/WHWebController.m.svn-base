//
//  WHWebController.m
//  PyHelp
//
//  Created by Michael Bianco on 4/11/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "WHWebController.h"

#import <WebKit/WebKit.h>
#import "WHHelpNode.h"
#import "WHOutlineDataSource.h"
#import "WHPluginList.h"
#import "WHSupportFolder.h"
#import "WHShared.h"

static WHWebController *_sharedController;

@implementation WHWebController
+ (WHWebController *) sharedController {
	extern WHWebController *_sharedController;
	if(!_sharedController) [self new];
	return _sharedController;	
}


- (id) init {
	if(self = [super init]) {
		extern WHWebController *_sharedController;
		_sharedController = self;
		_emptyPlugin = NO;
	}
	
	return self;
}

- (void) awakeFromNib {
	OB_OBSERVE_VALUE(@"isSearching", self, [[WHOutlineDataSource sharedController] searchController]);
	OB_OBSERVE_VALUE(@"selectedPlugin", self, [WHPluginList sharedController]);
	
	_webPreferences = [oWebView preferences];
	
	[_webPreferences setUserStyleSheetEnabled:YES];
}

// called by the outline view
- (IBAction) setHelpPage:(id)sender {
	WHHelpNode *selected = [oHelpTree itemAtRow:[oHelpTree selectedRow]];
	NSString *filePath = [selected valueForKey:@"filePath"];
	NSURL *fileURL = [selected completeURL];
	NSLog(@"FILE %@", filePath);
	// NSLog(@"Going to load %@", filePath);
	
	[self setSelectedNode:selected];
	[[oWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:fileURL]];
}

#pragma mark -
#pragma mark WebView Delegate Methods

- (void) webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
	if(_emptyPlugin) return;
	
	NSURL *currURL = [[[frame provisionalDataSource] request] URL];
	
	// check to see if we already have the right item
	// since URLs can be different (http://localhost/Users/ vs http:///Users/) we check using the path
	// if the URL is a file URL. We have to compare the anchors too (which is a fragment in NSURL)
	
	if([[_selectedNode completeURL] isFileURL] && [currURL isFileURL] &&
	   [[[_selectedNode completeURL] path] isEqualToString:[currURL path]] &&
	   ((isEmpty([currURL fragment]) && isEmpty([[_selectedNode completeURL] fragment])) || [[currURL fragment] isEqualToString:[[_selectedNode completeURL] fragment]])) {

		// we already have the right item!
		// we want to check for this because of the weirdness of anchors
		// and webview URL's not being completely equal
		return;
	} else {
		NSLog(@"Not Equal! %@ : %@", [_selectedNode completeURL], currURL);
		NSLog(@"%@ : %@", [[_selectedNode completeURL] fragment], [currURL fragment]);
		NSLog(@"%@ : %@", [[_selectedNode completeURL] path], [currURL path]);
	}
	
	unsigned int index = [_allPages indexOfObject:currURL];
	
	if(index != NSNotFound) {
		NSLog(@"Found new node! %@", [_allPages objectAtIndex:index]);
		[self setSelectedNode:[_allPages objectAtIndex:index]];
	} else {
		NSLog(@"No matching node found for URL %@", currURL);
	}
}

- (void) webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	if(_emptyPlugin) return;

	// the following is a pretty cool tunnelling algorithm
	// it finds the path up to the 'top' of the tree
	// expands the node, and sets the newly expanded node at the relRoot
	// then it resets the 'bottom' node to the target node and works it way up
	// till the target node is the relRoot node
	
	WHHelpNode *tempNode = _selectedNode, *targetNode = _selectedNode;
	WHHelpNode *relRoot = [[WHOutlineDataSource sharedController] currentRootNode];

	while(tempNode = [tempNode parentNode]) {
		if(relRoot == [_selectedNode parentNode]) {//if the relRoot is the parent of the target node then we are done
			break;
		}
		
		//NSLog(@"%@ Expand? %i:%i", tempNode, [oHelpTree isExpandable:tempNode], [tempNode parent] == relRoot);
		if([oHelpTree isExpandable:tempNode] && [tempNode parentNode] == relRoot) {
			[oHelpTree expandItem:tempNode];
			
			relRoot = tempNode;
			tempNode = targetNode;
		}
	}
	
	// selecte the new rom
	int newRow = [oHelpTree rowForItem:_selectedNode];
	[oHelpTree selectRow:newRow byExtendingSelection:NO];
	[oHelpTree scrollRowToVisible:newRow];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	NSLog(@"Error Loading WebView! %@ :: UserInfo %@", error, [error userInfo]);	
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	NSLog(@"WebView load error %@ :: UserInfo %@", error, [error userInfo]);
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
	//NSLog(@"Decision! %@", actionInformation);
	[listener use];
}

#pragma mark -
#pragma mark Accessors

- (WHHelpNode *) selectedNode {
	return _selectedNode;
}

- (void) setSelectedNode:(WHHelpNode *)aValue {
	[aValue retain];
	[_selectedNode release]; 
	_selectedNode = aValue;
}

- (NSArray *) allPages {
	return _allPages;
}

- (void) setAllPages:(NSArray *)aValue {
	[aValue retain];
	[_allPages release]; 
	_allPages = aValue;	
}

- (void) setStyleSheet:(NSURL *) styleSheet {
	[_webPreferences setUserStyleSheetLocation:styleSheet];
}

#pragma mark -
#pragma mark Notification/Delegate Methods

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqualToString:@"isSearching"] && ![object isSearching]) {
		unsigned int index = [_allPages indexOfObject:_selectedNode];
		if(index != NSNotFound) {
			[self setSelectedNode:[_allPages objectAtIndex:index]];
			[self webView:nil didFinishLoadForFrame:nil];
		}
	} else if([keyPath isEqualToString:@"selectedPlugin"]) {
		if([object isEmptyPlugin]) {
			NSURL *emptyPageURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"empty_plugin" ofType:@"html"]];
			[[oWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:emptyPageURL]];
		} else {
			NSString *overrideCSSPath = [[object selectedPlugin] customCSSFilePath];

			if(!isEmpty(overrideCSSPath))
				[self setStyleSheet:[NSURL URLWithString:overrideCSSPath]];
		}
	}
}
@end
