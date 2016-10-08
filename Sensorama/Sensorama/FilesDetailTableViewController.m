// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  FilesDetailTableViewController.m
//  Sensorama

#import "FilesDetailTableViewController.h"

@interface FilesDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleValue;
@property (weak, nonatomic) IBOutlet UILabel *sizeValue;
@property (weak, nonatomic) IBOutlet UILabel *lengthValue;
@end

@implementation FilesDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = YES;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1 && [indexPath row] == 0) { // Delete
        NSLog(@"Delete");

        UIAlertController *alert=   [UIAlertController
                                      alertControllerWithTitle:@"Will delete file"
                                      message:@"Are you sure?"
                                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* actionYes = [UIAlertAction
                             actionWithTitle:@"Yes"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 NSLog(@"yes delete");
                                 [self.dataFile deleteFile];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                                 [self performSegueWithIdentifier:@"fromDetailToFiles" sender:self];
                             }];
        UIAlertAction* actionNo = [UIAlertAction
                            actionWithTitle:@"No"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                NSLog(@"no delete");
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }];
        [alert addAction:actionYes];
        [alert addAction:actionNo];

        [self presentViewController:alert animated:YES completion:nil];
    }
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:NO];
}

@end
