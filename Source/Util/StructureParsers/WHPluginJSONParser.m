//
//  WHPluginJSONParser.m
//  PyHelp
//
//  Created by Michael Bianco on 10/14/11.
//  Copyright 2011 MAB Web Design. All rights reserved.
//

#import "WHPluginJSONParser.h"
#import "WHHelpNode.h"
#import "JSONKit.h"
#import "WHShared.h"

@implementation WHPluginJSONParser
+ (WHHelpNode *) nodeWithJSONData:(NSData *)data withNodeClass:(Class) nodeClass {
	return [[[[self alloc] initWithJSONFile:data withNodeClass:nodeClass] autorelease] rootNode];
}

- (WHHelpNode *) initWithJSONFile:(NSData *)data withNodeClass:(Class) nodeClass {
	if(self = [self init]) {
		_level = 1;
		_nodeClass = nodeClass;
		_rootNode = _currentParentNode = [_nodeClass new];		
		_structureData = [[[[[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone] autorelease] objectWithData:data] retain];
		
		[self generateStructure:_structureData withRootNode:_rootNode];
	}
	
	return self;
}

- (void) generateStructure:(NSDictionary *)children withRootNode:(WHHelpNode *)root {
	for (NSString *key in children) {
		NSDictionary *child = [children valueForKey:key];
		WHHelpNode *newNode = [_nodeClass nodeWithDictionary:child];
		[newNode setParentNode:root];
		[root addChild:newNode];
		
		NSLog(@"Child Name: %@", key);
		
		if(!isEmpty([child valueForKey:@"children"])) {
			[self generateStructure:[child valueForKey:@"children"] withRootNode:newNode];
		}
	}
}

- (WHHelpNode *) rootNode {
	return _rootNode;	
}

- (void) dealloc {
	[_nodeClass release];
	[_rootNode release];
	[super dealloc];
}

//---------------------------------------
//		XMLParser Delegate Methods
//---------------------------------------
/*
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
	
	WHHelpNode *newNode = [_nodeClass nodeWithDictionary:attributeDict];
	
	// Example XML Structure:
	
	if([elementName isEqualToString:@"section"]) {
		[_rootNode addChild:newNode];
		[newNode setParentNode:_rootNode];
		_lastNode = _currentParentNode = newNode;
		_level = 1;
	} else if([elementName hasPrefix:@"level"]) {
		// grab the level value, note that this will only work with levels 1-9
		int thisLevel = [[elementName substringFromIndex:[elementName length] - 1] intValue];
		
		if(thisLevel == _level) {
			// then we are still adding items to this section
			[newNode setParentNode:_currentParentNode];
			[_currentParentNode addChild:newNode];
		} else {
			// we have a new level
			
			if(thisLevel > _level) {
				// then we are going deeper
				_currentParentNode = _lastNode;
				[newNode setParentNode:_currentParentNode];
				[_currentParentNode addChild:newNode];
			} else {
				// move up in the tree
				// + root
				// 		+ child
				//			+ anotherChild
				
				int diff = _level - thisLevel;
				
				// move up the difference in levels
				while(diff--) {
					_currentParentNode = [_currentParentNode parentNode];
				}
				
				[newNode setParentNode:_currentParentNode];
				[_currentParentNode addChild:newNode];
				_lastNode = newNode;
			}
		}
		
		_level = thisLevel;
		_lastNode = newNode;
	} else {
		NSLog(@"XML Parser: Uncaught Tag %@", elementName);
	}
}
*/
@end
