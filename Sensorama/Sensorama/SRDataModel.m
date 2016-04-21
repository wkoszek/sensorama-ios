//
//  SRDataModel.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 19/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRDataModel.h"

@implementation SRDataPoint

+ (NSString *)primaryKey
{
    return @"pointId";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"pointId": @(0) };
}

@end

@implementation SRDataFile

+ (NSString *)primaryKey
{
    return @"fileId";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"fileId": @(0) };
}

@end


@implementation SRDataStore

+ (SRDataStore *)sharedInstance {
    static SRDataStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _realm = [RLMRealm defaultRealm];
    }
    return self;
}

- (void) insertDataFile:(SRDataFile *)dataFile
{
    [self.realm beginWriteTransaction];
    [self.realm addObject:dataFile];
    [self.realm commitWriteTransaction];
}

- (void) insertDataPoints:(NSArray<SRDataPoint *> *) points
{
    [self.realm beginWriteTransaction];
    [self.realm addOrUpdateObjectsFromArray:points];
    [self.realm commitWriteTransaction];
}


@end
