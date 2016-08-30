//
//  RBPlayerControlFullScreenButton.m
//  Pods
//
//  Created by 黄泽新 on 16/8/25.
//
//

#import "RBPlayerControlFullScreenButton.h"
#import "UIImage+RBPlayer.h"
#import "RBVideoPlayer.h"

@implementation RBPlayerControlFullScreenButton

- (instancetype)initWithMask:(RBPlayerViewMask *)mask {
    self = [super initWithMask:mask];
    if (self) {
        [self.button setImage:[UIImage rbp_imageNamed:@"rb_player_fullScreen_btn"] forState:UIControlStateNormal];
        [self.button setImage:[UIImage rbp_imageNamed:@"rb_player_fullScreen_btn"] forState:UIControlStateNormal | UIControlStateHighlighted];
        [self.button setImage:[UIImage rbp_imageNamed:@"rb_player_minScreen_btn"] forState:UIControlStateSelected];
        [self.button setImage:[UIImage rbp_imageNamed:@"rb_player_minScreen_btn"] forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    return self;
}

- (void)reload {
    self.button.selected = self.currentMask.currentPlayerView.isFullScreen;
}

- (void)main {
    if (self.currentMask.currentPlayerView.isFullScreen) {
        [self.currentMask.currentPlayerView performOrientationChange:UIInterfaceOrientationUnknown animated:YES];
    } else {
        [self.currentMask.currentPlayerView performOrientationChange:UIInterfaceOrientationLandscapeRight animated:YES];
    }
}

- (void)playerViewWillChangeOrientation:(UIInterfaceOrientation)orientation fromOrientation:(UIInterfaceOrientation)fromOrientation  {
    self.button.selected = orientation != UIInterfaceOrientationUnknown;
}

@end
