// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  AppDelegate.m
//  Sensorama
//

#import <NSLogger/NSLogger.h>
#import <Lock/Lock.h>

#import "AppDelegate.h"
#import "SRUsageStats.h"
#import "SRAuth.h"
#import "SRUtils.h"
#import "SRDataStore.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <GroundControl/NSUserDefaults+GroundControl.h>

#import "SensoramaVars.h"

static AWSLogLevel awsLogLevel = AWSLogLevelNone;
static const char *sensoramaAppURL = "http://labs.koszek.com:9494/defaults.plist";

@interface AppDelegate ()
@property (nonatomic) BOOL isDevPhone;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.isDevPhone = [self isDevPhoneDetect];
    if (self.isDevPhone) {
        LoggerApp(1, @"Started logging on %@ (at %@)", [self deviceName], [NSDate new]);
        [SRAuth setLogLevel:awsLogLevel];
    }

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary *infoDict = [mainBundle infoDictionary];
    NSDictionary *fabricDict = [infoDict objectForKey:@"Fabric"];
    NSString *fabricAPIKey = [NSString stringWithUTF8String:FABRIC_API_KEY];
    NSString *Auth0ClientID = [NSString stringWithUTF8String:AUTH0CLIENTID];
    NSString *Auth0Domain = [NSString stringWithUTF8String:AUTH0DOMAIN];
    NSString *Auth0URLScheme = [NSString stringWithUTF8String:AUTH0_URLSCHEME];

    NSURL *cfgURL = [NSURL URLWithString:[NSString stringWithUTF8String:sensoramaAppURL]];
    [[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:cfgURL
                                                           success:^(NSDictionary *dict) {
                                                               NSLog(@"dict=%@", dict);
                                                           } failure:^(NSError *error) {
                                                               NSLog(@"error=%@", error);
                                                           }];

    // Below I replace whole bunch of secrets for 3rd party frameworks,
    // so that everything in Sensorama can be open-sourced and actively
    // developed, but without disclosing secrets.
    [[[infoDict objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] setObject:@[ Auth0URLScheme ] forKey:@"CFBundleURLSchemes"];
    [fabricDict setValue:fabricAPIKey forKey:@"APIKey"];
    [infoDict setValue:Auth0ClientID forKey:@"Auth0ClientId"];
    [infoDict setValue:Auth0Domain forKey:@"Auth0Domain"];

    if ([SRUtils isSimulator]) {
        NSLog(@"Running on simulator. Crashlytics not initialized!");
    } else {
        if (self.isDevPhone) {
            [[Crashlytics sharedInstance] setDebugMode:YES];
        }
        [Fabric with:@[[CrashlyticsKit class], [Answers class]]];
    }

    [SRAuth startWithLaunchOptions:launchOptions];
    [SRUsageStats eventAppOpened];
    [SRDataStore handleMigrations];

    return YES;
}

- (NSString *)deviceName {
    return [[UIDevice currentDevice] name];
}

- (BOOL)isDevPhoneDetect {
    return [[self deviceName] isEqualToString:[NSString stringWithUTF8String:SENSORAMA_DEV_PHONE]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"%s", __func__);
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
