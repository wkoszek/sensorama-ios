//
//  FilesTableViewController.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "FilesTableViewController.h"
#import "SensoramaTabBarController.h"
#import "SRUsageStats.h"
#import "SRUtils.h"
#import "SRFile.h"


@interface FilesTableViewController ()

@end

@implementation FilesTableViewController

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%s", __func__);

    [super viewDidAppear:animated];
    [self.tabBarController setTitle:@"Files"];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    SensoramaTabBarController *tabController = (SensoramaTabBarController *)self.parentViewController;
    self.filesList = [tabController.srEngine filesRecorded];
    NSLog(@"filelistZZZ=%@", self.filesList);


    [SRUsageStats eventAppFiles];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"here");
    NSString *cellName = @"filesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }

    NSInteger howManyItems = [self.filesList count];
    NSInteger whichItem = indexPath.row % howManyItems;
    if (whichItem == 0) {
        [cell.imageView setImage:[UIImage imageNamed:@"iconFileNew"]];
        [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.imageView setTintColor:[SRUtils mainColor]];
    } else {
        [cell.imageView setImage:[UIImage imageNamed:@"iconFile"]];
    }


    SRFile *file = [[SRFile alloc] initWithFileName:self.filesList[whichItem]];
    NSString *itemString = [file printableLabel];

    [cell.textLabel setText:itemString];
    [cell.detailTextLabel setText:@"0.45MB, 3:23s"];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
