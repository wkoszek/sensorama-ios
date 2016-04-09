//
//  SRSync.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/11/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRSync : NSObject

@property NSString *pathToSync;

+ (void)doAmazonLogin:(NSString *)token;
- (instancetype)initWithPath:(NSString *)path;
- (void)syncStart;

@end
