//
//  ASHelpNode.m
//  PyHelp
//
//  Created by Michael Bianco on 4/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ASHelpNode.h"
#import "WHHelpNode.h"
#import "WHShared.h"

@implementation ASHelpNode
- (id) initWithDictionary:(NSDictionary *)attributes {
	if(self = [self init]) {
		//NSLog(@"Attributes %@", attributes);
		[self setFilePath:[attributes valueForKey:@"href"]];
		[self setName:isEmpty([attributes valueForKey:@"name"]) ? [attributes valueForKey:WHHelpNodeTitleKey] : [attributes valueForKey:@"name"]];
		[self setAnchor:@""];
		
	}
	
	return self;
}

@end
