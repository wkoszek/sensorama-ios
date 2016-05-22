//
//  SRDataFileExporterMailgun.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 20/05/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRDataFileExporterMailgun.h"

#import "SRAuth.h"
#import "SRUtils.h"
#import "SRDebug.h"
#import "SRDataFile.h"
#import "SRDataStore.h"

#import "SensoramaVars.h"

@implementation SRDataFileExporterMailgun

- (void)exportWithFile:(SRDataFile *)dataFile;
{
#if 0
    NSString *fileBaseName = [dataFile fileBasePathName];
    NSURL *fileURL = [NSURL fileURLWithPath:[dataFile filePathName]];
    SRPROBE1(fileURL);

    Mailgun *mailgun = [Mailgun clientWithDomain:@"samples.mailgun.org" apiKey:@"key-3ax6xnjp29jd6fds4gc373sgvjxteol0"];
    [mailgun sendMessageTo:@"Jay Baird <jay.baird@rackspace.com>"
                      from:@"Excited User <someone@sample.org>"
                   subject:@"Mailgun is awesome!"
                      body:@"A unicode snowman for you! ☃"];


#endif
}

@end
