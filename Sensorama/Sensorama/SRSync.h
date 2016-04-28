//
//  SRSync.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/11/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import Foundation;

#import "SRCfg.h"
#import "SRDataFile.h"

@interface SRSync : NSObject

@property (nonatomic) SRDataFile *fileToSync;
@property (nonatomic) SRCfg *configuration;

- (instancetype)initWithFile:(SRDataFile *)dataFile configuration:(SRCfg *)configuration;

+ (void)doAmazonLogin:(NSString *)token;
- (void)syncStart;

@end
