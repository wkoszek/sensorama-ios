//
//  SensoramaTabBarController.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/3/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SensoramaTabBarController.h"

@interface SensoramaTabBarController ()


@end

@implementation SensoramaTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.srEngine = [SREngine new];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"dest = %@", [segue destinationViewController]);
}

@end
