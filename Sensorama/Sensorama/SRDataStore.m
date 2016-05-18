//
//  SRDataStore.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRDataStore.h"
#import "SRDataFile.h"

@implementation SRDataStore

+ (SRDataStore *)sharedInstance {
    static SRDataStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void) insertDataFile:(SRDataFile *)dataFile
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    [realm addOrUpdateObject:dataFile];
    [realm commitWriteTransaction];
}

- (void) insertDataPoints:(NSArray<SRDataPoint *> *) points
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    [realm addOrUpdateObjectsFromArray:points];
    [realm commitWriteTransaction];
}

@end
