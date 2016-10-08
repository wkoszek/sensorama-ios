//
// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRDataFileExporterS3.h
//  Sensorama


@import Foundation;

#import "SRDataStore.h"
#import "SRDataFile.h"

@interface SRDataFileExporterS3 : NSObject <SRDataFileExportDelegate>

- (void)exportWithFile:(SRDataFile *)dataFile;

@end
