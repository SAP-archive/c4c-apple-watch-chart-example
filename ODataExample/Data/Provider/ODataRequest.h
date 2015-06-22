//
//  ODataRequest.h
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

#import <Foundation/Foundation.h>

@interface ODataRequest : NSObject <NSURLConnectionDataDelegate>


@property (strong, nonatomic)NSDate*requestStartTime;
@property (strong, nonatomic)NSString*name;
@property (strong, nonatomic)NSString*login;

- (instancetype)initWith:(NSString*)baseURL withQueryParams:(NSDictionary*)queryParams andHeaderParams:(NSDictionary*)headerParams;


-(void)fireRequestWithCompletionHandler:(void (^)(NSDictionary *data, NSError *error,ODataRequest*_self))callBack;
@end
