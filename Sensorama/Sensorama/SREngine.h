// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SREngine.h
//  Sensorama

@import Foundation;

#import "SRDataFile.h"

@interface SREngine : NSObject

- (instancetype) init;
- (void) recordingStart;
- (void) recordingStopWithExport:(BOOL)doExport;
- (void) recordingUpdate;
- (NSArray<SRDataFile *> *) allRecordedFiles;

@end
