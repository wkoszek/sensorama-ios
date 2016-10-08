// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  AboutViewController.m
//  Sensorama


#import "Crashlytics/Crashlytics.h"

#import "AboutViewController.h"

#import "SRUsageStats.h"


@interface AboutViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forceCrashButton;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.forceCrashButton;
    [SRUsageStats eventAppSettingsAbout];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)forceCrash:(id)sender {
    NSLog(@"force crash!");
    [[Crashlytics sharedInstance] crash];
}

@end
