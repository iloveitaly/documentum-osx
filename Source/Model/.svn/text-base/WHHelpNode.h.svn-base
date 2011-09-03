//
//  WHHelpNode.h
//  PyHelp
//
//  Created by Michael Bianco on 4/30/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define WHHelpNodeFileKey @"path"
#define WHHelpNodeTitleKey @"title"
#define WHHelpNodeAnchorKey @"anchor"

@interface WHHelpNode : NSObject {
	NSString *_filePath;
	NSString *_anchor;
	NSString *_name;
	NSMutableArray *_children;
	NSURL *_completeURL;
	WHHelpNode *_parentNode;
}

+ (id) nodeWithDictionary:(NSDictionary *)attributes;
- (id) initWithDictionary:(NSDictionary *)attributes;

- (NSArray *) children;
- (NSArray *) allChildren;
- (void) setChildren:(NSArray *)aValue;
- (void) addChild:(WHHelpNode *)child;

- (WHHelpNode *) parentNode;
- (void) setParentNode:(WHHelpNode *)aValue;

- (NSString *) name;
- (void) setName:(NSString *)aValue;

- (NSString *) anchor;
- (void) setAnchor:(NSString *)aValue;

- (NSString *) filePath;
- (void) setFilePath:(NSString *)aValue;

// generated once called, call this only after the anchor & filePath have been set
- (NSURL *) completeURL;
@end
