//
//  DataFacade.m
//  ODataExample
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

#import "DataFacade.h"
#import "DataProvider.h"
#import "ProviderFactory.h"
#import "Constants.h"
@interface DataFacade ()

@property(strong, nonatomic) id <DataProvider> c4cDataProvider;

@end


@implementation DataFacade


+ (id)sharedInstance {
    static DataFacade *instance = nil;
    
    static dispatch_once_t dispatchToken;
    dispatch_once(&dispatchToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


-(void)getAccountsForTop:(NSNumber*)top andSkip:(NSNumber*)skip withCallBack:(void(^)(NSDictionary *replyInfo))replyCallback{
   self.c4cDataProvider = [ProviderFactory createOrRenewDataProvider:self.c4cDataProvider];
    [self.c4cDataProvider getAccountCollectionWithTop:top andSkip:skip andCallBack:^(NSArray *data, NSError *error) {
        NSLog(@"found accounts %@",data);

        if(!data){
            data = @[];
        }
        [self _sendReply:@{COLLECTIION_ACCOUNT:data, @"error":(error ? error : [NSNull null])} withCallback:replyCallback];
        
    } ];
}

-(void)getExpectedValueAndOpportunitiesForAccount:(NSString*)accountID withCallBack:(void(^)(NSDictionary *replyInfo))replyCallback{
    self.c4cDataProvider = [ProviderFactory createOrRenewDataProvider:self.c4cDataProvider];
    [self.c4cDataProvider getExpectedValueAndOpportunitiesForAccount:accountID andCallBack:^(NSArray *data, NSError *error) {
        NSLog(@"found opportunityies %@",data);
        if(!data){
            data = @[];
        }
        [self _sendReply:@{COLLECTIION_OPPORTUNITY:data} withCallback:replyCallback];
        
    } ];
}


-(void)_sendReply:(NSDictionary*)data withCallback:(void(^)(NSDictionary *replyInfo))replyCallback{
    if(replyCallback){
        
        replyCallback(data);
        
    }
    else{
        NSLog(@"could not call back");
    }
}

@end
