//
//  SettingsTableViewController.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SRUsageStats.h"


@interface SettingsTableViewController ()
@property (weak, nonatomic) NSString *versionString;
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *sensorState;
@end

@implementation SettingsTableViewController


- (NSString *)versionString {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"Sensorama %@ (build:%@)",
                    [infoDict objectForKey:@"CFBundleShortVersionString"],
                    [infoDict objectForKey:@"CFBundleVersion"]
            ];
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *savedSettings = [NSUserDefaults standardUserDefaults];
    for (UISwitch *sw in self.sensorState) {
        NSString *swName = [sw accessibilityIdentifier];
        BOOL shouldBeOn = [savedSettings boolForKey:swName];
        [sw setOn:shouldBeOn];
    }
}

- (void) viewDidAppear:(BOOL)animate {
    [super viewDidAppear:animate];
    [self.tabBarController setTitle:@"Settings"];
}

- (void)viewDidLoad {
    NSLog(@"%s", __func__);
    [super viewDidLoad];

    [SRUsageStats eventAppSettings];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == [self.tableView numberOfSections] - 1) {
        return (self.versionString);
    } else {
        return [super tableView:tableView titleForFooterInSection:section];
    }
}


- (IBAction)sensorStateChange:(id)sender forEvent:(UIEvent *)event {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch *sw = (UISwitch *)sender;
        NSString *swName = [sw accessibilityIdentifier];
        [defaults setBool:[sw isOn] forKey:swName];
    }

    NSLog(@"event %@ changed %@", event, sender);
}


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
