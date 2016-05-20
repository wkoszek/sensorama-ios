//
//  SRDataFile.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <MPMessagePack/MPMessagePack.h>

#import "SRDataFile.h"
#import "SRDataStore.h"
#import "SRDataPoint.h"
#import "SRUtils.h"
#import "SRDebug.h"

@implementation SRDataFile

@synthesize configuration = _configuration;

+ (NSString *)primaryKey
{
    return @"fileId";
}

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{@"fileId": @(0) };
//}

- (instancetype) initWithConfiguration:(SRCfg *)cfg fileId:(NSInteger)fileId
                              userName:(NSString *)userName {
    self = [super init];
    if (!self) {
        return self;
    }
    NSString *timezoneString = [[NSTimeZone localTimeZone] name];
    _timezone = timezoneString;

    _configuration = cfg;
    _fileId = fileId;
    _username = userName;
    _desc = @"Sensorama_iOS";
    _sampleInterval = [cfg sampleInterval];
    _dataPoints = [NSMutableArray new];
    _dateStart = nil;
    _dateEnd = nil;
    _isExported = NO;

     return self;
}

- (instancetype) initWithConfiguration:(SRCfg *)cfg userName:(NSString *)userName {
    NSInteger fileId = [SRDataFile newFileId];
    return [self initWithConfiguration:cfg fileId:fileId userName:userName];
}

- (instancetype) init {
    return [self initWithConfiguration:[SRCfg defaultConfiguration] userName:@""];
}

- (SRCfg *)configuration {
    if (_configuration == nil) {
        return [SRCfg defaultConfiguration];
    }
    return _configuration;
}

+ (NSInteger) newFileId {
    RLMResults<SRDataFile *> *sortedFiles = [[SRDataFile allObjects] sortedResultsUsingProperty:@"fileId" ascending:YES];
    SRDataFile *lastDataFile = [sortedFiles lastObject];
    NSInteger nextFileId = lastDataFile.fileId + 1;

    return nextFileId;
}

- (void) pruneFileCache {
    // XXTODO remove old files
}

+ (dispatch_queue_t) saveQueue {
    static dispatch_once_t onceToken;
    dispatch_queue_t __block saveQueue;
    saveQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_once(&onceToken, ^{
        saveQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    });
    return saveQueue;
}

- (void)startWithDate:(NSDate *)dateStart {
    self.dateStart = dateStart;
}

- (void) updateWithPoint:(SRDataPoint *)point {
    point.fileId = self.fileId;
    [self.dataPoints addObject:point];

    dispatch_once(&(_onceToken), ^{
        [self startWithDate:[NSDate date]];
    });
    self.dateEnd = [NSDate date];
}

- (void) finalizeWithDate:(NSDate *)dateEnd {
    SRPROBE0();

    self.dateEnd = dateEnd;
}

- (void) save {
    dispatch_sync([SRDataFile saveQueue], ^{
        SRDataStore *datastore = [SRDataStore sharedInstance];
        [datastore insertDataFile:self];
    });
}

- (void)savePoints {
    dispatch_sync([SRDataFile saveQueue], ^{
        SRDataStore *datastore = [SRDataStore sharedInstance];
        [datastore insertDataPoints:self.dataPoints];
    });
}

- (void) saveWithExport:(BOOL)doExport {
    [self save];
    [self savePoints];
    if (doExport) {
        [self serializeWithExport:doExport];
    }
}

- (NSString *) stringDateStart {
    NSString *ret = [self.configuration stringFromDate:self.dateStart];
    assert(ret != nil);
    return ret;
}

- (NSString *) stringDateEnd {
    NSString *ret = [self.configuration stringFromDate:self.dateEnd];
    assert(ret != nil);
    return ret;
}

- (NSString *)printableLabel {
    return [NSString stringWithFormat:@"%@-%@", [self stringDateStart], [self stringDateEnd]];
}

- (NSString *)printableLabelDetails {
    return [NSString stringWithFormat:@"Exported: %@", self.isExported ? @"yes" : @"no"];
}

- (NSDictionary *)fileInfoDict {
    return @{
             @"file_info" : @{
                     @"username" : self.username,
                     @"desc" : self.desc,
                     @"timezone" : self.timezone,
                     @"interval" : @(self.sampleInterval),
                     @"accEnabled" : @(self.accEnabled),
                     @"magEnabled" : @(self.magEnabled),
                     @"gyroEnabled" : @(self.gyroEnabled),
                     @"dateStart" : [self stringDateStart],
                     @"dateEnd" : [self stringDateEnd],
                     @"fileId" : @(self.fileId)
            },
    };
}

- (NSString *) fileBasePathName {
    return [NSString stringWithFormat:@"%@-%@.json.bz2", [self stringDateStart], [self stringDateEnd]];
}

- (NSString *) filePathName {
    NSString *destDirString = [self.configuration pathForDataFiles];
    NSString *baseFileName = [self fileBasePathName];
    NSString *targetPath = [NSString stringWithFormat:@"%@/%@", destDirString, baseFileName];
    return targetPath;
}

- (NSDictionary *)serializeToMemory {
    NSDictionary *fileInfoDict = [self fileInfoDict];
    NSMutableDictionary *wholeFile = [[NSMutableDictionary alloc] initWithDictionary:fileInfoDict];

    RLMResults<SRDataPoint *> *pointsRaw = [SRDataPoint objectsWhere:@"fileId = %d", self.fileId];
    NSMutableArray <NSDictionary *> *points = [NSMutableArray new];
    for (SRDataPoint *pointRaw in pointsRaw) {
        NSDictionary *pointDict = [pointRaw toDict];
        [points addObject:pointDict];
    }
    [wholeFile setObject:points forKey:@"points"];
    [wholeFile setObject:[SRUtils deviceInfo] forKey:@"device_info"];

    return wholeFile;
}

+ (NSArray <SRDataFile *> *) filesWithPredicate:(NSPredicate *)predicate {
    RLMResults<SRDataFile *> *filesResults = [SRDataFile objectsWithPredicate:predicate];
    NSMutableArray <SRDataFile *> *files = [NSMutableArray new];
    for (SRDataFile *tmpFile in filesResults) {
        [files addObject:tmpFile];
    }
    return files;
}

+ (NSArray <SRDataFile *> *) filesNotExported {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isExported == 0"];
    return [SRDataFile filesWithPredicate:predicate];
}

- (void) serializeWithExport:(BOOL)doExport {
    SRPROBE0();

    [[SRDataStore sharedInstance] serializeFile:self];
    if (doExport) {
        [[SRDataStore sharedInstance] exportFiles:[SRDataFile filesNotExported]];
    }
    [self pruneFileCache];
}

- (void) serializeWithData:(NSData *)data path:(NSString *)filePath {
    [data writeToFile:filePath atomically:NO];
}

@end
