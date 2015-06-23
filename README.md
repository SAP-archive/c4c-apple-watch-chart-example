SAP Digital for Customer Engagement - Apple Watch OData API Sample
===============================

This repository contains the sample code demonstrating how to connect an Apple Watch app to the SAP Digital for Customer Engagement OData API’s for both Accounts & Opportunities and render the Opportunity data in a animated dynamic bar chart. 

## Disclaimer ##
<span style="color:red">Public access to the SAP Digital for Customer Engagement OData API is not supported currently. Customers/developers/partners should reach out to SAP for any such requests. For this sample your own login credentials will be used to access the OData API's</span>

## SCN Article ##
You can read the SCN Blog Post that this code was created for here: 

http://scn.sap.com/community/cloud-for-customer/blog/2015/05/08/apple-watch-charting-using-cloud-for-customer-odata-api

## Platforms ##
This sample code is for WatchOS 1.X & iOS 8.0+ and runs on the following hardware:

* iPhone 4S, 5, 5S, 5C, 6, 6 Plus
* Apple Watch 1.x

## Screenshots ##
### iPhone ###
![iPhone Screenshot](https://raw.githubusercontent.com/SAP/c4c-apple-watch-chart-example/master/iPhone.png?token=AMXxTpSzoXxUULcFXDMo2ZslowmSA5dPks5VkcX5wA%3D%3D)![iPhone Screenshot](https://raw.githubusercontent.com/SAP/c4c-apple-watch-chart-example/master/accounts.png?token=AMXxTsHqBtooZZfCwZiGhI1oCL3idRM0ks5VkxsVwA%3D%3D)![iPhone Screenshot](https://raw.githubusercontent.com/SAP/c4c-apple-watch-chart-example/master/accounts.png?token=AMXxTtKGQYMUnmL33H6f2N9R3coNQnstks5VkxtYwA%3D%3D)

### Apple Watch ###
![Apple Watch Screenshot](https://raw.githubusercontent.com/SAP/c4c-apple-watch-chart-example/master/Apple%20Watch.png?token=AMXxTu3M9F7IqkZqs5QWEaS8_opHRAFbks5VkcYowA%3D%3D)

## iPhone & Watch communication ##
Use openParentApplication to handle all network requests on the iPhone

<B>Docs:</B> [openParentApplication:reply:](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/index.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:handleWatchKitExtensionRequest:reply:)

In order to get data from the iPhone such as network responses you need to call 
```objective-c
[WKInterfaceController openParentApplication: reply:]
```
#### Figure 1.1.1 ####
```objective-c
    [WKInterfaceController openParentApplication:@{ACTION:COLLECTIION_ACCOUNT}
                            reply:^(NSDictionary *replyInfo, NSError *error) {
        accounts = [replyInfo objectForKey:COLLECTIION_ACCOUNT];
        [self loadAccounts: accounts];
    }];
```

### iPhone ###

<B>Docs:</B> [handleWatchKitExtensionRequest:reply:](https://developer.apple.com/library/prerelease/ios/documentation/WatchKit/Reference/WKInterfaceController_class/#//apple_ref/occ/clm/WKInterfaceController/openParentApplication:reply:)

The folowing code is needed to spawn a background task that will handle your <B>reply(NSDictionary*replyInfo)</B> callback.

#### Figure 1.2.1 ####
```objective-c
    UIBackgroundTaskIdentifier bgTaskID = [application beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"UIBackgroundTaskIdentifier expired");
    }];
    void (^reply)(NSDictionary*)=^(NSDictionary * replyInfo){
        replyBlock(replyInfo);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC), dispatch_get_global_queue(0, 0),^{
            [application endBackgroundTask:bgTaskID];
        });
    };
```
Inside your <B>handleWatchKitExtensionRequest</B> you will take parameters passed from the watch in order to process the request. You can do this by reading out the values passed from the watch in the (NSDictionary*) userInfo param

#### Figure 1.2.2 ####
```objective-c
    //Get the action
    NSString* action = [userInfo objectForKey:ACTION];
 
    //Get All Accounts
    if([action isEqualToString:COLLECTIION_ACCOUNT]){
        [[DataFacade sharedInstance] getAccountsForTop:[NSNumber numberWithInt:10] andSkip:[NSNumber numberWithInt:0] withCallBack:reply];
    }
    //Get the Opportunities for a given AccountID
    else if([action isEqualToString:COLLECTIION_OPPORTUNITY]){
        NSString *accountID = [userInfo objectForKey:FILTER_ACCOUNT_ACCOUNTID];
        
        [[DataFacade sharedInstance] getExpectedValueAndOpportunitiesForAccount:accountID  withCallBack:reply];
    }else{
        reply(nil);
    }
```

# Animations #

### Using After Effects to generate PNG Sequences ###

In order to animate on the Apple Watch you must use image sequences.

Using After Effects to create PNG Sequences: https://www.youtube.com/watch?v=IHzhRA3d9tk

### Optimizing Animations for Apple Watch ###

Load only the first animation then let the screen display and load the next.

Use compressed JPEGs when setting images to the Watch UI
```objective-c
UIImageJPEGRepresentation(UIImage*, compression)
```
Reduce animations to as few images as possible & load only the first animation then let the screen display and load the next using 
```objective-c
performSelector:afterDelay:
```

## Authors ##
* Damien Murphy<br/>
* Mario Linge<br/>
* Hansi Li<br/>
* Oliver Conze<br/>


## Contributions ##
We would like to thank the following people for their contributions to the project:
* Damien Murphy for coding the charting and putting all the pieces together & documentation
* Mario Linge for his work on the Architecture & iPhone Network Request code
* Hansi Li for his work on the Apple Watch UI & code
* Oliver Conze for his vision and testing help



