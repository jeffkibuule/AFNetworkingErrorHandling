## AFNetworkingErrorHandling

#### A simple sample app that shows how to get HTTP error responses in AFNetworking 2.x
---

[AFNetworking](http://afnetworking.com) is one of the most popular 3rd party, open-source Cocoa frameworks that takes the pain out of complex many complex networking tasks iOS/OSX developers frequently encounter. Among other things, AFNetworking makes it easy to process data from RESTful APIs, giving you an id responseObject which you can serialize into Foundation `NSArray`, `NSDictionary`, `NSString`, and `NSNumber` data structures your model classes can use. However, not all API calls are successful (sometimes the server is down!) so we need to properly handle errors should they occur.

We've all tried inspecting and logging the `NSError` in the failure block of an AFHTTPSessionManager request to make heads or tails of why a particular request failed during development only to get this:
```
2015-01-30 00:09:22.913 AFNetworkingErrorHandling[12816:637494] AFNetworking error response: Error Domain=com.alamofire.error.serialization.response Code=-1011 "Request failed: bad request (400)" UserInfo=0x7fdc4c3627f0 {com.alamofire.serialization.response.error.response=<NSHTTPURLResponse: 0x7fdc4a71ba10> { URL: https://api.twitter.com/1.1/statuses/mentions_timeline.json?count=2&since_id=14927799 } { status code: 400, headers {
"Content-Encoding" = deflate;
"Content-Length" = 74;
"Content-Type" = "application/json;charset=utf-8";
Date = "Fri, 30 Jan 2015 06:09:22 UTC";
Server = "tsa_a";
"Strict-Transport-Security" = "max-age=631138519";
"x-connection-hash" = 3d666c379f25e7a1d8ad46e88ce2be93;
"x-response-time" = 2;
"x-spdy-version" = "3.1-NPN";
} }, NSErrorFailingURLKey=https://api.twitter.com/1.1/statuses/mentions_timeline.json?count=2&since_id=14927799, com.alamofire.serialization.response.error.data=<7b226572 726f7273 223a5b7b 226d6573 73616765 223a2242 61642041 75746865 6e746963 6174696f 6e206461 7461222c 22636f64 65223a32 31357d5d 7d>, NSLocalizedDescription=Request failed: bad request (400)}
```

When instead what you as a developer would really like to see is an `NSDictionary` like this:

```
2015-01-30 00:09:22.913 AFNetworkingErrorHandling[12816:637494] 
AFNetworking error response body: {
    errors =     (
        {
            code = 215;
            message = "Bad Authentication data";
        }
    );
}
```

Searching the Internet has several solutions to this problem, including subclassing `AFJSONResponseSerializer` and implementing a custom version of this method:
```objc
- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
```

These two blogposts go into good detail with how to solve this problem that way:

* [Retrieving Response Body via AFNetworking with an HTTP Error Status Code](http://blog.gregfiumara.com/archives/239)
* [Accessing the response body in failure blocks with AFNetworking 2](http://www.splinter.com.au/2014/09/10/afnetworking-error-bodies/)


However, there actually exists a much simpler solution that doesn't require subclassing! If you peek into the userInfo dictionary and look at the `AFNetworkingOperationFailingURLResponseDataErrorKey` key, you get the response you're looking for as an `NSData` object. You can then transform that data into an NSDictionary using the NSJSONSerialization class.

Here's how that would be implemented:

```objc
NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
```

Within this simple sample app, I send a GET request to Twitter from their developer documentation that fails due to a lack of authentication. I subclass `AFHTTPSessionManager` as custom `ErrorSessionManager` and set the base URL to: `https://api.twitter.com/` so all requests have that base URL. I then make the request, which I expect to fail, print out the NSError object, then the failure response body, and finally access the dictionary to get a clear message that is presentable to a user.

Here's the complete request:

```objc
NSString *samplePath = @"1.1/statuses/mentions_timeline.json?count=2&since_id=14927799";

// This call will fail without proper Twitter authenticaion
[[ErrorSessionManager sharedInstance] GET:samplePath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // Log success response
        NSLog(@"AFNetworking success response body: %@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {   
        // Log error object
        NSLog(@"AFNetworking error response: %@\n\n\n", error);

        // Use the appropriate key to get the error data
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];

        // Serialize the data into JSON
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];

        // Print out the error JSON body
        NSLog(@"AFNetworking error response body: %@\n\n\n", serializedData);

        // Get the specific error cause and log it
        NSLog(@"Error reason: %@", [serializedData valueForKeyPath:@"errors.message"][0]);

        // Present that same error cause to the user
        NSString *message = [NSString stringWithFormat:@"Failed to GET Twitter data with reason: %@", [serializedData valueForKeyPath:@"errors.message"][0]];
        UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
        [errorController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];

        [self presentViewController:errorController animated:YES completion:nil];
    }];
```

That's it! Hopefully this simplifies your error handling code when using AFNetworking 2.x in your applications.