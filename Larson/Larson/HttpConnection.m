//
//  HttpConnection.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 19/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "HttpConnection.h"

@implementation HttpConnection

- (id) initWithServerURL:(NSString*)serverURL withPostString:(NSString*)postString
{
    self = [super init];
    
	if (self)
	{
		if (serverURL)		// For test purpose
		{
            NSData*	postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSString* postLength = [NSString stringWithFormat:@"%d", [postData length]];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kServerURL,serverURL]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
			_urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		}
	}
	return self;
}

- (void) setDelegate:(id)delegate
{
    _delegate = delegate;   // just referance
}

- (void) setRequestType:(RequestType)requestType
{
    _requestType = requestType;
}

- (RequestType) requestType
{
    return _requestType;
}

#pragma mark-

- (void) connection: (NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
	assert(_urlConnection == connection);
	
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	NSUInteger responseStatusCode = [httpResponse statusCode];
	if (responseStatusCode != 200)
	{
		[_delegate httpConnection:self didFailWithError:[NSError errorWithDomain:@"Bad Request" code:0 userInfo:nil]];
	}
}

- (void) connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    assert(_urlConnection == connection);
    
	if (_responseData == nil)
		_responseData = [[NSMutableData alloc] initWithData:data];
	else
		[_responseData appendData:data];
}

- (void) connection: (NSURLConnection*)connection didFailWithError:(NSError*)error
{
	assert(_urlConnection == connection);
    _urlConnection = nil;
    [_delegate httpConnection:self didFailWithError:error];
}

- (void) connectionDidFinishLoading: (NSURLConnection*)connection
{
	assert(_urlConnection == connection);
	
	_urlConnection = nil;
	//NSLog(@"Loading Finish");
    [_delegate httpConnection:self didFinishedSucessfully:_responseData];
}

- (void) cancelCurrentServerConnection
{
	[_urlConnection cancel];
    _urlConnection = nil;
}

#pragma mark -

- (id) responseData
{
	if (_responseData != nil)
	{
        NSError *error = nil;
        id response = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingAllowFragments error:&error];
        if (error == nil)
        {
            return response;
        }
        else
        {
            return nil;
        }
	}
	return nil;
}

- (void) logResponse
{
	//NSLog(@"Response Received: %@",[[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] autorelease]);
}

@end
