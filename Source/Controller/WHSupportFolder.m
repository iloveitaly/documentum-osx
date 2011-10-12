//
//  WHSupportFolder.m
//  PyHelp
//
//  Created by Michael Bianco on 5/28/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "WHSupportFolder.h"

#define PYTHON_SUPPORT_FOLDER_NAME @"pymodules"

@implementation WHSupportFolder
+ (WHSupportFolder *) sharedController {
	return (WHSupportFolder*) [super sharedController];
}

- (NSString *) _createSupportFolder:(NSString *) path {
	if(![_fileManager fileExistsAtPath:path]) {
		if(![_fileManager createDirectoryAtPath:path
									 attributes:nil]) {
			NSLog(@"Error creating support sub-folder %@", path);	
		}
	}
	
	return path;
}

- (NSString *) bundleFolder {
	return [self _createSupportFolder:[[self supportFolder] stringByAppendingPathComponent:@"Bundles"]];
}

- (NSString *) supportFolderForPlugin:(id <WHDataSource>)plugin {
	return [self _createSupportFolder:[[self supportFolder] stringByAppendingPathComponent:[plugin packageName]]];
}
@end
