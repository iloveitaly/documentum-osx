//
//  NSString+Levenshtein.h
//  PyHelp
//
//  Created by Michael Bianco on 12/2/11.
//  Copyright (c) 2011 MAB Web Design. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Levenshtein)

// calculate the smallest distance between all words in stringA and stringB
- (float) compareWithString: (NSString *) stringB matchGain:(int)gain missingCost:(int)cost;

// calculate the distance between two string treating them each as a single word
- (int) compareWithWord:(NSString *) stringB matchGain:(int)gain missingCost:(int)cost;
@end
