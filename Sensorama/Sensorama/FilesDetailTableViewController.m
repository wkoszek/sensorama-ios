//
//  FilesDetailTableViewController.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 14/09/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "FilesDetailTableViewController.h"

@interface FilesDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleValue;
@property (weak, nonatomic) IBOutlet UILabel *sizeValue;
@property (weak, nonatomic) IBOutlet UILabel *lengthValue;
@end

@implementation FilesDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *filePath = [self.dataFile filePathName];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
    NSTimeInterval timeDiff = [self.dataFile.dateEnd timeIntervalSinceDate:self.dataFile.dateStart];

    [self.titleValue  setText:[self.dataFile printableLabel]];
    [self.sizeValue   setText:[NSString stringWithFormat:@"%@", fileSize]];
    [self.lengthValue setText:[NSString stringWithFormat:@"%d", (int)timeDiff]];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        return nil;
    }
    return indexPath;
}

@end
