//
//  SRSync.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/11/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>

#import "SRSync.h"

#import "SensoramaVars.h"

@interface SRSync ()
@property AWSCognitoCredentialsProvider *provider;
@end

@implementation SRSync

+ (AWSCognitoCredentialsProvider *)getCredProvider {
    static AWSCognitoCredentialsProvider *credentialsProvider;
    static dispatch_once_t onceToken;

    NSString *CognitoPoolID = [NSString stringWithUTF8String:SENSORAMA_COGNITO_POOL_ID];
    NSString *CognitoAuthRoleARN = [NSString stringWithUTF8String:SENSORAMA_COGNITO_AUTH_ROLE_ARN];

    [[AWSLogger defaultLogger] setLogLevel:AWSLogLevelVerbose];

    dispatch_once(&onceToken, ^{
        AWSCognitoCredentialsProvider *credentialsProvider =
        [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                       identityId:nil
                                                        accountId:nil
                                                   identityPoolId:CognitoPoolID
                                                    unauthRoleArn:nil
                                                      authRoleArn:CognitoAuthRoleARN
                                                           logins:nil];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                             credentialsProvider:credentialsProvider];
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    });
    return credentialsProvider;
}


+ (void)doAmazonLogin:(NSString *)token
{
    AWSCognitoCredentialsProvider *provider = [SRSync getCredProvider];
    [provider setLogins:@{ @"koszek.auth0.com" : token }];
    [[provider getIdentityId] continueWithBlock:^id _Nullable(AWSTask * _Nonnull task) {
        if ([task error]) {
            NSLog(@"Amazon login failed");
        } else {
            NSLog(@"Amazon login complete");
        }
        return nil;
    }];
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.pathToSync = path;
    }
    return self;
}

- (void)syncStart
{
    AWSCognito *syncClient = [AWSCognito defaultCognito];

    // Create a record in a dataset and synchronize with the server
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:@"myDataset"];
    [dataset setString:@"myValue" forKey:@"myKey2"];
    [[dataset synchronize] continueWithBlock:^id(AWSTask *task) {
        // Your handler code here
        NSLog(@"synced!");
        return nil;
    }];
    [dataset synchronize];
}

@end
