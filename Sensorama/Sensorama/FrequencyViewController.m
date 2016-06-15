//
//  FrequencyViewController.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 05/06/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "FrequencyViewController.h"
#import "SRDebug.h"

@interface FrequencyViewController ()
@property (weak, nonatomic) IBOutlet UITextField *frequencyTextField;
@end

@implementation FrequencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.frequencyTextField action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];

    self.frequencyTextField.inputAccessoryView = toolbar;

    [self.frequencyTextField addTarget:self
                  action:@selector(frequencyUpdated)
        forControlEvents:UIControlEventEditingDidEnd];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return [[self.frequencyTextField text] integerValue] > 0;
}

- (void) frequencyUpdated {
    self.frequencyValue = @([[self.frequencyTextField text] integerValue]);
    NSLog(@"%s: %@", __func__, self.frequencyValue);

    if ([self shouldPerformSegueWithIdentifier:@"unwindToSettings" sender:self]) {
        [self performSegueWithIdentifier:@"unwindToSettings" sender:self];
    }
}

@end
