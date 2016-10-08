//
// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SensoramaTabBarController.m
//  Sensorama


#import "SensoramaTabBarController.h"
#import "ActivityViewController.h"

@interface SensoramaTabBarController ()


@end

@implementation SensoramaTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.engine = [SREngine new];
    // Do any additional setup after loading the view.
}

- (NSInteger) viewControllerIndexByClass:(id)objClass {
    NSInteger idx = 0;
    for (UIViewController *uivc in self.viewControllers) {
        if ([uivc.childViewControllers[0] isKindOfClass:objClass]) {
            return idx;
        }
        idx += 1;
    }
    return -1;
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
