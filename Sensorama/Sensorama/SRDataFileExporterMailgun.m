//
//  SRDataFileExporterMailgun.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 20/05/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRDataFileExporterMailgun.h"
#import "mailgun/Mailgun.h"
#import "mailgun/MGMessage.h"

#import "SRAuth.h"
#import "SRUtils.h"
#import "SRDebug.h"
#import "SRDataFile.h"
#import "SRDataStore.h"

#import "SensoramaVars.h"

@implementation SRDataFileExporterMailgun

- (void)exportWithFile:(SRDataFile *)dataFile;
{

    SRPROBE1(dataFile);

    NSString *exportMail = [[NSUserDefaults standardUserDefaults] objectForKey:@"exportEmail"];
    if ([exportMail boolValue] == 0) {
        NSLog(@"exportMail == 0, skipping sending email");
        return;
    }

    MGMessage *msg = [[MGMessage alloc] initWithFrom:@"sensorama@data.sensorama.org"
                                                  to:[[SRAuth currentProfile] email]
                                             subject:@"Sensorama Data File"
                                                body:@"Hello\n\nAttached is your Sensorama file\n\nSensorama"];

    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:[dataFile filePathName]];
    [msg addAttachment:fileData withName:[dataFile fileBasePathName] type:@"application/x-bzip2"];

    NSString *apiKey = [NSString stringWithUTF8String:SENSORAMA_MAILGUN_API_KEY];
    Mailgun *mailgun = [Mailgun clientWithDomain:@"data.sensorama.org" apiKey:apiKey];

    NSInteger fileId = dataFile.fileId;
    [mailgun sendMessage:msg success:^(NSString *messageId) {
        [[SRDataStore sharedInstance] markExportedFileId:fileId];
    } failure:^(NSError *error) {
        NSLog(@"failure to export! file=%@", dataFile);
    }];
}

@end
