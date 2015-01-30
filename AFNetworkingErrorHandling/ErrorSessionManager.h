//
//  ErrorSessionManager.h
//  AFNetworkingErrorHandling
//
//  Created by Joefrey Kibuule on 1/29/15.
//  Copyright (c) 2015 Joefrey Kibuule. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

@interface ErrorSessionManager : AFHTTPSessionManager

+ (instancetype)sharedInstance;

@end
