/*
 *  encrypt_main.c
 *  PyHelp
 *
 *  Created by Michael Bianco on 4/24/07.
 *  Copyright 2007 Prosit Software. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

#import "MABEncrypt.h"

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSArray *args = [[NSProcessInfo processInfo] arguments];
	
	if([args count] < 4) {
		if([args count] == 3) {
			NSData *fileContents = [NSData dataWithContentsOfFile:[args objectAtIndex:1]];
			NSString *password = [args objectAtIndex:2];
			
			NSLog(@"Decrypting data with file %@ and pass %@", [args objectAtIndex:1], password);
			NSData *result = DecryptData(fileContents, password);
			
			if([result length]) {
				NSLog(@"%@", [NSString stringWithCString:[result bytes] encoding:NSASCIIStringEncoding]);
			} else {
				NSLog(@"ERROR DECRYPTING DATA");
			}
			
			return 0;
		} else {			
			NSLog(@"This command requires 4 arguments");
			return 1;
		}
	}
	
	// encrypt the file
	NSString *inFile = [args objectAtIndex:1],
			 *outFile = [args objectAtIndex:2], 
			 *pass = [args objectAtIndex:3];
	
	NSLog(@"In %@, out %@, pass %@", inFile, outFile, pass);
	
	NSData *fileData = [NSData dataWithContentsOfFile:inFile];
	NSData *encryptedData = EncyptData(fileData, pass);
	[encryptedData writeToFile:outFile atomically:YES];
	
	[pool release];
	
	return 0;	
}