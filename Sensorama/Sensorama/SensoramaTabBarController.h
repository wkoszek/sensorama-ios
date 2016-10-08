//
// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SensoramaTabBarController.h
//  Sensorama


#import <UIKit/UIKit.h>
#import "SREngine.h"

@interface SensoramaTabBarController : UITabBarController

@property (strong, nonatomic) SREngine *engine;

- (NSInteger) viewControllerIndexByClass:(id)objClass;

@end
