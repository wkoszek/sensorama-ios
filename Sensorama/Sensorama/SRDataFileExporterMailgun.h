//
// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRDataFileExporterMailgun.h
//  Sensorama


@import Foundation;

#import "SRDataStore.h"
#import "SRDataFile.h"

@interface SRDataFileExporterMailgun : NSObject <SRDataFileExportDelegate>

- (void)exportWithFile:(SRDataFile *)dataFile;

@end
