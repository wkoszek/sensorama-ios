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
#import "SRDebug.h"

#import "SensoramaVars.h"

@interface SRSync ()
@property AWSCognitoCredentialsProvider *provider;
@end

@implementation SRSync

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

- (instancetype)initWithFile:(SRDataFile *)dataFile configuration:(SRCfg *)configuration
{
    self = [super init];
    if (self) {
        self.fileToSync = dataFile;
        self.configuration = configuration;
    }
    return self;
}

- (instancetype) init {
    return [self initWithFile:nil configuration:nil];
}

- (void)syncStart
{
    NSString *fileBaseName = [self.fileToSync fileBasePathName];
    NSURL *fileURL = [NSURL fileURLWithPath:[self.fileToSync filePathName]];
    SRPROBE1(fileURL);

    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"sensorama-data";
    uploadRequest.key = [NSString stringWithFormat:@"%@/%@", [SRAuth emailHashed], fileBaseName];
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
