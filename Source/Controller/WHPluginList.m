//
//  WHPluginList.m
//  PyHelp
//
//  Created by Michael Bianco on 7/14/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "WHPluginList.h"
#import "WHHelpIndexer.h"
#import "WHOutlineDataSource.h"
#import "WHWebController.h"
#import "WHSupportFolder.h"
#import "WHPluginBundle.h"
#import "WHShared.h"

static WHPluginList *_sharedController;

@implementation WHPluginList
+ (WHPluginList *) sharedController {
	return _sharedController;
}

- (id) init {
	if(self = [super init]) {
		extern WHPluginList *_sharedController;
		_sharedController = self;
		
		_isEmpty = NO;
		
		// plugin development: http://www.far-blue.co.uk/hacks/plugin-frameworks.html
		// undefined symbol error: http://www.borkware.com/quickies/one?topic=Xcode
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillFinishLaunching:) name:NSApplicationWillFinishLaunchingNotification object:nil];
		
		//[self setPluginList:[NSArray arrayWithObjects:[PHDataSource new], [PHPDataSource new], [CSSDataSource new], nil]];
	}
	
	return self;
}

- (void) awakeFromNib {
	[[WHHelpIndexer sharedController] setPluginList:self];
}

#pragma mark -
#pragma mark Plugin Loading

- (void) findAvailablePlugins {
	NSMutableArray *list = [NSMutableArray array];
	
	// load native plugins
	NSString* nativePluginsFolder = [[NSBundle mainBundle] builtInPlugInsPath];
	Class pluginClass;
	
	if (nativePluginsFolder) {
		NSEnumerator* enumerator = [[NSBundle pathsForResourcesOfType:@"plugin" inDirectory:nativePluginsFolder] objectEnumerator];
		NSString* pluginPath;
		
		while(pluginPath = [enumerator nextObject]) {
			if(pluginClass = [self loadPlugin:pluginPath]) {
				[list addObject:[[pluginClass new] autorelease]];
				NSLog(@"Plugin Name %@", [[list lastObject] packageName]);
			} else {
				// error
				NSLog(@"Error loading plugin");
			}
		}
	}
	
	// load 'proxy' or 'light' plugins
	NSString *bundleFolder = [[WHSupportFolder sharedController] bundleFolder], *bundleName;
	NSDirectoryEnumerator *simplePluginEnum = [[NSFileManager defaultManager] enumeratorAtPath:bundleFolder];
	WHPluginBundle *newBundle;
	
	while ((bundleName = [simplePluginEnum nextObject] )) {
		if ([bundleName hasSuffix:@".docbundle"]) {
			@try {
				newBundle = [[[WHPluginBundle alloc] initBundleWithPath:[bundleFolder stringByAppendingPathComponent:bundleName]] autorelease];
				[list addObject:newBundle];
			}
			@catch (NSException *exception) {
				NSLog(@"Error loading bundle: %@. Reason: %@", bundleName, [exception reason]);
			}
			@finally {
				
			}
		}
	}
	
	[self setPluginList:list];
}

- (Class) loadPlugin:(NSString*)path {
	// NSLog(@"Activate %@", path);
	NSBundle* pluginBundle = [NSBundle bundleWithPath:path];
	
	if (pluginBundle) {
		NSDictionary* pluginDict = [pluginBundle infoDictionary];
		NSString* pluginName = [pluginDict objectForKey:@"NSPrincipalClass"];

		if (pluginName) {
			Class pluginClass = NSClassFromString(pluginName);
			if(!pluginClass) { // if the class already exists then the class has already been used
				pluginClass = [pluginBundle principalClass];
				
				if([pluginClass conformsToProtocol:@protocol(WHDataSource)] && [pluginClass isKindOfClass:[NSObject class]]) {
					return pluginClass;
				} else {
					NSLog(@"Class %@ does not conform to WHDataSource protocol", pluginName);
				}
			} else {
				// error: class with this name already exists
				NSLog(@"Class with name %@ already exists", pluginName);
			}
		}
	}
	
	return nil;
}

- (void) findAvailableBundles {
	
}

#pragma mark -
#pragma mark Accessors


- (BOOL) isEmptyPlugin {
	return _isEmpty;
}

- (void) setIsEmptyPlugin:(BOOL)empty {
	_isEmpty = empty;
}

- (NSArray *) pluginList {
	return _pluginList;
}

- (void) setPluginList:(NSArray *)aValue {
	[aValue retain];
	[_pluginList release]; 
	_pluginList = aValue;
}

- (id <WHDataSource>) selectedPlugin {
	return _selectedPlugin;
}

- (void) setSelectedPlugin:(id <NSObject, WHDataSource>)aValue {
	if(aValue != _selectedPlugin) {
		[aValue retain];
		[_selectedPlugin release];
		_selectedPlugin = aValue;
		
		if([_selectedPlugin isInstalled]) {
			[self setIsEmptyPlugin:NO];
			[[WHOutlineDataSource sharedController] activateSelectedPlugin];
		} else {
			[[WHHelpIndexer sharedController] setIndexerInformation:_selectedPlugin];
			[[WHHelpIndexer sharedController] startIndexing:self];
		}
	}
}

#pragma mark -
#pragma mark Delegate/Notification Methods

- (void)applicationWillFinishLaunching:(NSNotification*)notification {
	[self findAvailablePlugins];
	[self setSelectedPlugin:[_pluginList lastObject]];
}

- (void) indexingOperationComplete:(WHHelpIndexer *)indexer {
	// we always set this var since some are watching the value
	[self setIsEmptyPlugin:![_selectedPlugin isInstalled]];
	
	[[WHOutlineDataSource sharedController] activateSelectedPlugin];
}
@end
