//
//  RBPlayerControlBackButton.m
//  Pods
//
//  Created by 黄泽新 on 16/8/27.
//
//

#import "RBPlayerControlBackButton.h"
#import "UIImage+RBPlayer.h"
#import "RBVideoPlayer.h"

@implementation RBPlayerControlBackButton

- (instancetype)initWithMask:(RBPlayerViewMask *)mask {
    self = [super initWithMask:mask];
    if (self) {
        [self.button setImage:[UIImage rbp_imageNamed:@"rb_player_back_btn"] forState:UIControlStateNormal];
    }
    return self;
}

- (void)reload {
    self.button.hidden = !self.currentMask.currentPlayerView.isFullScreen;
}

- (void)main {
    if (self.currentMask.currentPlayerView.isFullScreen) {
        [self.currentMask.currentPlayerView performOrientationChange:UIInterfaceOrientationUnknown animated:YES];
    } else {
        [self.currentMask.currentPlayerView performOrientationChange:UIInterfaceOrientationLandscapeRight animated:YES];
    }
}

- (void)playerViewWillChangeOrientation:(UIInterfaceOrientation)orientation fromOrientation:(UIInterfaceOrientation)fromOrientation {
    self.button.hidden = orientation == UIInterfaceOrientationUnknown;
}

@end
