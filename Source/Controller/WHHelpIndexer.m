//
//  PHHelpIndexer.m
//  PyHelp
//
//  Created by Michael Bianco on 4/24/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "WHHelpIndexer.h"

#import "AMURLLoader.h"
#import "WHSupportFolder.h"
#import "WHOutlineDataSource.h"
#import "WHWebController.h"
#import "WHShared.h"

static WHHelpIndexer *_sharedController;

@implementation WHHelpIndexer
+ (WHHelpIndexer *) sharedController {
	return _sharedController;
}

- (id) init {
	if(self = [super init]) {
		extern WHHelpIndexer *_sharedController;
		_sharedController = self;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidTerminate:) name:NSTaskDidTerminateNotification object:nil];		
	}
	
	return self;
}

- (void) awakeFromNib {
	[oProgress setUsesThreadedAnimation:YES];
	[oProgress setAnimationDelay:2];
}

#pragma mark -
#pragma mark Actions

- (IBAction) startIndexing:(id)sender {
	[self setCurrentStep:WHNothing];
	[oStopIndexButton setTitle:NSLocalizedString(@"Stop Indexing", nil)];
	[oSheetWindow setDefaultButtonCell:nil];
	
	[NSApp beginSheet:oSheetWindow modalForWindow:oMainWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
	
	[_indexerInfo performActionForStep:_currentStep withController:self];
}

- (IBAction) stopIndexing:(id)sender {
	NSLog(@"Stop Indexing");
	
	switch(_currentStep) {
		case WHDownloadHelpDocs:
			[_downloader cancel];
			[self setDownloader:nil];
			break;
		case WHUncompressHelpDocs:
			[_task terminate];
			break;
		case WHIndexHelpDocs:
			[_task terminate];
			break;
	}
	
	//[NSApp endSheet:oSheetWindow returnCode:1];
	[NSApp endSheet:oSheetWindow];
	
	// sent to the plugin list
	// so it knows when to reload the plugin
	[_pluginList indexingOperationComplete:self];
}

- (void) runCommand:(NSString *)command withArgs:(NSArray *)args {
	NSLog(@"%@", args);
	// convience function for running commands
	// the CWD is the support folder for the current plugin

	_task = [NSTask new];
	[_task setCurrentDirectoryPath:[[WHSupportFolder sharedController] supportFolderForPlugin:_indexerInfo]];
	[_task setLaunchPath:command];
	if(!isEmpty(args)) [_task setArguments:args];
	[_task launch];
}

- (void) downloadHelpArchiveAtURL:(NSURL *)url {
	AMURLLoader *loader = [AMURLLoader loaderWithURL:url target:self selector:@selector(didReceiveData:context:) userInfo:nil];
	[loader setDelegate:self];
	
	// make sure the progress indicater is set correctly
	[oProgress setIndeterminate:NO];
	[oProgress setDoubleValue:0.0];
	
	[self setDownloader:loader];
	
	// download the documenation
	[loader load];
}

#pragma mark -
#pragma mark Accessors

- (void) setPluginList:(WHPluginList *)aValue {
	[aValue retain];
	[_pluginList release]; 
	_pluginList = aValue;
}

- (NSString *) status {
	return _status;
}
 
- (void) setStatus:(NSString *)aValue {
	[aValue retain];
	[_status release]; 
	_status = aValue;
}

- (int) currentStep {
	return _currentStep;
}

- (void) setCurrentStep:(int)aValue {
	_currentStep = aValue;
	
	switch(_currentStep) {
		case WHDownloadHelpDocs:
			[self setStatus:NSLocalizedString(@"Downloading Documentation...", nil)];
			break;
		case WHUncompressHelpDocs:
			[self setStatus:@"Uncompressing files..."];
			break;
		case WHIndexHelpDocs:
			[self setStatus:@"Indexing Documentation..."];
			break;
		case WHComplete:
			[oProgress stopAnimation:self];
			[oStopIndexButton setTitle:@"Load Indexed Documentation"];
			[oSheetWindow setDefaultButtonCell:[oStopIndexButton cell]];
			[self setStatus:@"Finished!"];
			break;
	}
}

- (AMURLLoader *) downloader {
	return _downloader;
}

- (void) setDownloader:(AMURLLoader *)aValue {
	[aValue retain];
	[_downloader release]; 
	_downloader = aValue;
}

- (NSString *) archivePath {
	return _archivePath;	
}

- (void) setArchivePath:(NSString *)path {
	[path retain];
	[_archivePath release];
	_archivePath = path;
}

- (long long) expectedDataLength {
	return _expectedDataLength;
}

- (void) setExpectedDataLength:(long long)aValue {
	_expectedDataLength = aValue;
}

- (void) setIndexerInformation:(id <WHDataSource>)info {
	[info retain];
	[_indexerInfo release];
	_indexerInfo = info;
}

- (NSString *) pythonSupportPath {
	
}

#pragma mark -
#pragma mark Delegate/Notification Methods

- (void) sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSLog(@"Done! %i", returnCode);
	[oSheetWindow orderOut:self];
	
	if(_currentStep == WHIndexComplete) {
		NSLog(@"complete?");
		//[self checkIndexStatus];
	}
}

// for NSTask
- (void) taskDidTerminate:(NSNotification *)aNotification {
	NSLog(@"TASK TERM!!");
	if([aNotification object] == _task) {
		NSLog(@"%@", aNotification);
		int termStat = [_task terminationStatus];
		
		// release the previous task
		[_task release];
		_task = nil;

		if(termStat == 0) {
			switch(_currentStep) {
				case WHUncompressHelpDocs:
					[[NSFileManager defaultManager] removeFileAtPath:_archivePath handler:nil];
					break;
				case WHIndexHelpDocs:
					break;
			}
			
			// this is called after the _currentStep has been performed
			[_indexerInfo performActionForStep:_currentStep withController:self];
		} else {
			NSLog(@"Termination error");
		}
	} else {
		NSLog(@"Other task");
	}
}

// NSFileHandle notification method (from NSTask)
- (void) didReceiveData:(NSData *)data context:(NSDictionary *)context {
	// at this point we have recieved all the data for the file we were downloading
	// unzip cant process data from stdin so we have to write the data and then unzip it
	// in the future I should ask the plugin if we need to uncompress the documentation
	// and determine the right documentation from the file extension

	if(!isEmpty(data)) {
		NSString *downloadName = [[[_downloader URL] absoluteString] lastPathComponent];
		NSString *supportFolder = [[WHSupportFolder sharedController] supportFolderForPlugin:_indexerInfo];
		NSString *downloadedFile = [supportFolder stringByAppendingPathComponent:downloadName];
		
		// write the file to disk, and uncompress it
		[data writeToFile:downloadedFile atomically:YES];
		[self setArchivePath:downloadedFile];
				
		[_indexerInfo performActionForStep:_currentStep withController:self];
		
		[oProgress setIndeterminate:YES];
		[oProgress startAnimation:self];
		[self setCurrentStep:WHUncompressHelpDocs];
	} else {
		// there was an error loading the archive file
		
		NSString *errorString = [NSString stringWithFormat:@"The documentation download failed with reason: %@. Would you like to try again?", [[context objectForKey:@"error"] localizedDescription]];
		
		if(NSRunAlertPanel(NSLocalizedString(@"Load Error", nil),
						   NSLocalizedString(errorString, nil),
						   NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil), nil) == NSOKButton) {
			[_indexerInfo performActionForStep:_currentStep - 1 withController:self];
		} else {
			[self stopIndexing:self];
		}
	}
}

// AMURLoader Delegate Methods
- (void)loader:(AMURLLoader *)loader willReceiveDataOfLength:(long long)length {
	[self setExpectedDataLength:length];
}

- (void)loader:(AMURLLoader *)loader didReceiveDataOfLength:(long long)length {
	double newProgress = (double)length/_expectedDataLength * 100.0;
	[oProgress incrementBy:newProgress - [oProgress doubleValue]];
}
@end
