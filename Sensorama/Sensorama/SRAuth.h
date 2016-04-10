//
//  SRAuth.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/16/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleKeychain/A0SimpleKeychain.h"
#import <AWSCore/AWSCore.h>
#import <Lock/Lock.h>

@class A0Lock;

@interface SRAuth : NSObject
@property (readonly, nonatomic) A0Lock *lock;
@property A0SimpleKeychain *keychain;
@property (nonatomic) AWSCognitoCredentialsProvider *credentialsProvider;

+ (SRAuth *)sharedInstance;
+ (void)enableDebugging;
+ (void) startWithLaunchOptions:(NSDictionary *)launchOptions;
+ (A0UserProfile *) currentProfile;
+ (NSString *)emailHashed;

@end
