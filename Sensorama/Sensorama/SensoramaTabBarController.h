//
//  SensoramaTabBarController.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/3/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SREngine.h"

@interface SensoramaTabBarController : UITabBarController

@property (strong, nonatomic) SREngine *engine;

@end
