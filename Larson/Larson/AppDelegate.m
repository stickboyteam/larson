//
//  AppDelegate.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 06/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "PayPalMobile.h"
#import "ZBarSDK.h"
#import <Raygun4iOS/Raygun.h>

@implementation AppDelegate

@synthesize checkInList = _checkInList;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSMutableArray* checkInList1 = [[NSMutableArray alloc] init];
    self.checkInList = checkInList1;
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",                                                           PayPalEnvironmentSandbox :kPayPalClientID}];

    [Raygun sharedReporterWithApiKey:kRayGunApiKey];
    
    [ZBarReaderView class];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* savedObjects = [[NSArray alloc] initWithArray:self.checkInList];
    [defaults setObject:savedObjects forKey:@"CheckedIn"];
    [defaults synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* savedObjects = [[NSArray alloc] initWithArray:[defaults objectForKey:@"CheckedIn"]];
    [self.checkInList removeAllObjects];
    [self.checkInList addObjectsFromArray:savedObjects];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
//YourAppReturnURLRoot://takePayment?Type=CreditCard&InvoiceId=INV2-AHWG-SQHP-QMLT-1234&Tip=5.00&TxId=111-11-1111
    
//    However, if a payment is canceled, the response of the PayPal Here app would be similar to the following:
        
//        YourAppReturnURLRoot://takePayment?Type=Unknown

    [[NSNotificationCenter defaultCenter] postNotificationName:kAppDelegateOpenURLNotification object:url];
    
//    [UIUtils alertWithInfoMessage:[NSString stringWithFormat:@"%@",url]];
    
    return YES;
}

@end
