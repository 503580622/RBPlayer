//
//  RBPlayerViewController.m
//  Pods
//
//  Created by Ribs on 16/8/23.
//
//

#import "RBPlayerViewController.h"
#import "RBPlayerOrientationDmonitor.h"

@interface RBPlayerViewController ()

@property (nonatomic, strong) RBVideoPlayer *player;

@end

@implementation RBPlayerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _player = [[RBVideoPlayer alloc] init];
        _player.view.supportedOrientations = UIInterfaceOrientationMaskLandscape;
        _player.view.autoFullScreen = NO;
        _player.view.ignoreScreenSystemLock = YES;
        
        if ([_player.topMask isKindOfClass:[RBPlayerTopMask class]]) {
            RBPlayerTopMask *topMask = (RBPlayerTopMask *)_player.topMask;
            
            __weak typeof(self) weakSelf = self;
            RBPlayerControlBackButton *backButton = [[RBPlayerControlBackButton alloc] initWithMask:topMask mainBlock:^{
                weakSelf.player.view.supportedOrientations = UIInterfaceOrientationMaskAll;
                [weakSelf.player.view performOrientationChange:UIInterfaceOrientationUnknown animated:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                });
            }];
            topMask.leftButtons = @[ backButton ];
        }
        if ([_player.bottomMask isKindOfClass:[RBPlayerBottomMask class]]) {
            RBPlayerBottomMask *bottomMask = (RBPlayerBottomMask *)_player.bottomMask;
            bottomMask.rightButtons = @[
                                        [[RBPlayerControlRateButton alloc] initWithMask:bottomMask],
                                        [[RBPlayerControlItemAssetMenuButton alloc] initWithMask:bottomMask]
                                        ];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.player.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.player.view performOrientationChange:UIInterfaceOrientationLandscapeRight animated:NO];
        self.player.view.containerView.alpha = 0;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.player.view.containerView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
