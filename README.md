## AFNetworkingErrorHandling

A simple sample app that shows how to get HTTP error responses in AFNetworking 2.x

```
NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
```