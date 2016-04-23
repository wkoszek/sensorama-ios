//
//  SRDataModel.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 19/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRDataModel.h"


@implementation SRDataFile

+ (NSString *)primaryKey
{
    return @"fileId";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"fileId": @(0) };
}

- (NSDictionary *)toDict {
    return @{
             @"username" : self.username,
             @"desc" : self.desc,
             @"timezone" : self.timezone,
             @"interval" : @(self.sampleInterval),
             @"accEnabled" : @(self.accEnabled),
             @"magEnabled" : @(self.magEnabled),
             @"gyroEnabled" : @(self.gyroEnabled),
// TODO: get formatters from configuration somehow
//             @"dateStart" : self.dateStart,
//             @"dateEnd" : self.dateEnd,
             @"fileId" : @(self.fileId)
    };
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
