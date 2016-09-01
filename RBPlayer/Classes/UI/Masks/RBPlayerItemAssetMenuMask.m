//
//  RBPlayerItemAssetMask.m
//  Pods
//
//  Created by Ribs on 16/8/25.
//
//

#import "RBPlayerItemAssetMenuMask.h"
#import "RBVideoPlayer.h"


@implementation RBPlayerItemAssetMenuMask

- (void)selectedIndexDidChanged {
    if (self.selectedIndex >= 0) {
        NSUInteger currentSeconds = self.currentPlayerView.currentPlayer.currentItem.currentSeconds;
        RBPlayerItemAsset *itemAsset = self.currentPlayerView.currentPlayer.currentItem.assets[self.selectedIndex];
        [self.currentPlayerView.currentPlayer playWithItemAsset:itemAsset];
        [self.currentPlayerView.currentPlayer seekToSeconds:currentSeconds];
    }
    [self.currentPlayerView removeMask:self animated:YES];
}

#pragma mark - mask

- (void)reload {
    [super reload];
    
    NSMutableArray *items = [NSMutableArray array];
    __block NSInteger selectedIndex = -1;
    [self.currentPlayerView.currentPlayer.currentItem.assets enumerateObjectsUsingBlock:^(RBPlayerItemAsset *asset, NSUInteger index, BOOL *stop) {
        if ([asset isEqual:self.currentPlayerView.currentPlayer.currentItem.playingAsset]) {
            selectedIndex = index;
        }
        if ([asset.type length] > 0) {
            [items addObject:asset.type];
        }
    }];
    self.items = items;
    self.selectedIndex = selectedIndex;
}

- (void)willAddToPlayerView:(RBPlayerView *)playerView animated:(BOOL)animated {
    
    RBVideoPlayer *player = (RBVideoPlayer *)playerView.currentPlayer;
    [player.view lockAutoRemove:YES withMask:player.bottomMask];
}

- (void)willRemoveFromPlayerView:(RBPlayerView *)playerView animated:(BOOL)animated {
    RBVideoPlayer *player = (RBVideoPlayer *)playerView.currentPlayer;
    [player.view lockAutoRemove:NO withMask:player.bottomMask];
}

- (void)playerViewWillChangeOrientation:(UIInterfaceOrientation)orientation fromOrientation:(UIInterfaceOrientation)fromOrientation {
    if (orientation != UIInterfaceOrientationUnknown) {
        [self.currentPlayerView removeMask:self animated:NO];
    }
}

@end
