//
//  SREngine.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "CoreMotion/CoreMotion.h"

#import "SREngine.h"
#import "SRCfg.h"

@interface SREngine ()

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSString *pathDocuments;
@property (strong, nonatomic) SRCfg *srCfg;

@end

@implementation SREngine

- (instancetype) init {
    self = [super init];
    if (self) {
        self.fileManager = [NSFileManager defaultManager];
        self.pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.srCfg = [SRCfg new];
    }
    return self;
}

- (void)storageDebug {

}

- (void) recordingStart {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.motionManager = [CMMotionManager new];
    });

    NSLog(@"acc act:%d avail:%d",
          self.motionManager.accelerometerActive,
          self.motionManager.accelerometerAvailable);

    NSString *appFile = [self.pathDocuments stringByAppendingPathComponent:@"MyFile"];

    NSLog(@"%@ %@", [self.fileManager currentDirectoryPath], appFile);
    NSLog(@"%@", [self.srCfg sensoramaTimeString]);
    NSLog(@"%@", [self.srCfg sensoramaDateString]);


}

- (void) recordingStop {

}

- (void)sensoramaStart {

}

@end
