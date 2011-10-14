//
//  WHPluginJSONParser.h
//  PyHelp
//
//  Created by Michael Bianco on 10/14/11.
//  Copyright 2011 MAB Web Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHPluginStructureParser.h"

@class WHHelpNode;

@interface WHPluginJSONParser : WHPluginStructureParser {
	id _structureData;
	int _level;		
}

+ (WHHelpNode *) nodeWithJSONData:(NSData *)data withNodeClass:(Class) nodeClass;
@end
