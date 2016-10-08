// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  FilesDetailTableViewController.h
//  Sensorama

#import <UIKit/UIKit.h>
#import "SRDataFile.h"

@interface FilesDetailTableViewController : UITableViewController

@property (nonatomic) SRDataFile *dataFile;

@end
