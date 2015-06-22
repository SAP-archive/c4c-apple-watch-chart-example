//
//  CredentialObject.m
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

#import "CredentialObject.h"

@interface CredentialObject()

@property (nonatomic, readwrite) NSString* username;
@property (nonatomic, readwrite) NSString* password;
@property (nonatomic, readwrite) NSString* baseURL;

@end

@implementation CredentialObject

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.username = [decoder decodeObjectForKey:@"username"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.baseURL = [decoder decodeObjectForKey:@"baseURL"];
    }
    return self;
}

-(id)initWith:(NSString*)baseURL user:(NSString*)user password:(NSString*)psw{
    self = [super init];
    if(self) {
        self.username = user;
        self.password = psw;
        self.baseURL = baseURL;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.password forKey:@"password"];
    [encoder encodeObject:self.baseURL forKey:@"baseURL"];
}

@end
