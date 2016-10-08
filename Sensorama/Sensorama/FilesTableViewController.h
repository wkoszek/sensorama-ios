// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  FilesTableViewController.h
//  Sensorama


@import UIKit;

#import "SRDataFile.h"

@interface FilesTableViewController : UITableViewController <UITableViewDataSource>

@property (nonatomic) NSArray<SRDataFile *> *filesList;

@end
