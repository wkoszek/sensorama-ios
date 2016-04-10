//
//  SRSync.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/11/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "SRSync.h"
#import "SRAuth.h"
#import "SRUtils.h"

#import "SensoramaVars.h"

@interface SRSync ()
@property AWSCognitoCredentialsProvider *provider;
@end

@implementation SRSync

+ (void)doAmazonLogin:(NSString *)token
{
    AWSCognitoCredentialsProvider *provider = [[SRAuth sharedInstance] credentialsProvider];

    (void)provider;

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
    NSString *baseFileName = [[self.pathToSync componentsSeparatedByString:@"/"] lastObject];

    NSURL *fileURL = [NSURL fileURLWithPath:self.pathToSync];

    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"sensorama-data";
    uploadRequest.key = [NSString stringWithFormat:@"%@/%@", [SRAuth emailHashed], baseFileName];
    uploadRequest.body = fileURL;

    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        NSLog(@"download block");
        if ([task error] == nil) {
            NSLog(@"task finished");
        }
        return nil;
    }];
}

@end
