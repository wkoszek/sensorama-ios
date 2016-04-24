//
//  FilesTableViewController.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import UIKit;

#import "SRDataFile.h"

@interface FilesTableViewController : UITableViewController <UITableViewDataSource>

@property (nonatomic) NSArray<SRDataFile *> *filesList;

@end
