//
//  SRAuth.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/16/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleKeychain/A0SimpleKeychain.h"

// Auth0 Lock singleton crap
@class A0Lock;
@interface SRAuth : NSObject
@property (readonly, nonatomic) A0Lock *lock;
@property A0SimpleKeychain *keychain;
+ (SRAuth *)sharedInstance;
@end
