//
//  SRDataFile.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <BZipCompression/BZipCompression.h>
#import <MPMessagePack/MPMessagePack.h>

#import "SRDataFile.h"
#import "SRDataStore.h"
#import "SRDataPoint.h"
#import "SRDebug.h"

@implementation SRDataFile

//+ (NSString *)primaryKey
//{
//    return @"fileId";
//}
//
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
    ///* need to do something about device_info */

     return self;
}

- (instancetype) initWithConfiguration:(SRCfg *)cfg userName:(NSString *)userName {
    NSInteger fileId = [SRDataFile newFileId];
    return [self initWithConfiguration:cfg fileId:fileId userName:userName];
}

- (instancetype) init {
    return [self initWithConfiguration:[SRCfg defaultConfiguration] userName:@""];
}

+ (NSInteger) newFileId {
    RLMResults<SRDataFile *> *sortedFiles = [[SRDataFile allObjects] sortedResultsUsingProperty:@"fileId" ascending:YES];
    SRDataFile *lastDataFile = [sortedFiles lastObject];
    NSInteger nextFileId = lastDataFile.fileId + 1;

    return nextFileId;
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
    self.dateEnd = [NSDate date];       // XXTODO: figure if we could re-use curTime
}

- (void) finalizeWithDate:(NSDate *)dateEnd {
    SRPROBE0();

    /* do something about device_info */
    /* sensor states */
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

- (void) saveWithSync:(BOOL)doSync {
    [self save];
    [self savePoints];
    if (doSync) {
        [self exportWithSync:doSync];
    }
}

- (NSString *)printableLabel {
    return [NSString stringWithFormat:@"%@-%@",
            [self.configuration stringFromDate:self.dateStart],
            [self.configuration stringFromDate:self.dateEnd]];
}

- (NSString *)printableLabelDetails {
    return @"details";
}

- (NSDictionary *)toDict {
    NSString *dateStartString = [self.configuration stringFromDate:self.dateStart];
    NSString *dateEndString = [self.configuration stringFromDate:self.dateEnd];
    NSAssert(dateStartString != nil, @"dateStartString can't be nil");
    NSAssert(dateEndString != nil, @"dateEndString can't be nil");
    return @{
             @"username" : self.username,
             @"desc" : self.desc,
             @"timezone" : self.timezone,
             @"interval" : @(self.sampleInterval),
             @"accEnabled" : @(self.accEnabled),
             @"magEnabled" : @(self.magEnabled),
             @"gyroEnabled" : @(self.gyroEnabled),
             @"dateStart" : dateStartString,
             @"dateEnd" : dateEndString,
             @"fileId" : @(self.fileId)
    };
}

- (void) exportWithSync:(BOOL)doSync {
    SRPROBE0();

    NSDictionary *dataFileDict = [self toDict];
    NSMutableDictionary *wholeFile = [[NSMutableDictionary alloc] initWithDictionary:dataFileDict];

    RLMResults<SRDataPoint *> *pointsRaw = [SRDataPoint objectsWhere:@"fileId = %d", self.fileId];
    NSMutableArray <NSDictionary *> *points = [NSMutableArray new];
    for (SRDataPoint *pointRaw in pointsRaw) {
        NSDictionary *pointDict = [pointRaw toDict];
        [points addObject:pointDict];
    }
    [wholeFile setObject:points forKey:@"points"];

    NSError *error = nil;
    NSData *sampleDataJSON = [NSJSONSerialization dataWithJSONObject:wholeFile
                                                             options:NSJSONWritingPrettyPrinted error:&error];

    NSLog(@"%@", [[NSString alloc] initWithData:sampleDataJSON encoding:NSUTF8StringEncoding]);
    NSData *compressedDataJSON = [BZipCompression compressedDataWithData:sampleDataJSON
                                                               blockSize:BZipDefaultBlockSize
                                                              workFactor:BZipDefaultWorkFactor
                                                                   error:&error];
    SRPROBE1(@([sampleDataJSON length]));
    SRPROBE1(@([compressedDataJSON length]));

#if 0

    NSData *sampleDataMP = [self.srContent mp_messagePack];
    NSData *compressedDataMP = [BZipCompression compressedDataWithData:sampleDataMP
                                                             blockSize:BZipDefaultBlockSize
                                                            workFactor:BZipDefaultWorkFactor
                                                                 error:&error];
    SRPROBE1(@([sampleDataMP length]));
    SRPROBE1(@([compressedDataMP length]));


    NSError *errorBSON = nil;
    NSData *sampleDataBSON = [BSONSerialization BSONDataWithDictionary:self.srContent error:&errorBSON];
    NSData *compressedDataBSON = [BZipCompression compressedDataWithData:sampleDataBSON
                                                               blockSize:BZipDefaultBlockSize
                                                              workFactor:BZipDefaultWorkFactor
                                                                   error:&error];
    SRPROBE1(@([sampleDataBSON length]));
    SRPROBE1(@([compressedDataBSON length]));

    [compressedDataJSON writeToFile:pathString atomically:NO];

    if (doSync) {
        SRSync *syncFile = [[SRSync alloc] initWithPath:pathString];
        [syncFile syncStart];
    }
#endif
}


//- (NSString *)samplePath {
//    SRPROBE0();
//
//    NSString *dateString = [NSString stringWithFormat:@"%@_%@",
//                            [self.srCfg stringFromDate:self.startDate],
//                            [self.srCfg stringFromDate:self.endDate]];
//    NSString *fileName = [NSString stringWithFormat:@"%@.json.bz2", dateString];
//    NSString *sampleFilePath = [self.pathDocuments stringByAppendingPathComponent:fileName];
//
//    return sampleFilePath;
//}


@end
