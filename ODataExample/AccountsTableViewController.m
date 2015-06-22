//
//  AccountsTableViewController.m
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

#import "AccountsTableViewController.h"
#import "OpportunitiesTableViewController.h"
#import "DataFacade.h"
#import "Constants.h"

@interface AccountsTableViewController ()
{
    NSArray * accounts;
    UIView * spinner;
}
@property (nonatomic) IBOutlet UITableView *myTableView;
@end

@implementation AccountsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadAccounts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return accounts.count;
}


-(void)loadAccounts
{
    [NSThread detachNewThreadSelector:@selector(showSpinner) toTarget:self withObject:nil];
    
    [[DataFacade sharedInstance] getAccountsForTop:[NSNumber numberWithInt:10] andSkip:[NSNumber numberWithInt:0] withCallBack:^(NSDictionary *replyInfo) {
    
        if([replyInfo objectForKey:@"error"] != [NSNull null]){
            NSError * error = [replyInfo objectForKey:@"error"];
            [self performSelectorOnMainThread:@selector(showErrorAlert:) withObject:error.localizedDescription waitUntilDone:NO];
        }else{
            accounts = [replyInfo objectForKey:COLLECTIION_ACCOUNT];
            [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
        }
        
    }];
}

-(void)reloadTable
{
    [self.myTableView reloadData];
    [self hideSpinner];
}

-(void)showErrorAlert:(NSString*)error
{
    [self hideSpinner];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error loading Accounts!"
                                                    message:error
                                                    delegate:self 
                                                    cancelButtonTitle:@"OK" 
                                                    otherButtonTitles:nil];
    [alert show];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell.textLabel setText:[accounts[indexPath.row] objectForKey:SELECT_ACCOUNT_ACCOUNT_NAME]];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    OpportunitiesTableViewController * oppVC = [segue destinationViewController];
    
    NSDictionary * account = accounts[[self.tableView indexPathForSelectedRow].row];
    oppVC.accountID = [account objectForKey:FILTER_ACCOUNT_ACCOUNTID];
}

#pragma mark - Activity Indicatior
-(void)showSpinner
{

    spinner = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.myTableView.bounds.size.width, self.myTableView.bounds.size.height)];
    spinner.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    spinner.alpha = 0.5;

    UIActivityIndicatorView *activitySpinner = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(self.myTableView.bounds.size.width / 2 - 12, self.myTableView.bounds.size.height / 2 - 12, 24, 24)];
    activitySpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activitySpinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleBottomMargin);
    [spinner addSubview:activitySpinner];
    [self.view addSubview: spinner];

    [[[spinner subviews] objectAtIndex:0] startAnimating];
}

-(void)hideSpinner
{
    [[[spinner subviews] objectAtIndex:0] stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
}
@end
