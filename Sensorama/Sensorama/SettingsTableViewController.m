//
//  SettingsTableViewController.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SRUsageStats.h"
#import "SRUtils.h"
#import "SRDebug.h"


@interface SettingsTableViewController ()
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *settingsState;
@end

@implementation SettingsTableViewController



- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *savedSettings = [NSUserDefaults standardUserDefaults];
    for (UISwitch *sw in self.settingsState) {
        NSString *swName = [sw accessibilityIdentifier];
        NSNumber *yesOrNo = @([sw tag]);

        BOOL shouldBeOn = [yesOrNo boolValue];
        if ([savedSettings objectForKey:swName] != nil) {
            shouldBeOn = [savedSettings boolForKey:swName];
        } else {
            [savedSettings setObject:@(shouldBeOn) forKey:swName];
        }
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
        return ([SRUtils humanSensoramaVersionString]);
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

@end
