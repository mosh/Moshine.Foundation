﻿// Header generated by RemObjects Elements for Cocoa 

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#import <objc/NSObject.h>
#import <Foundation/Foundation.h>
#import <dispatch/semaphore.h>

@class __Moshine_Foundation_ApplicationHelpers;
@class __Moshine_Foundation_DateUtils;
@class __Moshine_Foundation_ProxyException;
@class __Moshine_Foundation_HttpStatusCodeException;
@class __Moshine_Foundation_AuthenticationRequiredException;
@class __Moshine_Foundation_MissingAuthTokenException;
@class __Moshine_Foundation_NoNetworkConnectionException;
@class __Moshine_Foundation_ProxyFormatException;
@class __Moshine_Foundation_Web_HttpRequest;
@class __Moshine_Foundation_Reachability;
@class __Moshine_Foundation_Web_WebProxy;

typedef NSException PlatformException;
typedef NSMutableURLRequest PlatformHttpRequest;
typedef /* mapped */ NSMutableURLRequest * _Null_unspecified(^ _Null_unspecified RequestBuilderDelegate)(/* mapped */ PlatformString _Null_unspecified url, /* mapped */ PlatformString _Null_unspecified webMethod, BOOL addAuthentication);
@interface __Moshine_Foundation_ApplicationHelpers: NSObject

+ (NSString * _Null_unspecified)appVersion;

@end

@interface __Moshine_Foundation_DateUtils: NSObject

+ (NSDate * _Null_unspecified)epochToDate:(double)epoch;

@end

@interface __Moshine_Foundation_ProxyException: NSException

- (instancetype _Null_unspecified)initWithName:(NSExceptionName _Null_unspecified)aName reason:(NSString * _Null_unspecified)aReason userInfo:(NSDictionary * _Null_unspecified)aUserInfo;
- (instancetype _Null_unspecified)initWithName:(NSExceptionName _Null_unspecified)aName reason:(NSString * _Null_unspecified)aReason userInfo:(NSDictionary * _Null_unspecified)aUserInfo FromUrl:(NSString * _Null_unspecified)aUrl;

@property (strong) NSString *Url;

@end

@interface __Moshine_Foundation_HttpStatusCodeException: __Moshine_Foundation_ProxyException

- (instancetype _Null_unspecified)initWithName:(NSExceptionName _Null_unspecified)aName reason:(NSString * _Null_unspecified)aReason userInfo:(NSDictionary * _Null_unspecified)aUserInfo StatusCode:(int32_t)aCode FromUrl:(NSString * _Null_unspecified)aUrl;

@property (assign) int32_t StatusCode;

@end

@interface __Moshine_Foundation_AuthenticationRequiredException: __Moshine_Foundation_ProxyException
@end

@interface __Moshine_Foundation_MissingAuthTokenException: __Moshine_Foundation_AuthenticationRequiredException
@end

@interface __Moshine_Foundation_NoNetworkConnectionException: __Moshine_Foundation_ProxyException
@end

@interface __Moshine_Foundation_ProxyFormatException: __Moshine_Foundation_ProxyException
@end

@interface __Moshine_Foundation_Reachability: NSObject
@end

@interface __Moshine_Foundation_Web_WebProxy: NSObject

{
  RequestBuilderDelegate _requestBuilder;
};


@end

#define __Moshine_Foundation_Web_WebProxy_UnknownHttpStatusCode 0

