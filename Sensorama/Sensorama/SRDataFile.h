//
// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRDataFile.h
//  Sensorama


#import <Foundation/Foundation.h>
#import "Realm/Realm.h"

#import "SRDataPoint.h"

@class SRCfg;

@interface SRDataFile : RLMObject

@property NSString *username;
@property NSString *desc;
@property NSString *timezone;

@property NSInteger sampleInterval;
@property BOOL accEnabled;
@property BOOL magEnabled;
@property BOOL gyroEnabled;

@property NSDate *dateStart;
@property NSDate *dateEnd;
@property NSInteger fileId;
@property BOOL isExported;

@property (nonatomic, readonly) NSMutableArray *dataPoints;

+ (dispatch_queue_t) saveQueue;

- (instancetype) initWithConfiguration:(SRCfg *)cfg fileId:(NSInteger)fileId
                              userName:(NSString *)userName;
- (instancetype) initWithConfiguration:(SRCfg *)cfg userName:(NSString *)userName;

- (void) startWithDate:(NSDate *)dateStart;
- (void) updateWithPoint:(SRDataPoint *)point;
- (void) finalizeWithDate:(NSDate *)dateEnd;
- (void) saveWithExport:(BOOL)doExport;
- (void) save;
- (void) savePoints;
- (void) pruneFileCache;
- (void) serializeWithData:(NSData *)data path:(NSString *)filePath;
- (void) deleteFile;

- (NSString *) fileBasePathName;
- (NSString *) filePathName;
- (NSString *) printableLabel;
- (NSString *) printableLabelDetails;

// General serialize/export methods.
- (NSDictionary *)serializeToMemory;

// Not in the persistent data model.
@property (nonatomic, readonly) SRCfg *configuration;
@property (nonatomic, readonly) dispatch_once_t onceToken;

@end
RLM_ARRAY_TYPE(SRDataFile)

