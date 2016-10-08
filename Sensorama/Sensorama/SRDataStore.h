//
// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRDataStore.h
//  Sensorama

@import Foundation;

#import "SRDataPoint.h"
#import "SRDataFile.h"

@protocol SRDataFileSerializeDelegate <NSObject>
@required
- (void)serializeWithFile:(SRDataFile *)dataFile;
@end

@protocol SRDataFileExportDelegate <NSObject>
@required
- (void)exportWithFile:(SRDataFile *)dataFile;
@end


@interface SRDataStore : NSObject

@property (nonatomic) NSMutableArray <id<SRDataFileSerializeDelegate>> *serializers;
@property (nonatomic) NSMutableArray <id<SRDataFileExportDelegate>> *exporters;

+ (SRDataStore *)sharedInstance;
- (void) addSerializer:(id<SRDataFileSerializeDelegate>)serializer;
- (void) addExporter:(id<SRDataFileExportDelegate>)exporter;

+ (void) initAndHandleMigrations;

- (void) insertDataFile:(SRDataFile *)dataFile;
- (void) removeDataFile:(SRDataFile *)dataFile;

- (void) insertDataPoints:(NSArray<SRDataPoint *> *)points;
- (void) removeDataPoints:(NSArray<SRDataPoint *> *)points;

- (void) serializeFile:(SRDataFile *)fileInMemory;
- (void) exportFiles:(NSArray <SRDataFile *> *)filesToSync;

- (void) markExportedFileId:(NSInteger)fileId;


@end
