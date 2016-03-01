//
//  RecordViewController.m
//  
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//
//

#import "RecordViewController.h"
#import "SRUtils.h"

@interface RecordViewController ()
@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureStartStop;

@end

@implementation RecordViewController

- (void)makeRecordCircle {
    CGFloat w = self.recordView.frame.size.width;
    CGFloat h = self.recordView.frame.size.height;
    NSAssert(w == h, @"recordView must be rectangle");
    self.recordView.alpha = 1;
    self.recordView.layer.cornerRadius = h / 2;
    self.recordView.backgroundColor = [SRUtils mainColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self makeRecordCircle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doStartStop:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:10.0
                          delay:0
                        options: UIViewAnimationOptionCurveLinear
                 animations:^{
                     self.recordView.layer.cornerRadius = 0;
                     //NSLog(@"animate");
                 }
                 completion:^(BOOL finished){
                     NSLog(@"Done!");
                 }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
