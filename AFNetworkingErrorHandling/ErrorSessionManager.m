//
//  ErrorSessionManager.m
//  AFNetworkingErrorHandling
//
//  Created by Joefrey Kibuule on 1/29/15.
//  Copyright (c) 2015 Joefrey Kibuule. All rights reserved.
//

#import "ErrorSessionManager.h"

static NSString * BASE_URL = @"https://api.twitter.com/";

@implementation ErrorSessionManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ErrorSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    });
    
    return sharedInstance;
}

@end
