//
//  RBVideoPlayer.m
//  Pods
//
//  Created by 黄泽新 on 16/8/24.
//
//

#import "RBVideoPlayer.h"

@implementation RBVideoPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.controlMask = [[RBPlayerControlMask alloc] initWithPlayerView:self.view];
        self.topMask = [[RBPlayerTopMask alloc] initWithPlayerView:self.view];
        self.bottomMask = [[RBPlayerBottomMask alloc] initWithPlayerView:self.view];
        self.loadingMask = [[RBPlayerLoadingMask alloc] initWithPlayerView:self.view];
    }
    return self;
}

#pragma mark - getters setters

- (void)setControlMask:(RBPlayerViewMask *)controlMask {
    if (_controlMask != nil) {
        [self.view removeMask:_controlMask animated:NO];
    }
    _controlMask = controlMask;
    [self.view addMask:_controlMask animated:NO];
    [self.view.containerView.maskContainerView sendSubviewToBack:_controlMask];
}

- (void)setBottomMask:(RBPlayerViewMask *)bottomMask {
    if (_bottomMask != nil) {
        [self.view removeMask:_bottomMask animated:NO];
    }
    _bottomMask = bottomMask;
    [self.view addMask:_bottomMask animated:NO];
}

- (void)setLoadingMask:(RBPlayerViewMask *)loadingMask {
    if (_loadingMask != nil) {
        [self.view removeMask:_loadingMask animated:NO];
    }
    _loadingMask = loadingMask;
    [self.view addMask:_loadingMask animated:NO];
}

@end