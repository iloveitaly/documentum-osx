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
- (WHPluginJSONParser *) initWithJSONData:(NSData *)data withNodeClass:(Class) nodeClass {
	if(self = [self initWithNodeClass:nodeClass]) {
		_structureData = [[[[[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone] autorelease] objectWithData:data] retain];
		
		[self generateStructure:_structureData
				   withRootNode:rootNode];
	}
	
	return self;
}

- (void) generateStructure:(NSDictionary *)children withRootNode:(WHHelpNode *)root {
	for (NSString *key in children) {
		NSDictionary *child = [children valueForKey:key];
		WHHelpNode *newNode = [_nodeClass nodeWithDictionary:child];
		[newNode setParentNode:root];
		[root addChild:newNode];
		
		//NSLog(@"Child Name: %@", key);
		
		if(!isEmpty([child valueForKey:@"children"])) {
			self.isStructured = YES;
			[self generateStructure:[child valueForKey:@"children"] withRootNode:newNode];
		}
	}
}

- (void) dealloc {
	[_structureData release];
	[super dealloc];
}
@end
