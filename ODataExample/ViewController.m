//
//  ViewController.m
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

#import "ViewController.h"
#import "UserContext.h"
#import "DataFacade.h"

@interface ViewController ()
- (IBAction)onSaveBtnPressed:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CredentialObject* credObj = [[UserContext sharedInstance] getCredentials];
    
    //Load the stored credentials if any
    if(credObj){
        self.user.text = credObj.username;
        self.password.text = credObj.password;
        self.systemUrl.text = credObj.baseURL;
        
        [self onSaveBtnPressed:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSaveBtnPressed:(id)sender {
    [self.view endEditing:YES];
    self.log.text = @"Processing...";
    NSString* username = self.user.text;
    NSString* password = self.password.text;
    NSString* url = self.systemUrl.text;
    
    CredentialObject* credObj = [[CredentialObject alloc] initWith:url user:username password:password];
    
    //Save the credentials
    [[UserContext sharedInstance] setCredentials:credObj];
    
    NSLog(@"User Credentials Saved With Username \"%@\", Password \"%@\", URL \"%@\"", credObj.username,credObj.password, credObj.baseURL);
    
    [self validateCredentials];
    
}

-(void)validateCredentials
{
    [[DataFacade sharedInstance] getAccountsForTop:[NSNumber numberWithInt:10] andSkip:[NSNumber numberWithInt:0] withCallBack:^(NSDictionary *replyInfo) {
    
        if([replyInfo objectForKey:@"error"] != [NSNull null]){
            NSError * error = [replyInfo objectForKey:@"error"];
            NSString * log = [NSString stringWithFormat:@"Check url & credentials.\nError:\n%@",[error localizedDescription] ];
            [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:NO];
            NSLog(@"Error: %@", [error localizedDescription]);
            [self performSelectorOnMainThread:@selector(enableButton:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
        }else{
            NSString * log = @"Credentials Valid";
            [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:NO];
            NSLog(@"valid");
            [self performSelectorOnMainThread:@selector(enableButton:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
        }
        
    }];
}

-(void)enableButton:(NSNumber*)enabled
{
    [self.btnViewAccounts setEnabled:[enabled boolValue]];
}

-(void)updateLog:(NSString*)log
{
    self.log.text = log;
}
@end
