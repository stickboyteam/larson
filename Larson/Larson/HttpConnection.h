//
//  HttpConnection.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 19/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpConnectionDelegate <NSObject>

- (void) httpConnection:(id)handler didFailWithError:(NSError*)error;
- (void) httpConnection:(id)handler didFinishedSucessfully:(NSData*)data;

@end

@interface HttpConnection : NSObject
{
	NSURLConnection*	_urlConnection;
	NSMutableData*		_responseData;
    
	id <HttpConnectionDelegate> _delegate;
    
    RequestType _requestType;
}

- (id) initWithServerURL:(NSString*)serverURL withPostString:(NSString*)postString;
- (void) setDelegate:(id)delegate;
- (void) setRequestType:(RequestType)requestType;


- (id) responseData;
- (RequestType) requestType;

- (void) logResponse;
- (void) cancelCurrentServerConnection;

@end
