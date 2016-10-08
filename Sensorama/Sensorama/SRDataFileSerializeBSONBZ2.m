//
// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRDataFileSerializeBSONBZ2.m
//  Sensorama

#import "SRDataFileSerializeBSONBZ2.h"

@implementation SRDataFileSerializeBSONBZ2

- (void) serializeWithFile:(SRDataFile *)dataFile {
#if 0
    NSError *error = nil;

    NSDictionary *fileInMemory = [dataFile serializeToMemory];


    NSData *sampleDataBSON = [BSONSerialization BSONDataWithDictionary:self.srContent error:&errorBSON];
    NSData *compressedDataBSON = [BZipCompression compressedDataWithData:sampleDataBSON
                                                               blockSize:BZipDefaultBlockSize
                                                              workFactor:BZipDefaultWorkFactor
                                                                   error:&error];
    SRPROBE1(@([sampleDataBSON length]));
    SRPROBE1(@([compressedDataBSON length]));

    NSString *outFileName = [dataFile filePathName];
    [dataFile serializeWithData:compressedDataMP path:outFileName];
#endif
}



@end
