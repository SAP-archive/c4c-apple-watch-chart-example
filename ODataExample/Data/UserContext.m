//
//  UserContext.m
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

#import "UserContext.h"
#import "Constants.h"

@interface UserContext ()

@property (nonatomic, readwrite) CredentialObject* credentials;

@end

@implementation UserContext

@synthesize credentials = _credentials;

-(id)init
{
    self = [super init];
    if(self) {
        [self _syncContext];
     }
    
    return self;
}

+(UserContext *)sharedInstance
{
    static UserContext *instance = nil;
    
    static dispatch_once_t dispatchToken;
    dispatch_once(&dispatchToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(CredentialObject*)getCredentials
{
    NSData* userContextData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CONTEXT_KEY];
    
    if(userContextData) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:userContextData];
    }else{
       
    }
   
    NSDictionary* userContextDict = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CONTEXT_KEY];
    if(userContextDict) {
        NSString* url = [userContextDict objectForKey:USER_CONTEXT_URL_KEY];
        NSString* username = [userContextDict objectForKey:USER_CONTEXT_USERNAME_KEY];
        NSString* password = [userContextDict objectForKey:USER_CONTEXT_PASSWORD_KEY];
        
        if(url && username && password) {
            return [[CredentialObject alloc] initWith:url user:username password:password];
        }
    }
    
    return nil;
}

-(void)setCredentials:(CredentialObject *)credentials
{
    _credentials = credentials;
    
    NSData* userContextData = [NSKeyedArchiver archivedDataWithRootObject:credentials];
    
    [[NSUserDefaults standardUserDefaults] setObject:userContextData forKey:USER_CONTEXT_KEY];
}

-(void)_syncContext
{
    NSData* userContextData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CONTEXT_KEY];
    
    if(userContextData) {
        _credentials = [NSKeyedUnarchiver unarchiveObjectWithData:userContextData];
    }
}

@end
