// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SettingsTableViewController.h
//  Sensorama


#import <UIKit/UIKit.h>
#import "InAppSettingsKit/IASKAppSettingsViewController.h"
#import "InAppSettingsKit/IASKSettingsReader.h"


@interface SettingsTableViewController : IASKAppSettingsViewController <IASKSettingsDelegate>

@end
