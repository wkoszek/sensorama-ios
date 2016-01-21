// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  ViewController.m
//  Sensorama
//

#import "ViewController.h"
#import "Crashlytics/Crashlytics.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *forceCrashButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)forceCrash:(UIButton *)sender {
    [[Crashlytics sharedInstance] crash];
}

@end
