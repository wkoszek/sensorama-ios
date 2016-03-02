// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  ViewController.m
//  Sensorama
//

#import "ViewController.h"
#import "Crashlytics/Crashlytics.h"
#import "CoreMotion/CoreMotion.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *forceCrashButton;

@property (strong, nonatomic) CMMotionManager *motionManager;
@end

@implementation ViewController

- (void)sensoramaStart {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.motionManager = [CMMotionManager new];
    });

    NSLog(@"acc act:%d avail:%d",
          self.motionManager.accelerometerActive,
          self.motionManager.accelerometerAvailable);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sensoramaStart];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
