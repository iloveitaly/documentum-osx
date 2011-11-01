//
//  WHHelpNode.m
//  PyHelp
//
//  Created by Michael Bianco on 4/30/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "WHHelpNode.h"
#import "WHShared.h"

@implementation WHHelpNode
@synthesize windowTitle;

+ (id) nodeWithDictionary:(NSDictionary *)attributes {
	return [[[self alloc] initWithDictionary:attributes] autorelease];
}

- (id) initWithDictionary:(NSDictionary *)attributes {
	if(self = [self init]) {
		// NSLog(@"Attributes %@", attributes);
		[self setFilePath:[attributes valueForKey:WHHelpNodeFileKey]];
		[self setName:[attributes valueForKey:WHHelpNodeTitleKey]];
		[self setAnchor:[attributes valueForKey:WHHelpNodeAnchorKey]];
		
		windowTitle = [[attributes valueForKey:WHHelpNodeWindowTitleKey] retain];
		
		// use the standard name if no window title exists
		if(isEmpty(windowTitle)) {
			windowTitle = _name;
		}
	}
	
	return self;
}

- (id) init {
	if(self = [super init]) {
		[self setChildren:[NSMutableArray array]];
	}
	
	return self;
}

- (void) dealloc {
	[_filePath release];
	[_anchor release];
	[_name release];
	[_completeURL release];
	[_children release];
	[super dealloc];
}

- (NSArray *) children {
	return _children;
}

// this is only used by the root node to get a linear list of everything
- (NSMutableArray *) allChildren {
	NSMutableArray *allChilds = [NSMutableArray array];
	WHHelpNode *tempNode;
	
	int l = [_children count];
	while(l--) {
		tempNode = [_children objectAtIndex:l];
		[allChilds addObject:tempNode];
		[allChilds addObjectsFromArray:[tempNode allChildren]];
	}

	return allChilds;
}

- (void) setChildren:(NSArray *)aValue {
	NSArray *oldChildren = _children;
	_children = [aValue retain];
	[oldChildren release];
}

- (void) addChild:(WHHelpNode *)child {
	[_children addObject:child];
}

- (WHHelpNode *) parentNode {
	return _parentNode;
}

- (void) setParentNode:(WHHelpNode *)aValue {
	_parentNode = aValue;
}

- (NSString *) filePath {
	return _filePath;
}

- (void) setFilePath:(NSString *)aValue {
	[aValue retain];
	[_filePath release];
	_filePath = aValue;
}

- (NSString *) name {
	return _name;
}

- (void) setName:(NSString *)aValue {
	NSString *oldName = _name;
	_name = [aValue retain];
	[oldName release];
}

- (NSString *) anchor {
	return _anchor;
}

- (void) setAnchor:(NSString *)aValue {
	[aValue retain];
	[_anchor release]; 
	_anchor = aValue;
}

- (NSURL *) completeURL {
	// unfortunatly it looks as though the webview loads a different looking URL when a link is clicked in the webview
	// this causes issues when trying to compare the absoluteURL
	
	if(!_completeURL) {
		if(!isEmpty(_anchor)) {
			// remove the # in the anchor (allows the creator of a plugin to not worry about the format in which he stores the anchor)
			_completeURL = [[NSURL URLWithString:[NSString stringWithFormat:@"#%@", [_anchor stringByReplacingOccurrencesOfString:@"#" withString:@""]] relativeToURL:[NSURL fileURLWithPath:_filePath]] retain];
		} else {
			_completeURL = [[NSURL fileURLWithPath:_filePath] retain];
		}
	}

	return _completeURL;
}

- (BOOL) isEqual:(id)ob {
	if([ob isKindOfClass:[NSURL class]]) {		
		// unfortunatly we cant just compare the URLs since
		// NSURL doesn't seem to care about anchors
		// luckily NSURL doesn't create a new NSString everytime -absoluteURL is called
		// looks like NSURL caches the -description too
		
		if([[ob path] isEqualToString:[[self completeURL] path]]) {
			return YES;
		} else {
			return NO;
		}
	} else if([ob isKindOfClass:[WHHelpNode class]]) {
		return [_filePath isEqualToString:[ob filePath]];
	} else {
		return [super isEqual:ob];
	}
}

@end
