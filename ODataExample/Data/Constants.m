//
//  Constants.m
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

#import "Constants.h"



@implementation Constants

NSString* const COLLECTIION_ACCOUNT         = @"AccountCollection";
NSString* const COLLECTIION_OPPORTUNITY     = @"OpportunityCollection";

NSString* const PATH_ODATA_V1               = @"/sap/byd/odata/v1/c4codata/";

NSString* const COUNT                       = @"$count";

NSString* const QUERY_OPTION_FORMAT_JSON    = @"$format=json";
NSString* const QUERY_OPTION_FILTER         = @"$filter";
NSString* const QUERY_OPTION_TOP            = @"$top";
NSString* const QUERY_OPTION_SKIP           = @"$skip";
NSString* const QUERY_OPTION_ORDERBY        = @"$orderby";
NSString* const QUERY_OPTION_SELECT         = @"$select";
NSString* const QUERY_OPTION_EXPAND         = @"$expand";

NSString* const USER_CONTEXT_KEY            = @"ODEUserContext";
NSString* const USER_CONTEXT_URL_KEY        = @"ODEUserContextUrl";
NSString* const USER_CONTEXT_USERNAME_KEY   = @"ODEUserContextUsername";
NSString* const USER_CONTEXT_PASSWORD_KEY   = @"ODEUserContextPassword";

NSString* const FILTER_ACCOUNT_ACCOUNTID    = @"AccountID";
NSString* const SELECT_ACCOUNT_ACCOUNT_NAME = @"AccountName";


NSString* const OPPORTUNITY_CLOSE_DATE      = @"CloseDate";
NSString* const OPPORTUNITY_EXPECTED_VALUE  = @"ExpectedValue";
NSString* const OPPORTUNITY_NAME            = @"Name";

NSString* const NO_RESULTS                  = @"No Results";
NSString* const ACTION                      = @"action";

@end
