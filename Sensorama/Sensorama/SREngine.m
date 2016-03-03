//
//  SREngine.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "CoreMotion/CoreMotion.h"

#import "SREngine.h"

@interface SREngine ()

@property (strong, nonatomic) CMMotionManager *motionManager;

@end

@implementation SREngine

- (instancetype) init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void) recordingStart {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.motionManager = [CMMotionManager new];
    });

    NSLog(@"acc act:%d avail:%d",
          self.motionManager.accelerometerActive,
          self.motionManager.accelerometerAvailable);

}

- (void) recordingStop {

}

- (void)sensoramaStart {

}

@end
