//
//  PHSplitView.m
//  PyHelp
//
//  Created by Michael Bianco on 4/11/07.
//  Copyright 2007 Prosit Software. All rights reserved.
//

#import "PHSplitView.h"


@implementation PHSplitView
- (id) initWithCoder:(NSCoder *)decoder {
	if(self = [super initWithCoder:decoder]) {
		_splitImage = [[NSImage imageNamed:@"SplitBar"] retain];
	}
	
	return self;
}

- (float) dividerThickness {
	return 8.0;
}

- (void)drawDividerInRect:(NSRect)aRect {
	[_splitImage setSize:aRect.size];
	
	NSSize barSize = [_splitImage size];
	NSRect barRect = NSMakeRect(0, 0, barSize.width, barSize.height);
	
	[self lockFocus];
	[_splitImage drawAtPoint:aRect.origin fromRect:barRect operation:NSCompositeSourceOver fraction:1.0];
	[self unlockFocus];
}
@end
