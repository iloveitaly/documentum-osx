//
//  AMURLLoader.h
//  FavIconTest
//
//  Created by Andreas on 13.09.04.
//  Copyright 2004 Andreas Mayer. All rights reserved.
//
//  2004-11-23	Andreas Mayer
//	- added delegate
//	- init/loaderWithURL will no longer call load automatically
//	- removed init/loaderWithURL:...cachePolicy:timeoutInterval:


#import <Cocoa/Cocoa.h>


@interface AMURLLoader : NSObject {
	NSMutableData *receivedData;
	NSURLRequest *request;
	NSURLConnection *connection;
	NSMutableDictionary *context;
	NSURL *url;
	id target;
	SEL selector;
	id delegate;
}

+ (AMURLLoader *)loaderWithURL:(NSURL *)url target:(id)target selector:(SEL)selector userInfo:(id)theUserInfo;

- (id)initWithURL:(NSURL *)url target:(id)target selector:(SEL)selector userInfo:(id)theUserInfo;
// Does not retain target.
// Expected selector signature:
// - (void)receivedData:(NSData *)data context:(NSDictionary *)context;
// If an error occured, data will be nil.
// The context dictionary may contain:
// key:@"userInfo" value:the user info provided with the init message
// key:@"error" value:NSError object
// key:@"response" value:NSURLResponse object (may be NSHTTPURLResponse - check class)

- (NSURL *)URL;
- (void)setURL:(NSURL *)newURL;

- (id)target;
- (void)setTarget:(id)newTarget;

- (SEL)selector;
- (void)setSelector:(SEL)newSelector;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (void)load;
- (void)cancel;

- (void)loadWithCachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;

@end

// delegate interface

@interface NSObject (AMURLLoaderDelegate)
- (void)loader:(AMURLLoader *)loader willReceiveDataOfLength:(long long)length;
// tells the delegate how many bytes are to be expected
- (void)loader:(AMURLLoader *)loader didReceiveDataOfLength:(long long)length;
// tells the delegate how many bytes have been received up until now (cumulated)
@end

