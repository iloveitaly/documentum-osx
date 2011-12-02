//
//  NSString+Levenshtein.m
//  PyHelp
//
//  Created by Michael Bianco on 12/2/11.
//  Copyright (c) 2011 MAB Web Design. All rights reserved.
//

#import "NSString+Levenshtein.h"

@implementation NSString (Levenshtein)

// default match: 0
// default cost: 1

// calculate the mean distance between all words in stringA and stringB
- (float) compareWithString: (NSString *) stringB matchGain:(int)gain missingCost:(int)cost {
	float averageSmallestDistance = 0.0;
	float smallestDistance;
	
	NSString *mStringA = [self stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	NSString *mStringB = [stringB stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	
	NSArray *arrayA = [mStringA componentsSeparatedByString: @" "];
	NSArray *arrayB = [mStringB componentsSeparatedByString: @" "];
	
	for (NSString *tokenA in arrayA) {
		smallestDistance = 99999999.0;
		
		for (NSString *tokenB in arrayB) {
			smallestDistance = MIN((float) [tokenA compareWithWord:tokenB matchGain:gain missingCost:cost], smallestDistance);
		}
		
		averageSmallestDistance += smallestDistance;
	}
	
	return averageSmallestDistance / (float) [arrayA count];
}


// calculate the distance between two string treating them eash as a single word
- (int) compareWithWord:(NSString *) stringB matchGain:(int)gain missingCost:(int)cost
{
	// normalize strings
	NSString * stringA = [NSString stringWithString: self];
	stringA = [[stringA stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
	stringB = [[stringB stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];	
	
	// Step 1
	int k, i, j, change, *d, distance;
	
	int n = [stringA length];
	int m = [stringB length];	
	
	if( n++ != 0 && m++ != 0 ) {
		d = malloc( sizeof(int) * m * n );
		
		// Step 2
		for( k = 0; k < n; k++)
			d[k] = k;
		
		for( k = 0; k < m; k++)
			d[ k * n ] = k;
		
		// Step 3 and 4
		for( i = 1; i < n; i++ ) {
			for( j = 1; j < m; j++ ) {
				
				// Step 5
				if([stringA characterAtIndex: i-1] == [stringB characterAtIndex: j-1]) {
					change = -gain;
				} else {
					change = cost;
				}
				
				// Step 6
				d[ j * n + i ] = MIN(d [ (j - 1) * n + i ] + 1, MIN(d[ j * n + i - 1 ] +  1, d[ (j - 1) * n + i -1 ] + change));
			}
		}
		
		distance = d[ n * m - 1 ];
		free( d );
		return distance;
	}
	
	return 0;
}

@end
