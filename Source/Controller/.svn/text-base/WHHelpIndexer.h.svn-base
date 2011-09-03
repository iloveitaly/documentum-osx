//
//  WHHelpIndexer.h
//  PyHelp
//
//  Created by Michael Bianco on 4/24/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WHDataSource.h"
#import "WHIndexer.h"

@class AMURLLoader, WHPluginList;

@interface WHHelpIndexer : NSObject <WHIndexer> {
	IBOutlet NSWindow *oMainWindow;
	IBOutlet NSWindow *oSheetWindow;
	IBOutlet NSProgressIndicator *oProgress;
	IBOutlet NSButton *oStopIndexButton;
	
	// general
	WHPluginList *_pluginList;
	
	// archive loader vars
	long long _expectedDataLength;
	NSString *_archivePath;
	AMURLLoader *_downloader;
	
	// status/steps vars
	int _currentStep;
	NSString *_status;
	NSTask *_task;
	id _indexerInfo;
}

+ (WHHelpIndexer *) sharedController;

- (IBAction) startIndexing:(id)sender;
- (IBAction) stopIndexing:(id)sender;

// methods called by the plugin object
// helps create the documentation and such for the 'running' plugin
- (void) downloadHelpArchiveAtURL:(NSURL *)url;
- (void) runCommand:(NSString *)command withArgs:(NSArray *)args;

// Accessors
- (NSString *) status;
- (void) setStatus:(NSString *)aValue;

- (int) currentStep;
- (void) setCurrentStep:(int)aValue;

- (AMURLLoader *) downloader;
- (void) setDownloader:(AMURLLoader *)aValue;

- (NSString *) archivePath;
- (void) setArchivePath:(NSString *)path;

- (long long) expectedDataLength;
- (void) setExpectedDataLength:(long long)aValue;

- (void) setPluginList:(WHPluginList *)aValue;
- (void) setIndexerInformation:(id <WHDataSource>)info;
@end
