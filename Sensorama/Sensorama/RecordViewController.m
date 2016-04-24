//
//  RecordViewController.m
//  
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//
// Corner radius animation:
// http://stackoverflow.com/questions/5948167/uiview-animatewithduration-doesnt-animate-cornerradius-variation
// Re-login implementation stolen from:
// https://github.com/maju6406/Layer-Auth0-iOS-Example/blob/master/Code/Controllers/ViewController.m#L97
// JWTDecode written in Swift doesn't export "isExpired" method, so I had to make it myself.
//
#import <Lock/Lock.h>

@import JWTDecode;

#import "RecordViewController.h"
#import "SensoramaTabBarController.h"
#import "FilesTableViewController.h"
#import "SRUtils.h"
#import "SRUsageStats.h"
#import "SREngine.h"
#import "SRAuth.h"
#import "SRSync.h"
#import "SRDebug.h"
#import "SimpleKeychain/A0SimpleKeychain.h"
#import "../contrib/libextobjc/extobjc/EXTScope.h"

@interface RecordViewController ()
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureStartStop;

@property (weak,   nonatomic) IBOutlet UIView *recordView;

@property (nonatomic) BOOL isRecording;
@property (nonatomic) CGFloat savedCornerRadius;
@property (nonatomic) NSString *idToken;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%s", __func__);
    [self setIsRecording:false];
}

- (void)customizeLoginLook {
    A0Theme *sensoramaTheme = [[A0Theme alloc] init];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemePrimaryButtonNormalColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeSecondaryButtonBackgroundColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeSecondaryButtonTextColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeTextFieldTextColor];
    [sensoramaTheme registerColor:[UIColor lightGrayColor] forKey:A0ThemeTextFieldPlaceholderTextColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeTextFieldIconColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeTitleTextColor];
    [sensoramaTheme registerImageWithName:@"appLaunch" bundle:[NSBundle mainBundle] forKey:A0ThemeIconImageName];
    [[A0Theme sharedInstance] registerTheme:sensoramaTheme];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tabBarController setTitle:@"Record"];
    NSLog(@"%s", __func__);

    [self customizeLoginLook];
    [self doLogin];
    [SRUsageStats eventAppRecord];
}

- (void)doLogin
{
    A0SimpleKeychain *keychain = [SRAuth sharedInstance].keychain;
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:[keychain dataForKey:@"profile"]];
    NSString *idToken = [keychain stringForKey:@"id_token"];
    
    NSLog(@"keychain=%@", keychain);
    NSLog(@"profile=%@", profile);
    NSLog(@"idToken=%@", idToken);
    
    if (idToken) {
        NSError *error = nil;
        A0JWT *jwt = [A0JWT decode:idToken error:&error];
        
        if ([self isJWTTokenExpired:jwt]) {
            NSLog(@"Auth0 token has expired, refreshing.");
            NSString *refreshToken = [keychain stringForKey:@"refresh_token"];
            
            @weakify(self);
            A0APIClient *client = [[[SRAuth sharedInstance] lock] apiClient];
            [client fetchNewIdTokenWithRefreshToken:refreshToken parameters:nil success:^(A0Token *token) {
                @strongify(self);
                [keychain setString:token.idToken forKey:@"id_token"];
                [SRSync doAmazonLogin:token.idToken];
                (void)self;
            } failure:^(NSError *error) {
                [keychain clearAll];
            }];
        } else {
            self.idToken = idToken;
            [SRSync doAmazonLogin:idToken];
        }
    } else {
        [self signInToAuth0];
    }
}

- (void)signInToAuth0
{
    A0Lock *lock = [[SRAuth sharedInstance] lock];
    A0LockViewController *controller = [lock newLockViewController];

    controller.closable = false;
    @weakify(self);
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        @strongify(self);
        self.idToken = token.idToken;

        A0SimpleKeychain *keychain = [SRAuth sharedInstance].keychain;
        [keychain setString:token.idToken forKey:@"id_token"];
        [keychain setString:token.refreshToken forKey:@"refresh_token"];
        [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:@"profile"];
        [SRSync doAmazonLogin:token.idToken];

        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)logoutAuth0
{
    A0APIClient *client = [[[SRAuth sharedInstance] lock] apiClient];
    A0SimpleKeychain *store = [SRAuth sharedInstance].keychain;

    [client logout];
    [store clearAll];
}

- (BOOL)isJWTTokenExpired:(A0JWT *)jwt
{
    NSDate *date = [jwt expiresAt];
    if (date == nil) {
        return false;
    }
    return ([date compare:[NSDate new]] != NSOrderedDescending);
}

- (void)setIsRecording:(BOOL)isRecording
{
    SensoramaTabBarController *tabController = (SensoramaTabBarController *)self.parentViewController;
    FilesTableViewController *filesTVC = [tabController.viewControllers objectAtIndex:1];

    SRPROBE1(filesTVC);

    [self makeStartStopTransition:isRecording];
    if (isRecording) {
        [tabController.engine recordingStart];
        [self activateOtherTabs:NO];
    } else {
        [tabController.engine recordingStop];
        [self activateOtherTabs:YES];
        // XXXTODO
        //filesTVC.filesList = [tabController.srEngine filesRecorded];
    }
    _isRecording = isRecording;
}

- (void)activateOtherTabs:(BOOL)activateFlag {
    SensoramaTabBarController *tabController = (SensoramaTabBarController *)self.parentViewController;

    [[[[tabController tabBar] items] objectAtIndex:1] setEnabled:activateFlag];
    [[[[tabController tabBar] items] objectAtIndex:2] setEnabled:activateFlag];
    [[[[tabController tabBar] items] objectAtIndex:3] setEnabled:activateFlag];
}

- (void)makeStartStopTransition:(BOOL)needSquare {
    SRPROBE0();

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
    SRPROBE0();

    NSAssert(self.recordView.frame.size.width == self.recordView.frame.size.height,
             @"recordView must be rectangle");
    self.recordView.alpha = 1;
    self.recordView.layer.cornerRadius = self.recordView.frame.size.height / 2;
    self.recordView.backgroundColor = [SRUtils mainColor];

    self.savedCornerRadius = self.recordView.layer.cornerRadius;
}

- (IBAction)doStartStop:(UITapGestureRecognizer *)sender {
    SRPROBE0();

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
