//
//  InterfaceController.m
//  ODataExample WatchKit Extension
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

#import "InterfaceController.h"
#import "MyAccountsRowController.h"
#import "ReloadDataRowController.h"
#import "Constants.h"

@interface InterfaceController()
{
    NSArray* accounts;
}

@property (nonatomic, retain) IBOutlet WKInterfaceTable * tblMyAccounts;
@end



@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
  
    [self refreshData];
}

-(void)refreshData
{
    [WKInterfaceController openParentApplication:@{ACTION:COLLECTIION_ACCOUNT}
                            reply:^(NSDictionary *replyInfo, NSError *error) {
        
        accounts = [replyInfo objectForKey:COLLECTIION_ACCOUNT];
        [self loadAccounts: accounts];
        
    }];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)loadAccounts:(NSArray*)items {

    NSMutableArray * rowTypes = [[NSMutableArray alloc] init];
    if(items.count == 0){
        items = @[@{SELECT_ACCOUNT_ACCOUNT_NAME : NO_RESULTS}];
    }
    
    for(int i=0; i< items.count; i++){
        [rowTypes addObject:@"MyAccountsRowController"];
    }
    
    //Add the reload data row
    [rowTypes addObject:@"ReloadDataRowController"];
    
    [self.tblMyAccounts setRowTypes:rowTypes];
    
    NSInteger rowCount = self.tblMyAccounts.numberOfRows;

    // Iterate over the rows and set the label for each one.
    for (int i = 0; i < rowCount-1; i++) {
        // Get the item data.
        NSDictionary* item = items[i];

        // Assign the text to the row's label.
        MyAccountsRowController* row = [self.tblMyAccounts rowControllerAtIndex:i];
        if(item){
            row.lblName.text = [item objectForKey:SELECT_ACCOUNT_ACCOUNT_NAME];
        }
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    //if the last row was selected
    if(rowIndex == table.numberOfRows-1){
        ReloadDataRowController * row = [table rowControllerAtIndex:rowIndex];
        
        row.lblReloadData.text = @"Loading...";
        
        [self refreshData];
        
        [table scrollToRowAtIndex:0];
    }
}

-(id) contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex
{
    
    if([segueIdentifier isEqualToString:@"SalesInterfaceController"]){
        if([accounts count]==0){
            return @{FILTER_ACCOUNT_ACCOUNTID:@"",SELECT_ACCOUNT_ACCOUNT_NAME:@"no account"};
        }else{
            return accounts[rowIndex] ;
        }
        
    }else{
        return nil;
    }
}

@end



