//
//  SRDataFileExporterMailgun.h
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 20/05/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import Foundation;

#import "SRDataStore.h"
#import "SRDataFile.h"

@interface SRDataFileExporterMailgun : NSObject <SRDataFileExportDelegate>

- (void)exportWithFile:(SRDataFile *)dataFile;

@end