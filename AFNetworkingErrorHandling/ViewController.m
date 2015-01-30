//
//  ViewController.m
//  AFNetworkingErrorHandling
//
//  Created by Joefrey Kibuule on 1/29/15.
//  Copyright (c) 2015 Joefrey Kibuule. All rights reserved.
//

#import "ViewController.h"
#import "ErrorSessionManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getTwitterStatus];
}

- (void)getTwitterStatus {
    NSString *samplePath = @"1.1/statuses/mentions_timeline.json?count=2&since_id=14927799";
    
    // This call will fail without proper Twitter authenticaion
    [[ErrorSessionManager sharedInstance] GET:samplePath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // Log success response
        NSLog(@"AFNetworking success response body: %@", responseObject);
        
        // Process response data here
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // Log error object
        NSLog(@"AFNetworking error response: %@\n\n\n", error);
        
        // Use the appropriate key to get the error data
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        // Serialize the data into JSON
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        
        // Print out the error JSON body
        NSLog(@"AFNetworking error response body: %@", serializedData);
        
        // Get the first error cause and log it
        NSDictionary *failureError = serializedData[@"errors"][0];
        NSLog(@"Error reason: %@", failureError);
        
        // Present that same error cause to the user
        NSString *message = [NSString stringWithFormat:@"Failed to GET Twitter data with reason: %@", failureError[@"message"]];
        UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
        [errorController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:errorController animated:YES completion:nil];
    }];
}

@end
