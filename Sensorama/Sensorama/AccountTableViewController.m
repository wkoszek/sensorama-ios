//
//  AccountTableViewController.m
//  
//
//  Created by Wojciech Adam Koszek (h) on 30/03/2016.
//
//

#import <Lock/Lock.h>
#import <UIKit/UIKit.h>

#import "AccountTableViewController.h"
#import "SensoramaTabBarController.h"
#import "RecordViewController.h"
#import "SimpleKeychain/A0SimpleKeychain.h"
#import "SRAuth.h"

@interface AccountTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;

@end

@implementation AccountTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%s", __func__);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear:(BOOL)animate {
    [super viewDidAppear:animate];

    NSLog(@"%s", __func__);

    [self.tabBarController setTitle:@"Account"];

    A0UserProfile *profile = [SRAuth currentProfile];

    SensoramaTabBarController *stvc = (SensoramaTabBarController *)self.parentViewController;
    AccountTableViewController *atvc = [stvc viewControllerByClass:[AccountTableViewController class]];
    NSLog(@"email=%@", profile.email);

    atvc.emailAddress = profile.email;
    [self.emailCell.detailTextLabel setText:profile.email];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.logoutCell) {
        NSLog(@"logoutButton");
        [self.logoutCell setSelected:NO];
        [self logout];
        SensoramaTabBarController *stvc = (SensoramaTabBarController *)self.parentViewController;
        [stvc setSelectedIndex:0];
    }
}


- (void) logout {
    NSLog(@"logout triggered");
    SensoramaTabBarController *stvc = (SensoramaTabBarController *)self.parentViewController;
    RecordViewController *rvc = [stvc.viewControllers objectAtIndex:0];
    [rvc logoutAuth0];
}

@end
