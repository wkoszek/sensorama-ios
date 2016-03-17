// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  AppDelegate.m
//  Sensorama
//

#import "Fabric/Fabric.h"
#import "Crashlytics/Crashlytics.h"
#import <AWSCore/AWSCore.h>
#import <Lock/Lock.h>


#import "AppDelegate.h"
#import "SRUsageStats.h"
#import "SRAuth.h"

#import "SensoramaVars.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary *infoDict = [mainBundle infoDictionary];
    NSDictionary *fabricDict = [infoDict objectForKey:@"Fabric"];
    NSString *fabricAPIKey = [NSString stringWithUTF8String:FABRIC_API_KEY];
    NSString *Auth0ClientID = [NSString stringWithUTF8String:AUTH0CLIENTID];
    NSString *Auth0Domain = [NSString stringWithUTF8String:AUTH0DOMAIN];
    NSString *Auth0URLScheme = [NSString stringWithUTF8String:AUTH0_URLSCHEME];

    // Below I replace whole bunch of secrets for 3rd party frameworks,
    // so that everything in Sensorama can be open-sourced and actively
    // developed, but without decreasing security.
    [[[infoDict objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] setObject:@[ Auth0URLScheme ] forKey:@"CFBundleURLSchemes"];
    [fabricDict setValue:fabricAPIKey forKey:@"APIKey"];
    [infoDict setValue:Auth0ClientID forKey:@"Auth0ClientId"];
    [infoDict setValue:Auth0Domain forKey:@"Auth0Domain"];

    [Fabric with:@[[CrashlyticsKit class], [Answers class]]];
    [self AWSStart];

    A0Lock *lock = [[SRAuth sharedInstance] lock];
    [lock applicationLaunchedWithOptions:launchOptions];

    [SRUsageStats eventAppOpened];

    return YES;
}

- (void)AWSStart {
    NSString *CognitoPoolID = [NSString stringWithUTF8String:SENSORAMA_COGNITO_POOL_ID];
    AWSCognitoCredentialsProvider *credentialsProvider =
        [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:CognitoPoolID];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
        credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    A0Lock *lock = [[SRAuth sharedInstance] lock];
    return [lock handleURL:url sourceApplication:sourceApplication];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
