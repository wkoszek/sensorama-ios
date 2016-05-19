//
//  SRSync.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/11/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import Foundation;

#import "SRDataStore.h"
#import "SRDataFile.h"

@interface SRDataFileExporterS3 : NSObject <SRDataFileExportDelegate>

- (void)exportWithFile:(SRDataFile *)dataFile;

@end
