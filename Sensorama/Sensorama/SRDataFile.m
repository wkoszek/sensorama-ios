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
        NSString *timezoneString = [[NSTimeZone localTimeZone] name];
        _timezone = timezoneString;

        _configuration = cfg;
        _fileId = fileId;
        _username = userName;
        _desc = @"Sensorama_iOS";
        _sampleInterval = [cfg sampleInterval];
        ///* need to do something about device_info */

        return self;
    }

    return self;
}

- (instancetype) initWithConfiguration:(SRCfg *)cfg userName:(NSString *)userName {
    NSInteger fileId = [SRDataFile newFileId];
    return [self initWithConfiguration:cfg fileId:fileId userName:userName];
}

+ (NSInteger) newFileId {
    RLMResults<SRDataFile *> *sortedFiles = [[SRDataFile allObjects] sortedResultsUsingProperty:@"fileId" ascending:YES];
    SRDataFile *lastDataFile = [sortedFiles lastObject];
    NSInteger nextFileId = lastDataFile.fileId + 1;
    return nextFileId;
}

- (void)startWithDate:(NSDate *)dateStart {
    self.dateStart = dateStart;
}

- (void) updateWithPoint:(SRDataPoint *)point {
    [self.dataPoints addObject:point];
}

- (void) finalizeWithDate:(NSDate *)dateEnd {
    SRPROBE0();

    /* do something about device_info */
    /* sensor states */
    self.dateEnd = dateEnd;
}

- (void) saveWithSync:(BOOL)doSync {
    SRDataStore *datastore = [SRDataStore sharedInstance];
    [datastore insertDataFile:self];
    [datastore insertDataPoints:self.dataPoints];
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
    return @{
             @"username" : self.username,
             @"desc" : self.desc,
             @"timezone" : self.timezone,
             @"interval" : @(self.sampleInterval),
             @"accEnabled" : @(self.accEnabled),
             @"magEnabled" : @(self.magEnabled),
             @"gyroEnabled" : @(self.gyroEnabled),
             @"dateStart" : [self.configuration stringFromDate:self.dateStart],
             @"dateEnd" : [self.configuration stringFromDate:self.dateEnd],
             @"fileId" : @(self.fileId)
    };
}

- (void) exportWithSync:(BOOL)doSync {
    SRPROBE0();

    RLMResults<SRDataFile *> *dataFile = [SRDataFile objectsWhere:@"fileId = %d", self.fileId];
    NSAssert([dataFile count] == 1, @"more than one file with the same ID!");
    NSMutableDictionary *wholeFile = [[NSMutableDictionary alloc] initWithDictionary:[dataFile[0] toDict]];
    RLMResults<SRDataPoint *> *points = [SRDataFile objectsWhere:@"fileId = %d", self.fileId];
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
