//
//  WHPluginXMLParser.h
//  PyHelp
//
//  Created by Michael Bianco on 6/5/09.
//  Copyright 2009 MAB Web Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WHHelpNode;

@interface WHPluginXMLParser : NSObject {
	NSXMLParser *_parser;
	
	WHHelpNode *_rootNode;
	WHHelpNode *_currentParentNode;
	WHHelpNode *_lastNode;
	
	Class _nodeClass;
	int _level;	
}

+ (WHHelpNode *) nodeWithXMLFile:(NSString *)path withNodeClass:(Class) nodeClass;

- (WHHelpNode *) initWithXMLFile:(NSString *)path withNodeClass:(Class) nodeClass;
- (WHHelpNode *) rootNode;

@end
