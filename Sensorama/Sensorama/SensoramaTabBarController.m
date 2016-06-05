//
//  SensoramaTabBarController.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/3/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SensoramaTabBarController.h"
#import "ActivityViewController.h"
#import "AccountTableViewController.h"

@interface SensoramaTabBarController ()


@end

@implementation SensoramaTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.engine = [SREngine new];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
    NSInteger idxToRemove = [self viewControllerIndexByClass:[ActivityViewController class]];
    [viewControllers removeObjectAtIndex:idxToRemove];
    self.viewControllers = viewControllers;

    // XXugleee
    NSInteger idxToRemove2 = [self viewControllerIndexByClass:[AccountTableViewController class]];
    [viewControllers removeObjectAtIndex:idxToRemove2];
    self.viewControllers = viewControllers;
}

- (id) viewControllerByClass:(id)objClass {
    for (UIViewController *uivc in self.viewControllers) {
        if ([uivc isKindOfClass:objClass]) {
            return uivc;
        }
    }
    return nil;
}

- (NSInteger) viewControllerIndexByClass:(id)objClass {
    NSInteger idx = 0;
    for (UIViewController *uivc in self.viewControllers) {
        if ([uivc isKindOfClass:objClass]) {
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
