//
//  WHPluginXMLParser.m
//  PyHelp
//
//  Created by Michael Bianco on 6/5/09.
//  Copyright 2009 MAB Web Design. All rights reserved.
//

#import "WHPluginXMLParser.h"
#import "WHHelpNode.h"

/*
Example XML:
<index>
	<section path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/api.html" title="Python/C API Reference Manual">
		<level1 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/front.html" title="Front Matter"/>
		<level1 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/contents.html" title="Contents"/>
		<level1 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/intro.html" title="1. Introduction">
			<level2 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/includes.html" title="1.1 Include Files"/>
			<level2 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/objects.html" title="1.2 Objects, Types and Reference Counts">
				<level3 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/refcounts.html" title="1.2.1 Reference Counts"/>
				<level3 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/types.html" title="1.2.2 Types"/>
			</level2>
			<level2 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/exceptions.html" title="1.3 Exceptions"/>
			<level2 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/embedding.html" title="1.4 Embedding Python"/>
			<level2 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/debugging.html" title="1.5 Debugging Builds"/>
		</level1>
		<level1 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/veryhigh.html" title="2. The Very High Level Layer"/>
		<level1 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/countingRefs.html" title="3. Reference Counting"/>
		<level1 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/exceptionHandling.html" title="4. Exception Handling">
		<level2 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/standardExceptions.html" title="4.1 Standard Exceptions"/>
		<level2 path="/Users/Mike/Library/Application Support/PyHelp/python/pythondocs/api/node16.html" title="4.2 Deprecation of String Exceptions"/>
	</level1>
	</section>
</index>
*/

@implementation WHPluginXMLParser
+ (WHHelpNode *) nodeWithXMLFile:(NSString *)path withNodeClass:(Class) nodeClass {
	return [[[[self alloc] initWithXMLFile:path withNodeClass:nodeClass] autorelease] rootNode];
}

- (WHHelpNode *) initWithXMLFile:(NSString *)path withNodeClass:(Class) nodeClass {
	if(self = [self init]) {
		_level = 1;
		_nodeClass = nodeClass;
		_rootNode = _currentParentNode = [_nodeClass new];
		
		_parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
		[_parser setShouldResolveExternalEntities:YES];
		[_parser setDelegate:self];
		[_parser parse];
	}
	
	return self;
}

- (WHHelpNode *) rootNode {
	return _rootNode;	
}

- (void) dealloc {
	[_nodeClass release];
	[_rootNode release];
	[_parser release];
	[super dealloc];
}

//---------------------------------------
//		XMLParser Delegate Methods
//---------------------------------------
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
@end
