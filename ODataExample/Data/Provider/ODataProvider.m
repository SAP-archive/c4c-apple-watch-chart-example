//
//  ODataProvider.m
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

#import "ODataProvider.h"
#import "UserContext.h"
#import "Constants.h"
#import "ODataRequest.h"

@interface ODataProvider()


@property(nonatomic, strong) NSMutableSet*runningRequests;
@end

@implementation ODataProvider


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.runningRequests = [NSMutableSet set];
    }
    return self;
}

#pragma mark request API

-(void)getAccountCollectionWithTop:(NSNumber*)top andSkip:(NSNumber*)skip andCallBack:(void (^)(NSArray *data, NSError *error))callback {
    
    //filter based on AccountName
    NSMutableDictionary* queryParams = [NSMutableDictionary dictionary];
    
    if(top){
        [queryParams setObject:[top stringValue]  forKey:QUERY_OPTION_TOP];
    }
    
    if(skip){
        [queryParams setObject:[skip stringValue]  forKey:QUERY_OPTION_SKIP];
    }

    [queryParams setObject:SELECT_ACCOUNT_ACCOUNT_NAME forKey:QUERY_OPTION_ORDERBY];
    [queryParams setObject:[NSString stringWithFormat:@"%@,%@",SELECT_ACCOUNT_ACCOUNT_NAME,FILTER_ACCOUNT_ACCOUNTID] forKey:QUERY_OPTION_SELECT];
    
    CredentialObject* credObj = [[UserContext sharedInstance] getCredentials];
    
    ODataRequest* request = [[ODataRequest alloc] initWith:[NSString stringWithFormat:@"%@%@%@",credObj.baseURL,PATH_ODATA_V1,COLLECTIION_ACCOUNT]
                                                           withQueryParams:queryParams
                                                           andHeaderParams:nil];
    request.name = [NSString stringWithFormat:@"%@_%@",COLLECTIION_ACCOUNT, [NSDate date]];
    
    [self.runningRequests addObject:request];
    
    [request fireRequestWithCompletionHandler:^(NSDictionary*data,NSError*error,ODataRequest*request){
        
        [self _handleAccountResult:request withData:data error:error andCallBack:callback];
        
    }];
}

-(void)getExpectedValueAndOpportunitiesForAccount:(NSString*)accountID andCallBack:(void (^)(NSArray *data, NSError *error))callback {

    NSMutableDictionary* queryParams = [NSMutableDictionary dictionary];
    NSMutableString*filterConditions = [NSMutableString string];
    
    [self _appendFilterValues:@[accountID] withKey:FILTER_ACCOUNT_ACCOUNTID toString:filterConditions];
    [self _appendTime:[NSDate date] withKey:OPPORTUNITY_CLOSE_DATE toString:filterConditions];
    [self _appendStatus:@"1" toString:filterConditions];
    
    [queryParams setObject:filterConditions forKey: QUERY_OPTION_FILTER];
  
    [queryParams setObject:@"10" forKey:QUERY_OPTION_TOP];
    
    CredentialObject* credObj = [[UserContext sharedInstance] getCredentials];
    
    ODataRequest* request = [[ODataRequest alloc] initWith:[NSString stringWithFormat:@"%@%@%@",credObj.baseURL,PATH_ODATA_V1, COLLECTIION_OPPORTUNITY]
                                                           withQueryParams:queryParams
                                                           andHeaderParams:nil];
    request.name = [NSString stringWithFormat:@"%@_%@",COLLECTIION_OPPORTUNITY, [NSDate date]];
    
    [self.runningRequests addObject:request];
    
    [request fireRequestWithCompletionHandler:^(NSDictionary*data,NSError*error,ODataRequest*request){

        [self _handleExpectedValueResult:request withData:data error:error andCallBack:callback];
        
    }];
    
}

#pragma mark result handlers

-(void)_handleAccountResult:(ODataRequest*)request withData:(NSDictionary*)data error:(NSError*)error andCallBack:(void (^)(NSArray *data, NSError *error))callback {
    
    if(request.requestStartTime){
        float requestTime = -1*[request.requestStartTime timeIntervalSinceNow];
        NSLog(@"****Request:%@  took : %f seconds",request.name,requestTime);
    }
    
    if(error){
        NSLog(@"ERROR with %@ %@",request.name,error);
        if(callback){
            callback(nil,error);
        }
    }else{
        
        if([data objectForKey:@"d"]&&[[data objectForKey:@"d"] objectForKey:@"results"]){
            
            NSLog(@"SUCCESS %@ has result %@  count:%lu",request.name,data,(unsigned long)[(NSArray*)[[data objectForKey:@"d"] objectForKey:@"results"] count] );
            if(callback){
                callback((NSArray*)[[data objectForKey:@"d"] objectForKey:@"results"],nil);
            }
        }
        
        [self.runningRequests removeObject:request];
    }
}

-(void)_handleExpectedValueResult:(ODataRequest*)request withData:(NSDictionary*)data error:(NSError*)error andCallBack:(void (^)(NSArray *data, NSError *error))callback {
    
    
    if(request.requestStartTime){
        float requestTime = -1*[request.requestStartTime timeIntervalSinceNow];
        NSLog(@"****Request:%@  took : %f seconds",request.name,requestTime);
    }
    
    
    if(error){
        
        NSLog(@"ERROR with %@ %@",request.name,error);
        if(callback){
            callback(nil,error);
        }
        
    }else{
    
        if([data objectForKey:@"d"]&&[[data objectForKey:@"d"] objectForKey:@"results"]){
            
            
            NSLog(@"SUCCESS %@ has result count:%lu",request.name,(unsigned long)[(NSArray*)[[data objectForKey:@"d"] objectForKey:@"results"] count] );
            if(callback){
                
                NSMutableArray*condensedResult = [[NSMutableArray alloc] init];
                
                NSArray* rawResult = (NSArray*)[[data objectForKey:@"d"] objectForKey:@"results"];
                if(rawResult&&[rawResult count]>0){
                    [rawResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSDictionary*opportunity = (NSDictionary*)obj;
                        if(opportunity){
                            NSDictionary*expValDict = [opportunity objectForKey:OPPORTUNITY_EXPECTED_VALUE];
                             NSDictionary*nameValDic = [opportunity objectForKey:OPPORTUNITY_NAME];
                            if(expValDict){
                                
                                [condensedResult addObject:@{
                                                             OPPORTUNITY_NAME:[nameValDic objectForKey:@"content"],
                                                             OPPORTUNITY_EXPECTED_VALUE:[expValDict objectForKey:@"content"]
                                                             
                                                             }];
                            }else{
                                NSLog(@"CODWatchODataProvider - ERROR Unable to parse result: expValDict & nameDict");
                            }
                        }else{
                            NSLog(@"CODWatchODataProvider - ERROR Unable to parse result: opportunity");
                        }
                    }];
                }
                callback(condensedResult ,nil);
            }
        }
        [self.runningRequests removeObject:request];
    }
}


#pragma mark helpers


-(NSString*)formatDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    return [dateFormatter stringFromDate:date];
}


-(void)_appendStatus:(NSString*)statusCode toString:(NSMutableString*)filterConditions{
    
    if([filterConditions length]>0){
        [filterConditions appendString:@" and "];
    }
    [filterConditions appendString:[NSString stringWithFormat: @" (StatusCode  eq '%@')",statusCode]];
}

-(void)_appendTimeOffset:(NSDate*)date withKey:(NSString*)key toString:(NSMutableString*)filterConditions{
    
    if([filterConditions length]>0){
        [filterConditions appendString:@" and "];
    }
    [filterConditions appendString:[NSString stringWithFormat: @" (%@ gt datetimeoffset'%@.0000000Z')",key,[self formatDate:date]]];
}

-(void)_appendTime:(NSDate*)date withKey:(NSString*)key toString:(NSMutableString*)filterConditions{
    
    if([filterConditions length]>0){
        [filterConditions appendString:@" and "];
    }
    [filterConditions appendString:[NSString stringWithFormat: @" (%@ gt datetime'%@')",key,[self formatDate:date]]];
}
-(void)_appendFilterValues:(NSArray*)values withKey:(NSString*)key toString:(NSMutableString*)filterConditions{
    
    if([filterConditions length]>0){
        [filterConditions appendString:@" and "];
    }
    
    if(values&&[values count]>0){
        [ filterConditions appendString:@"( "];
        for(int i = 0;i<[values count];i++ ){
            [filterConditions appendFormat:@"(%@ eq '%@')",key,[values objectAtIndex:i]];
            if(i<[values count]-1){
                [filterConditions appendString:@" or "];
            }
        }
        [ filterConditions appendString:@")"];
    }
}
@end
