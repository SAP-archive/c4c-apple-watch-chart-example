//
//  ODataRequest.m
/*
Copyright 2015 SAP America Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#import "ODataRequest.h"
#import "UserContext.h"
@interface ODataRequest()

@property (nonatomic, strong)NSMutableURLRequest* request;


@end
@implementation ODataRequest
- (instancetype)initWith:(NSString*)baseURL withQueryParams:(NSDictionary*)queryParams andHeaderParams:(NSDictionary*)headerParams
{
    self = [super init];
    if (self) {
        [self _createRequest:baseURL withQueryParams:queryParams andHeaderParams:headerParams];
        self.requestStartTime = [NSDate date];
        
    }
    return self;
}


-(void)fireRequestWithCompletionHandler:(void (^)(NSDictionary *data, NSError *error,ODataRequest*_self))callBack{
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:self.request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if(connectionError || httpResponse.statusCode != 200) {
            callBack( nil, connectionError,self);
        } else {
            NSError *error = nil;
            if(data){

                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if(!error) {
                    NSLog(@"pure string with :%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
                    NSLog(@"result was coming" );
                    callBack( result, connectionError,self);
                } else {
                    
                    callBack( nil, error, self);
                }
            }
            
            
        }
    }];
}


-(void)_createRequest:(NSString*)baseURL withQueryParams:(NSDictionary*)queryParams andHeaderParams:(NSDictionary*)headerParams{
    
    NSMutableString* compiledURL = [NSMutableString stringWithString:baseURL];
    [compiledURL appendString:@"?"];
    //make sure we get JSON
    if(![queryParams objectForKey:@"$format"]){
        
        [compiledURL appendString:@"$format=json"];
        
    }
    //query params
    if(queryParams&&[queryParams count]>0){
        
       
        [queryParams enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL *stop) {
           
            [compiledURL appendString:@"&"];
            [compiledURL appendString:key];
            [compiledURL appendString:@"="];
            [compiledURL appendString:obj];
            
        }];
        
    }
    NSString* finalString = [(NSString*)[compiledURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
   
    NSLog(@"calling url: %@",finalString);
     NSLog(@"length: %lu",(unsigned long)[finalString length]);

    NSURL* url = [NSURL URLWithString:finalString];
    self.request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:100];
    [self.request setHTTPMethod:@"GET"];
  
    if(headerParams&&[headerParams count]>0){
    
        [headerParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            [self.request addValue:(NSString*)obj forHTTPHeaderField:(NSString*)key];
            
        }];
    }
    
    //authorization
    NSString *loginString = [self _getLoginString];
    NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [[loginString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
    
    [self.request addValue:authHeader forHTTPHeaderField:@"Authorization"];
}



-(NSString*)_getLoginString{
    
   CredentialObject* credentials = [[UserContext sharedInstance] getCredentials];
   return  [NSString stringWithFormat:@"%@:%@", credentials.username, credentials.password];

}
@end
