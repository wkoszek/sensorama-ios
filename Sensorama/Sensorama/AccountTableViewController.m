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
    AccountTableViewController *atvc = (AccountTableViewController *)[stvc.viewControllers objectAtIndex:2];
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

#if 0
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}
#endif
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
