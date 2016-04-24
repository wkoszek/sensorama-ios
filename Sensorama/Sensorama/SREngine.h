//
//  SREngine.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import Foundation;

#import "SRDataFile.h"

@interface SREngine : NSObject

- (instancetype) init;
- (void) recordingStart;
- (void) recordingStopWithSync:(BOOL)doSync;
- (void) recordingUpdate;
- (NSArray<SRDataFile *> *) allRecordedFiles;

@end
