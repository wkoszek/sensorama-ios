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

    for (SRDataFile *fileToSyncOne in filesToSync) {
        for (id<SRDataFileExportDelegate> delegate in self.exporters) {
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

- (void) markExportedFileId:(NSInteger)fileId {
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<SRDataFile *> *results = [SRDataFile objectsWhere:@"fileId = %ld", fileId];
    SRDataFile *fileToMark = results[0];
    [realm beginWriteTransaction];
    fileToMark.isExported = true;
    [realm addOrUpdateObject:fileToMark];
    [realm commitWriteTransaction];
    NSLog(@"File should be marked as exported");
}

+ (void) initAndHandleMigrations {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirPath = [paths firstObject];
    [[NSFileManager defaultManager] createDirectoryAtPath:appSupportDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *realmPath = [appSupportDirPath stringByAppendingPathComponent:@"default.realm"];
    config.fileURL = [NSURL fileURLWithPath:realmPath];
    [RLMRealmConfiguration setDefaultConfiguration:config];
    NSLog(@"XXXX path=%@ realmURL: '%@'", realmPath, config.fileURL);

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

- (void) insertOrRemoveDataFile:(SRDataFile *)dataFile willRemove:(BOOL)willRemove {
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    if (willRemove) {
        [realm deleteObject:dataFile];
    } else {
        [realm addOrUpdateObject:dataFile];
    }
    [realm commitWriteTransaction];
}

- (void) insertDataFile:(SRDataFile *)dataFile {
    [self insertOrRemoveDataFile:dataFile willRemove:NO];
}

- (void) removeDataFile:(SRDataFile *)dataFile {
    NSInteger fileId = dataFile.fileId;
    [self insertOrRemoveDataFile:dataFile willRemove:YES];
    [self removeDataPoints:(NSArray *)[SRDataPoint objectsWhere:@"fileId = %d", fileId]];
}

- (void) insertOrRemoveDataPoints:(NSArray<SRDataPoint *> *) points willRemove:(BOOL)willRemove {
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    if (willRemove) {
        [realm deleteObjects:points];
    } else {
        [realm addOrUpdateObjectsFromArray:points];
    }
    [realm commitWriteTransaction];
}

- (void) insertDataPoints:(NSArray<SRDataPoint *> *)points {
    [self insertOrRemoveDataPoints:points willRemove:NO];
}

- (void) removeDataPoints:(NSArray<SRDataPoint *> *)points {
    [self insertOrRemoveDataPoints:points willRemove:YES];
}

@end
