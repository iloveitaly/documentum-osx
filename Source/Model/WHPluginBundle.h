//
//  WHPluginBundle.h
//  PyHelp
//
//  Created by Michael Bianco on 10/12/11.
//  Copyright 2011 MAB Web Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHPluginBase.h"

@interface WHPluginBundle : WHPluginBase {
	NSString *_bundlePath;
	NSDictionary *_bundleInfo;
}

- (WHPluginBundle *) initBundleWithPath:(NSString *)path;
@end
