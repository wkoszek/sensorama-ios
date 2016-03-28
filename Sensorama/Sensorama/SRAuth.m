//
//  SRAuth.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/16/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRAuth.h"
#import <Lock/Lock.h>

@implementation SRAuth
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
    }
    return self;
}
@end

