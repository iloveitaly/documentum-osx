//
//  AMURLLoader.m
//  FavIconTest
//
//  Created by Andreas on 13.09.04.
//  Copyright 2004 Andreas Mayer. All rights reserved.
//

#import "AMURLLoader.h"

@interface AMURLLoader (Private)
- (NSMutableData *)receivedData;
- (void)setReceivedData:(NSMutableData *)newReceivedData;
- (NSURLRequest *)request;
- (void)setRequest:(NSURLRequest *)newRequest;
- (NSURLConnection *)connection;
- (void)setConnection:(NSURLConnection *)newConnection;
- (NSMutableDictionary *)context;
- (void)setContext:(NSMutableDictionary *)newContext;
@end


@implementation AMURLLoader

+ (AMURLLoader *)loaderWithURL:(NSURL *)theURL target:(id)theTarget selector:(SEL)theSelector userInfo:(id)theUserInfo
{
	AMURLLoader *result = [[[AMURLLoader alloc] initWithURL:theURL target:theTarget selector:theSelector userInfo:theUserInfo] autorelease];
	return result;
}

- (id)initWithURL:(NSURL *)theURL target:(id)theTarget selector:(SEL)theSelector userInfo:(id)theUserInfo
{
	// does not retain target
	if (self = [super init]) {
		[self setReceivedData:[NSMutableData data]];
		[self setURL:theURL];
		[self setTarget:theTarget];
		[self setSelector:theSelector];
		[self setContext:[NSMutableDictionary dictionary]];
		[[self context] setObject:self forKey:@"AMURLLoader"];
		if (theUserInfo) {
			[[self context] setObject:theUserInfo forKey:@"userInfo"];
		}
		[self retain]; // do not release until done
	}
	return self;
}


- (void)dealloc
{
	[receivedData release];
	[request release];
	[connection release];
	[url release];
	[super dealloc];
}

- (NSMutableData *)receivedData
{
	return receivedData;
}

- (void)setReceivedData:(NSMutableData *)newReceivedData
{
	id old = nil;
	
	if (newReceivedData != receivedData) {
		old = receivedData;
		receivedData = [newReceivedData retain];
		[old release];
	}
}

- (NSURLRequest *)request
{
	return request;
}

- (void)setRequest:(NSURLRequest *)newRequest
{
	id old = nil;
	
	if (newRequest != request) {
		old = request;
		request = [newRequest retain];
		[old release];
	}
}

- (NSURLConnection *)connection
{
	return connection;
}

- (void)setConnection:(NSURLConnection *)newConnection
{
    id old = nil;

    if (newConnection != connection) {
        old = connection;
        connection = [newConnection retain];
        [old release];
    }
}

- (NSMutableDictionary *)context
{
	return context;
}

- (void)setContext:(NSMutableDictionary *)newContext
{
	id old = nil;
	
	if (newContext != context) {
		old = context;
		context = [newContext retain];
		[old release];
	}
}

- (NSURL *)URL
{
	return url;
}

- (void)setURL:(NSURL *)newURL
{
	id old = nil;
	
	if (newURL != url) {
		old = url;
		url = [newURL retain];
		[old release];
	}
}

- (id)target
{
	return target;
}

- (void)setTarget:(id)newTarget
{
	// do not retain target
	target = newTarget;
}

- (SEL)selector
{
	return selector;
}

- (void)setSelector:(SEL)newSelector
{
	selector = newSelector;
}

- (id)delegate
{
	return delegate; 
}

- (void)setDelegate:(id)newDelegate
{
	// do not retain delegate
	delegate = newDelegate;
}

- (void)load
{
	[self setRequest:[NSURLRequest requestWithURL:[self URL]]];
	if ([self request] != nil) {
		[self setConnection:[NSURLConnection connectionWithRequest:[self request] delegate:self]];
	}
}

- (void) cancel
{
	[connection cancel];
	[self setConnection:nil];
	[self setRequest:nil];
	[context release];
	[self release];
}

- (void)loadWithCachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval
{
	[self setRequest:[NSURLRequest requestWithURL:[self URL] cachePolicy:cachePolicy timeoutInterval:timeoutInterval]];
	if ([self request] != nil) {
		[self setConnection:[NSURLConnection connectionWithRequest:[self request] delegate:self]];
	}
}


// ============================================================
#pragma mark -
#pragma mark ━ NSURLConnection delegate methods ━
// ============================================================

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[[self context] setObject:response forKey:@"response"];
	[[self receivedData] setLength:0];
	if ((delegate) && [delegate respondsToSelector:@selector(loader:willReceiveDataOfLength:)]) {
		long long length = [response expectedContentLength];
		[delegate loader:self willReceiveDataOfLength:length];
	}
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)theRequest redirectResponse:(NSURLResponse *)redirectResponse
{
	return [[theRequest retain] autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
	if (delegate) {
		[delegate loader:self didReceiveDataOfLength:[receivedData length]];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[[self context] setObject:error forKey:@"error"];
	[[[self context] retain] autorelease];
	[target performSelector:selector withObject:nil withObject:[self context]];
	[context release];
	[self release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[[[self context] retain] autorelease];
	[target performSelector:selector withObject:[[[self receivedData] retain] autorelease] withObject:[self context]];
	[context release];
	[self release];
}


@end
