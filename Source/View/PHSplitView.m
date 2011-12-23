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

- (CGFloat) dividerThickness {
	return 8.0;
}

// weird drawing issue, possible fix: https://github.com/osxync/xboxlivefriends/blob/b34c6c836a6e29703657a68bebd648772dea7825/src/XBSplitView.m
// BWToolkit: https://bitbucket.org/bwalkin/bwtoolkit/src/590c12e68e7a/BWTransparentScroller.m

- (void)drawDividerInRect:(NSRect)aRect {
	NSImage *splitImage = [NSImage imageNamed:@"SplitBar"];
	NSDrawThreePartImage(aRect, splitImage, splitImage, splitImage, YES, NSCompositeSourceOver, 1.0, NO);
}
@end
