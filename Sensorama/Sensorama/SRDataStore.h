//
//  SRDataStore.h
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import Foundation;

#import "SRDataPoint.h"
#import "SRDataFile.h"

@interface SRDataStore : NSObject

@property (readonly) RLMRealm *realm;

+ (SRDataStore *)sharedInstance;
- (void) insertDataFile:(SRDataFile *)dataFile;
- (void) insertDataPoints:(NSArray<SRDataPoint *> *) points;


@end