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
#import "SRAuth.h"
#import "SensoramaTabBarController.h"
#import "RecordViewController.h"
#import "FrequencyViewController.h"
#import "SRCfg.h"


@interface SettingsTableViewController ()
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *settingsState;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UILabel *frequencySamplingLabel;

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

    A0UserProfile *profile = [SRAuth currentProfile];


    NSLog(@"email=%@", profile.email);

    [self.logoutCell.detailTextLabel setText:profile.email];
}

- (void)viewDidLoad {
    NSLog(@"%s", __func__);
    [super viewDidLoad];

    [SRUsageStats eventAppSettings];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == [self.tableView numberOfSections] - 1) {
        return ([SRUtils humanSensoramaVersionString]);
    } else {
        return [super tableView:tableView titleForFooterInSection:section];
    }
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


- (IBAction)sensorStateChange:(id)sender forEvent:(UIEvent *)event {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch *sw = (UISwitch *)sender;
        NSString *swName = [sw accessibilityIdentifier];
        [defaults setBool:[sw isOn] forKey:swName];
    }

    NSLog(@"event %@ changed %@", event, sender);
}

- (void) logout {
    NSLog(@"logout triggered");
    SensoramaTabBarController *stvc = (SensoramaTabBarController *)self.parentViewController;
    RecordViewController *rvc = [stvc viewControllerByClass:[RecordViewController class]];
    [rvc logoutAuth0];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SRPROBE0();
    if ([segue.destinationViewController isKindOfClass:[FrequencyViewController class]]) {
        FrequencyViewController *freqVC = (FrequencyViewController *)segue.destinationViewController;
        NSString *stringWithoutMs = [self.frequencySamplingLabel.text
                                        stringByReplacingOccurrencesOfString:@"ms" withString:@""];
        freqVC.frequencyValue = @([stringWithoutMs integerValue]);
    }
}

- (IBAction)unwindToSettings:(UIStoryboardSegue *)unwindSegue {
    SRPROBE0();
    if ([unwindSegue.sourceViewController isKindOfClass:[FrequencyViewController class]]) {
        FrequencyViewController *freqVC = (FrequencyViewController *)unwindSegue.sourceViewController;
        NSLog(@"GOT HERE %@", freqVC.frequencyValue);

        NSString *stringWithMs = [NSString stringWithFormat:@"%@ms", freqVC.frequencyValue];
        [self.frequencySamplingLabel setText:stringWithMs];

        SRCfg *cfg = [SRCfg defaultConfiguration];
        cfg.sampleInterval = [freqVC.frequencyValue integerValue];
    }
}

@end
