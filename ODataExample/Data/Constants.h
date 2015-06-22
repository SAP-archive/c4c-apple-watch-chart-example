//
//  Constants.h
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

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString* const COLLECTIION_ACCOUNT;
extern NSString* const COLLECTIION_OPPORTUNITY;

extern NSString* const PATH_ODATA_V1;

extern NSString* const COUNT;

extern NSString* const QUERY_OPTION_FORMAT_JSON;
extern NSString* const QUERY_OPTION_FILTER;
extern NSString* const QUERY_OPTION_TOP;
extern NSString* const QUERY_OPTION_SKIP;
extern NSString* const QUERY_OPTION_ORDERBY;
extern NSString* const QUERY_OPTION_SELECT;
extern NSString* const QUERY_OPTION_EXPAND;

extern NSString* const USER_CONTEXT_KEY;
extern NSString* const USER_CONTEXT_URL_KEY;
extern NSString* const USER_CONTEXT_USERNAME_KEY;
extern NSString* const USER_CONTEXT_PASSWORD_KEY;


extern NSString* const FILTER_ACCOUNT_ACCOUNTID;
extern NSString* const SELECT_ACCOUNT_ACCOUNT_NAME;

extern NSString* const OPPORTUNITY_CLOSE_DATE;
extern NSString* const OPPORTUNITY_EXPECTED_VALUE;
extern NSString* const OPPORTUNITY_NAME;

extern NSString* const NO_RESULTS;
extern NSString* const ACTION;

@end
