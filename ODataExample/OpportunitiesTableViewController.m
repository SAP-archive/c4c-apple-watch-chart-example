//
//  OpportunitiesTableViewController.m
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

#import "OpportunitiesTableViewController.h"
#import "DataFacade.h"
#import "Constants.h"

@interface OpportunitiesTableViewController ()
{
    NSArray*opportunities;
    UIView * spinner;
}
@property (nonatomic) IBOutlet UITableView *myTableView;
@end

@implementation OpportunitiesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadOpportunities];
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
    return opportunities.count;
}

-(void)loadOpportunities
{
    [NSThread detachNewThreadSelector:@selector(showSpinner) toTarget:self withObject:nil];

    [[DataFacade sharedInstance] getExpectedValueAndOpportunitiesForAccount:self.accountID  withCallBack:^(NSDictionary *replyInfo) {
        if([[replyInfo allKeys ] containsObject:@"error"]){
            NSError * error = [replyInfo objectForKey:@"error"];
            [self performSelectorOnMainThread:@selector(showErrorAlert:) withObject:error.localizedDescription waitUntilDone:NO];
        }else{
            opportunities = [replyInfo objectForKey:COLLECTIION_OPPORTUNITY];
            [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
        }
    }];
}

-(void)reloadTable
{
    if(opportunities.count == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"No results found"
                                                    delegate:self 
                                                    cancelButtonTitle:@"OK" 
                                                    otherButtonTitles:nil];
        [alert show];
    }
    [self.myTableView reloadData];
    [self hideSpinner];
}

-(void)showErrorAlert:(NSString*)error
{
    [self hideSpinner];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error loading Opportunities!"
                                                    message:error
                                                    delegate:self 
                                                    cancelButtonTitle:@"OK" 
                                                    otherButtonTitles:nil];
    [alert show];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"opportunityCell" forIndexPath:indexPath];
    
    NSDictionary * opportunity = opportunities[indexPath.row];
    
    // Configure the cell...
    [cell.textLabel setText: [opportunity objectForKey:OPPORTUNITY_NAME]];
    
    NSString * value = [NSString stringWithFormat:@"$%.0f", [[opportunity objectForKey:OPPORTUNITY_EXPECTED_VALUE] floatValue]];
    [cell.detailTextLabel setText:value];
    
    return cell;
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
