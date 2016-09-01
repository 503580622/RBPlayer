//
//  RBPlayerControlPlayOrPauseButton.m
//  Pods
//
//  Created by Ribs on 16/8/25.
//
//

#import "RBPlayerControlPlayOrPauseButton.h"
#import "UIImage+RBPlayer.h"
#import "RBVideoPlayer.h"

@implementation RBPlayerControlPlayOrPauseButton

- (instancetype)initWithMask:(RBPlayerViewMask *)mask {
    self = [super initWithMask:mask];
    if (self) {
        [self.button setImage:[UIImage rbp_imageNamed:@"rb_player_play_btn"] forState:UIControlStateNormal];
        [self.button setImage:[UIImage rbp_imageNamed:@"rb_player_pause_btn"] forState:UIControlStateSelected];
    }
    return self;
}

- (void)reload {
    self.button.selected = self.currentMask.currentPlayerView.currentPlayer.state == RBPlayerStatePlaying;
}

- (void)main {
    [self.currentMask.currentPlayerView.currentPlayer resumeOrPause];
}

- (void)playerDidChangedState {
    [self reload];
}

@end
