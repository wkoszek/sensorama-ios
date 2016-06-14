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
//

#import <Lock/Lock.h>
#import "FontAwesome_iOS/UIImage+FontAwesome.h"
#import "Sensorama-Swift.h"

@import JWTDecode;

#import "RecordViewController.h"
#import "SensoramaTabBarController.h"
#import "FilesTableViewController.h"
#import "SRUtils.h"
#import "SRUsageStats.h"
#import "SREngine.h"
#import "SRAuth.h"
#import "SRDebug.h"
#import "SimpleKeychain/A0SimpleKeychain.h"
#import "../contrib/libextobjc/extobjc/EXTScope.h"

@interface RecordViewController ()
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureStartStop;

@property (weak,   nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UILabel *debugMessagesLabel;

@property (nonatomic) BOOL isRecording;
@property (nonatomic) CGFloat savedCornerRadius;
@property (nonatomic) NSString *idToken;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.debugMessagesLabel setHidden:YES];
    NSLog(@"%s", __func__);
    [self setIsRecording:false initial:YES];
    [self hideViewsIfNecessary];
    [self startDebugging];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self hideViewsIfNecessary];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tabBarController setTitle:@"Record"];
    NSLog(@"%s, hasWifi:%d", __func__, [SRUtils hasWifi]);

    [self customizeLoginLook];
    [self doLogin];
    [SRUsageStats eventAppRecord];
}

- (void) hideViewsIfNecessary {
    if (![SRUtils isDeveloperMode]) {
        [self.debugMessagesLabel setHidden:YES];
    }
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
                [SRAuth doAmazonLogin:token.idToken];
                (void)self;
            } failure:^(NSError *error) {
                [keychain clearAll];
            }];
        } else {
            self.idToken = idToken;
            [SRAuth doAmazonLogin:idToken];
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
        [SRAuth doAmazonLogin:token.idToken];

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

// Get rid of this once https://github.com/auth0/JWTDecode.swift/pull/25
// hits the production
- (BOOL)isJWTTokenExpired:(A0JWT *)jwt
{
    NSDate *date = [jwt expiresAt];
    if (date == nil) {
        return false;
    }
    return ([date compare:[NSDate new]] != NSOrderedDescending);
}

- (void)setIsRecording:(BOOL)isRecording initial:(BOOL)isInitial
{
    SensoramaTabBarController *tabBarController = (SensoramaTabBarController *)self.parentViewController;
    FilesTableViewController *filesTVC = [tabBarController viewControllerByClass:[FilesTableViewController class]];

    SRPROBE1(filesTVC);

    [self makeStartStopTransition:isRecording];
    _isRecording = isRecording;
    if (isInitial) {
        return;
    }

    if (isRecording) {
        [tabBarController.engine recordingStart];
        [self activateOtherTabs:NO];
    } else {
        [tabBarController.engine recordingStopWithExport:YES];
        [self activateOtherTabs:YES];
        filesTVC.filesList = [tabBarController.engine allRecordedFiles];
    }
}

- (void)activateOtherTabs:(BOOL)activateFlag {
    SensoramaTabBarController *tabBarController = (SensoramaTabBarController *)self.parentViewController;
    NSInteger viewIndexToKeep = [tabBarController viewControllerIndexByClass:[RecordViewController class]];

    NSInteger curTabItem = 0;
    for (UITabBarItem *tbi in [tabBarController viewControllers]) {
        if (viewIndexToKeep == curTabItem) {
            continue;
        }
        [tbi setEnabled:activateFlag];
    }
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

    [self setIsRecording:!self.isRecording initial:NO];
}


#pragma mark - Debugging

- (void)startDebugging {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensoramaNotificationHandler:)
                                                 name:@"SensoramaDebug"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensoramaNotificationHandler:)
                                                 name:@"Sensorama"
                                               object:nil];

}

- (void)setNotifyString:(NSString *)debugString fgColor:(UIColor *)fgColor image:(UIImage *)image {
    [WhisperBridge whisper:debugString textColor:fgColor backgroundColor:[SRUtils mainColor] toNavigationController:self.navigationController silenceAfter:3 images:@[image]];
}

- (UIImage *) faImageWithName:(NSString *)name {
    return [UIImage imageWithIcon:name backgroundColor:[SRUtils mainColor] iconColor:[UIColor whiteColor] iconScale:1.0f andSize:CGSizeMake(20, 20)];
}

- (void)sensoramaNotificationHandler:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *notificationString = [userInfo objectForKey:@"text"];

    SRPROBE1([notification name]);

    if ([[notification name] isEqualToString:@"SensoramaDebug"]) {
        [self.debugMessagesLabel setHidden:NO];
        [self.debugMessagesLabel setText:notificationString];
    }
    if ([[notification name] isEqualToString:@"Sensorama"]) {
        UIColor *fgColor = [UIColor whiteColor];
        UIImage *image = nil;
        if ([[userInfo objectForKey:@"type"] isEqualToString:@"notify"]) {
            image = [self faImageWithName:@"icon-ok"];
        }
        if ([[userInfo objectForKey:@"type"] isEqualToString:@"warn"]) {
            image = [self faImageWithName:@"icon-warning-sign"];
        }
        if ([[userInfo objectForKey:@"type"] isEqualToString:@"error"]) {
            image = [self faImageWithName:@"icon-thumbs-down"];
        }
        SRPROBE2(fgColor, notificationString);
        [self setNotifyString:notificationString fgColor:fgColor image:image];
    }
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
