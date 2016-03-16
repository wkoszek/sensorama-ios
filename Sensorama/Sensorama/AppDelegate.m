// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  AppDelegate.m
//  Sensorama
//

#import "Fabric/Fabric.h"
#import "Crashlytics/Crashlytics.h"
#import <AWSCore/AWSCore.h>


#import "AppDelegate.h"
#import "SRUsageStats.h"

#import "SensoramaVars.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary *fabricDict = [[mainBundle infoDictionary] objectForKey:@"Fabric"];
    NSString *fabricAPIKey = [NSString stringWithUTF8String:FABRIC_API_KEY];
    [fabricDict setValue:fabricAPIKey forKey:@"APIKey"];

    [Fabric with:@[[CrashlyticsKit class], [Answers class]]];
    [self AWSStart];

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
