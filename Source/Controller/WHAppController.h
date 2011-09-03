//
//  WHAppController.h
//  PyHelp
//
//  Created by Michael Bianco on 4/9/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WHAppController : NSObject {
	IBOutlet NSWindow *oMainWindow;
}

- (IBAction) gotoHomePage:(id)sender;
@end
