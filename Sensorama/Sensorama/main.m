// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  main.m
//  Sensorama
//

#import <UIKit/UIKit.h>
#import <NSLogger/NSLogger.h>

#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        LoggerStart(LoggerGetDefaultLogger());
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
