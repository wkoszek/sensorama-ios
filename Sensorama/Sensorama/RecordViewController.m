//
//  RecordViewController.m
//  
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//
// Corner radius animation:
// http://stackoverflow.com/questions/5948167/uiview-animatewithduration-doesnt-animate-cornerradius-variation

#import <Lock/Lock.h>

#import "RecordViewController.h"
#import "SensoramaTabBarController.h"
#import "FilesTableViewController.h"
#import "SRUtils.h"
#import "SRUsageStats.h"
#import "SREngine.h"
#import "SRAuth.h"


@interface RecordViewController ()
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureStartStop;

@property (weak,   nonatomic) IBOutlet UIView *recordView;

@property (nonatomic) BOOL isRecording;
@property (nonatomic) CGFloat savedCornerRadius;

@end

@implementation RecordViewController

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%s", __func__);
    [super viewDidAppear:animated];
    [self.tabBarController setTitle:@"Record"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Custom login screen for Sensorama.
    A0Theme *sensoramaTheme = [[A0Theme alloc] init];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemePrimaryButtonNormalColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeSecondaryButtonBackgroundColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeSecondaryButtonTextColor];
    [[A0Theme sharedInstance] registerTheme:sensoramaTheme];

    A0Lock *lock = [[SRAuth sharedInstance] lock];
    A0LockViewController *controller = [lock newLockViewController];
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        // Do something with token & profile. e.g.: save them.
        // And dismiss the ViewController
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:controller animated:YES completion:nil];


    [self setIsRecording:false];
    [SRUsageStats eventAppRecord];
}

- (void)setIsRecording:(BOOL)isRecording
{
    SensoramaTabBarController *tabController = (SensoramaTabBarController *)self.parentViewController;
    FilesTableViewController *filesTVC = [tabController.viewControllers objectAtIndex:1];

    NSLog(@"fund: %s", __func__);
    NSLog(@"files: %@", filesTVC);


    [self makeStartStopTransition:isRecording];
    if (isRecording) {
        [tabController.srEngine recordingStart];
    } else {
        [tabController.srEngine recordingStop];
        filesTVC.filesList = [tabController.srEngine filesRecorded];
    }
    _isRecording = isRecording;
}

- (void)makeStartStopTransition:(BOOL)needSquare {
    NSLog(@"%s", __func__);
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [self makeInitialCircle];
    });

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:needSquare ? self.savedCornerRadius : 0];
    animation.toValue = [NSNumber numberWithFloat:needSquare ? 0.0f : self.savedCornerRadius];
    animation.duration = 0.1;
    [self.recordView.layer addAnimation:animation forKey:@"cornerRadius"];
    [self.recordView.layer setCornerRadius:needSquare ? 0 : self.savedCornerRadius];
}

- (void)makeInitialCircle {
    NSLog(@"%s", __func__);
    NSAssert(self.recordView.frame.size.width == self.recordView.frame.size.height,
             @"recordView must be rectangle");
    self.recordView.alpha = 1;
    self.recordView.layer.cornerRadius = self.recordView.frame.size.height / 2;
    self.recordView.backgroundColor = [SRUtils mainColor];

    self.savedCornerRadius = self.recordView.layer.cornerRadius;
}

- (IBAction)doStartStop:(UITapGestureRecognizer *)sender {
    NSLog(@"%s", __func__);

    [self setIsRecording:!self.isRecording];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
