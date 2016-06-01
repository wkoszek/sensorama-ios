//
//  SRDataStore.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRDataStore.h"
#import "SRDataFile.h"
#import "SRUtils.h"
#import "SRDataFileSerializerJSONBZ2.h"
#import "SRDataFileExporterS3.h"
#import "SRDataFileExporterMailgun.h"

@implementation SRDataStore

+ (SRDataStore *)sharedInstance {
    static SRDataStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];

        sharedInstance.serializers = [NSMutableArray new];
        sharedInstance.exporters = [NSMutableArray new];

        SRDataFileSerializerJSONBZ2 *serializedJSONBZ2 = [SRDataFileSerializerJSONBZ2 new];
        [sharedInstance addSerializer:serializedJSONBZ2];

        SRDataFileExporterS3 *exporterS3 = [SRDataFileExporterS3 new];
        [sharedInstance addExporter:exporterS3];

        SRDataFileExporterMailgun *exporterMailgun = [SRDataFileExporterMailgun new];
        [sharedInstance addExporter:exporterMailgun];
    });
    return sharedInstance;
}

- (void) addSerializer:(id<SRDataFileSerializeDelegate>)serializer {
    [self.serializers addObject:serializer];
}

- (void) addExporter:(id<SRDataFileExportDelegate>)exporter {
    [self.exporters addObject:exporter];
}

- (void) serializeFile:(SRDataFile *)dataFile {
    for (id<SRDataFileSerializeDelegate> delegate in self.serializers) {
        [delegate serializeWithFile:dataFile];
    }
}

- (void) exportFiles:(NSArray<SRDataFile *> *)filesToSync {
    if (![self exportCheckAndNotify:filesToSync]) {
        return;
    }

    for (id<SRDataFileExportDelegate> delegate in self.exporters) {
        for (SRDataFile *fileToSyncOne in filesToSync) {
            [delegate exportWithFile:fileToSyncOne];
        }
    }
}

- (BOOL) exportCheckAndNotify:(NSArray<SRDataFile *> *)filesToSync {
    BOOL isOK = NO;
    int howManyToExport = (int)[filesToSync count];

    if (![SRUtils hasWifi]) {
        [SRUtils notifyWarn:[NSString stringWithFormat:@"No Wi-Fi. Will export %d files later", howManyToExport]];
    } else {
        [SRUtils notifyOK:[NSString stringWithFormat:@"Exporting %d files now", howManyToExport]];
        isOK = YES;
    }
    return isOK;
}

+ (void) handleMigrations {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    int currentSchemaVersion = [[SRUtils bundleVersionString] intValue];

    assert(currentSchemaVersion > 60);

    config.schemaVersion = currentSchemaVersion;

    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 60) {
            [migration enumerateObjects:SRDataFile.className
                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
                                      newObject[@"isExported"] = @(false);
                                  }];
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    [RLMRealm defaultRealm];
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
