//
//  WHPluginStructureParser.m
//  PyHelp
//
//  Created by Michael Bianco on 10/14/11.
//  Copyright 2011 MAB Web Design. All rights reserved.
//

#import "WHPluginStructureParser.h"
#import "WHHelpNode.h"

@implementation WHPluginStructureParser

@synthesize isStructured, rootNode;

- (WHPluginStructureParser *) initWithNodeClass:(Class) nodeClass {
	if(self = [self init]) {
		_nodeClass = nodeClass;
		
		self.rootNode = [[nodeClass new] autorelease];
	}
	
	return self;
}

- (void) dealloc {
	[self setRootNode:nil];
	[super dealloc];
}
@end
