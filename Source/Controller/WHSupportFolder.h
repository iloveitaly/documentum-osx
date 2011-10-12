//
//  WHSupportFolder.h
//  PyHelp
//
//  Created by Michael Bianco on 5/28/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MABSupportFolder.h"
#import "WHDataSource.h"

@interface WHSupportFolder : MABSupportFolder {}

+ (WHSupportFolder *) sharedController;
- (NSString *) bundleFolder;
- (NSString *) supportFolderForPlugin:(id <WHDataSource>)plugin;
@end
