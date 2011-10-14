//
//  WHPluginBundle.m
//  PyHelp
//
//  Created by Michael Bianco on 10/12/11.
//  Copyright 2011 MAB Web Design. All rights reserved.
//

#import "WHPluginBundle.h"
#import "JSONKit.h"
#import "WHShared.h"


@implementation WHPluginBundle
- (WHPluginBundle *) initBundleWithPath:(NSString *)bundlePath {
	if(self = [self init]) {
		_bundlePath = [bundlePath retain];
		
		// load the info JSON
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *jsonInfoFile = [bundlePath stringByAppendingPathComponent:@"info.json"];

		if([fm fileExistsAtPath:jsonInfoFile isDirectory:NO]) {
			// TODO: better error handling, i.e. misformed json
			NSData *jsonData = [NSData dataWithContentsOfFile:jsonInfoFile];
			JSONDecoder* decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
			_bundleInfo = [[decoder objectWithData:jsonData] retain];
			
			NSLog(@"Loaded Bundle Info: %@", _bundleInfo);
			NSLog(@"Loaded? %i", [self isInstalled]);
		} else {
			// TODO: error reporting
			NSLog(@"Error loading bundle: %@", bundlePath);
		}
	}
	
	return self;
}

- (NSString *) packageName {
	return [[_bundleInfo valueForKey:@"name"] lowercaseString];
}

- (NSString *) packageFullName {
	// if no full name exists titlecase the package name
	return isEmpty([_bundleInfo valueForKey:@"full_name"]) ? [[self packageName] capitalizedString] : [_bundleInfo valueForKey:@"full_name"];
}

- (NSString *) documentationDownloadPath {
	return [_bundleInfo valueForKey:@"documentation_download_url"];
}

- (NSString *) indexScriptPath {
	return !isEmpty([_bundleInfo valueForKey:@"index_script"]) ? [self _supportFilePath:[_bundleInfo valueForKey:@"index_script"]] : nil;
}

//- (NSString *) pluginStructurePath {
//	
//}

- (NSString *) customCSSFilePath {
	return [_bundleInfo valueForKey:@"overide_css"];
}

- (NSString *) indexFileName {
		
}

//- (NSString *) _supportFilePath:(NSString *) name {
//	return [_bundlePath stringByAppendingPathComponent:name];
//}

@end
