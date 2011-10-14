//
//  WHPluginStructureParser.h
//  PyHelp
//
//  Created by Michael Bianco on 10/14/11.
//  Copyright 2011 MAB Web Design. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WHHelpNode;

@interface WHPluginStructureParser : NSObject {
	BOOL isStructured;
	WHHelpNode *rootNode
	Class _nodeClass;
}

@property BOOL isStructured;
@property WHHelpNode rootNode;
@end
