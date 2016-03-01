//
//  SRUtils.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SRUtils.h"

@implementation SRUtils

+ (UIColor *)colorFromHex:(uint32_t)rgb {
    CGFloat r = ((rgb   >>  16) & 0xff) / 255.0;
    CGFloat g = ((rgb   >>   8) & 0xff) / 255.0;
    CGFloat b = ((rgb   & 0xff) & 0xff) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

+ (UIColor *)mainColor {
    return [SRUtils colorFromHex:0xc51162];
}


@end
