//
//  FilesTableViewController.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "DZNEmptyDataSet/UIScrollView+EmptyDataSet.h"

#import "FilesTableViewController.h"
#import "FilesDetailTableViewController.h"
#import "SensoramaTabBarController.h"
#import "SRUsageStats.h"
#import "SRUtils.h"
#import "SRDataStore.h"
#import "SRCfg.h"
#import "SRDebug.h"


@interface FilesTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation FilesTableViewController

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%s", __func__);

    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];  // Trick to remove line separators

    SensoramaTabBarController *tabController = (SensoramaTabBarController *)self.navigationController.parentViewController;
    self.filesList = [tabController.engine allRecordedFiles];
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

    SRDataFile *dataFile = [self.filesList objectAtIndex:whichItem];
    [cell.textLabel setText:[dataFile printableLabel]];
    [cell.detailTextLabel setText:[dataFile printableLabelDetails]];

    return cell;
}

#pragma mark - DZNEmptyDataSetSource Methods (empty Files tab handling)

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No files yet. You didn't record anything?";

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:170/255.0 green:171/255.0 blue:179/255.0 alpha:1.0],
                                 NSParagraphStyleAttributeName: paragraphStyle};

    return [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"To see some files go to 'Record' tab and start recording";

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:170/255.0 green:171/255.0 blue:179/255.0 alpha:1.0],
                                 NSParagraphStyleAttributeName: paragraphStyle};

    return [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"empty_placeholder"];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    return nil;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0;
}


#pragma mark - DZNEmptyDataSetSource Methods

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return NO;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{

    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Segue handling

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        FilesDetailTableViewController *fdvc = (FilesDetailTableViewController *)segue.destinationViewController;

        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *whichItemIndex = [self.tableView indexPathForCell:cell];
        NSInteger whichItem = [whichItemIndex row];
        SRDataFile *dataFile = [self.filesList objectAtIndex:whichItem];
        fdvc.dataFile = dataFile;
        NSLog(@"segue=%@, sender=%@ index=%@", segue, sender, dataFile);
    }
}

@end
