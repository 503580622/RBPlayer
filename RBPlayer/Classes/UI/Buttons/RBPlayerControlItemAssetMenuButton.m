//
//  RBPlayerControlItemAssetMenuButton.m
//  Pods
//
//  Created by 黄泽新 on 16/8/25.
//
//

#import "RBPlayerControlItemAssetMenuButton.h"
#import "RBVideoPlayer.h"

@interface RBPlayerControlItemAssetMenuButton ()

@property (nonatomic, strong) RBPlayerItemAssetMenuMask *itemAssetMenuMask;

@end

@implementation RBPlayerControlItemAssetMenuButton

- (instancetype)initWithMask:(RBPlayerViewMask *)mask {
    self = [super initWithMask:mask];
    if (self) {
        self.changeButtonTitleWhenSelected = YES;
        self.button.hidden = YES;
    }
    return self;
}

- (void)reload {
    
    self.button.hidden = !self.currentMask.currentPlayerView.isFullScreen || [self.currentMask.currentPlayerView.currentPlayer.currentItem.assets count] <= 1;
    
    if (self.changeButtonTitleWhenSelected) {
        [self.button setTitle:self.currentMask.currentPlayerView.currentPlayer.currentItem.playingAsset.type forState:UIControlStateNormal];
    } else {
        [self.button setTitle:self.currentMask.currentPlayerView.currentPlayer.currentItem.assetTitle forState:UIControlStateNormal];
    }
}

- (void)main {
    if ([self.currentMask.currentPlayerView containsMask:self.itemAssetMenuMask]) {
        [self.currentMask.currentPlayerView removeMask:self.itemAssetMenuMask animated:YES];
    } else {
        CGPoint point = CGPointMake(self.button.frame.origin.x + self.button.frame.size.width/2,
                                    self.button.frame.origin.y + 5);
        self.itemAssetMenuMask.menuPosition = [self.currentMask.currentPlayerView.containerView.maskContainerView convertPoint:point fromView:self.button.superview];
        [self.currentMask.currentPlayerView addMask:self.itemAssetMenuMask animated:YES];
    }
}

- (void)playerViewWillChangeOrientation:(UIInterfaceOrientation)orientation fromOrientation:(UIInterfaceOrientation)fromOrientation {
    self.button.hidden = orientation == UIInterfaceOrientationUnknown || [self.currentMask.currentPlayerView.currentPlayer.currentItem.assets count] <= 1;
}

#pragma mark - getters setters

- (RBPlayerItemAssetMenuMask *)itemAssetMenuMask {
    if (_itemAssetMenuMask == nil) {
        _itemAssetMenuMask = [[RBPlayerItemAssetMenuMask alloc] initWithPlayerView:self.currentMask.currentPlayerView];
    }
    return _itemAssetMenuMask;
}

@end
