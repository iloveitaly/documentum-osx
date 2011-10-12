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
	return [super sharedController];
}

- (NSString *) bundleFolder {
	return [self _createSupportFolder:[[self supportFolder] stringByAppendingFormat:@"Bundles"]];
}

- (NSString *) supportFolderForPlugin:(id <WHDataSource>)plugin {
	return [self _createSupportFolder:[[self supportFolder] stringByAppendingPathComponent:[plugin packageName]]];
}

- (NSString *) _createSupportFolder:(NSString *) path {
	if(![_fileManager fileExistsAtPath:path]) {
		if(![_fileManager createDirectoryAtPath:path
									 attributes:nil]) {
			NSLog(@"Error creating support sub-folder %@", folderPath);	
		}
	}
	
	return path;
}
@end
