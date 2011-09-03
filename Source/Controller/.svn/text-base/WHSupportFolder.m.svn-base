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

- (NSString *) pythonSupportFolder {
	return [[self supportFolder] stringByAppendingPathComponent:PYTHON_SUPPORT_FOLDER_NAME];
}

- (NSString *) supportFolderForPlugin:(id <WHDataSource>)plugin {
	NSString *folderPath = [[self supportFolder] stringByAppendingPathComponent:[plugin packageName]];
	
	// create the plugin support folder if it doesn't already exist
	if(![_fileManager fileExistsAtPath:folderPath]) {
		if(![_fileManager createDirectoryAtPath:folderPath
									 attributes:nil]) {
			NSLog(@"Error creating app-support sub-folder %@", folderPath);	
		}
	}
	
	return folderPath;
}
@end
