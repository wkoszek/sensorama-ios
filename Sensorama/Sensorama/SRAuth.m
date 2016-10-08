// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRAuth.m
//  Sensorama

#import <Lock/Lock.h>

#import "SRAuth.h"
#import "SRUtils.h"
#import "SRDebug.h"

#import "SensoramaVars.h"

@implementation SRAuth

+ (void)setLogLevel:(AWSLogLevel)logLevel {
    [[AWSLogger defaultLogger] setLogLevel:logLevel];
}

- (NSString *)cognitoPoolID {
    return [NSString stringWithUTF8String:SENSORAMA_COGNITO_POOL_ID];
}

+ (SRAuth *)sharedInstance {
    static SRAuth *sharedApplication = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedApplication = [[self alloc] init];
    });
    return sharedApplication;
}

- (id)init {
    self = [super init];
    if (self) {
        _lock = [A0Lock newLock];
        _keychain = [A0SimpleKeychain keychainWithService:@"Sensorama"];
        _credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                   identityPoolId:[self cognitoPoolID]];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                             credentialsProvider:_credentialsProvider];
        configuration.allowsCellularAccess = NO;
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    }
    return self;
}

+ (void) startWithLaunchOptions:(NSDictionary *)launchOptions {
    A0Lock *lock = [[SRAuth sharedInstance] lock];
    [lock applicationLaunchedWithOptions:launchOptions];
}

+ (A0UserProfile *) currentProfile {
    A0SimpleKeychain *keychain = [SRAuth sharedInstance].keychain;
    NSData *decodedData = [keychain dataForKey:@"profile"];
    if (decodedData == nil) {
        return nil;
    }
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    return profile;
}

+ (NSString *)emailHashed {
    NSString *emailString = [[SRAuth currentProfile] email];
    NSString *emailStringHashed = [SRUtils computeSHA256DigestForString:emailString];
    return emailStringHashed;
}

+ (void)doAmazonLogin:(NSString *)token
{
    AWSCognitoCredentialsProvider *provider = [[SRAuth sharedInstance] credentialsProvider];

    SRPROBE1(provider);

#if 0
    // Broken for now.
    [provider setLogins:@{ @"koszek.auth0.com" : token }];
    [[provider getIdentityId] continueWithBlock:^id _Nullable(AWSTask * _Nonnull task) {
        if ([task error]) {
            NSLog(@"!!!!!!!!!!!!!!!!!! Amazon login failed");
        } else {
            NSLog(@"!!!!!!!!!!!!!!!!!! Amazon login complete");
        }
        return nil;
    }];
#endif
}



@end

