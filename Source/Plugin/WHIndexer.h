//
//  WHIndexerInformation.h
//  PyHelp
//
//  Created by Michael Bianco on 5/31/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol WHIndexer
// command methods
- (void) downloadHelpArchiveAtURL:(NSURL *)url;
- (void) runCommand:(NSString *)command withArgs:(NSArray *)args;

// accessors
- (int) currentStep;
- (void) setCurrentStep:(int)aValue;

- (NSString *) archivePath;
@end