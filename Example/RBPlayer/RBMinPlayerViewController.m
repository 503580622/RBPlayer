//
//  RBMinPlayerViewController.m
//  RBPlayer
//
//  Created by Ribs on 16/8/23.
//  Copyright © 2016年 Ribs. All rights reserved.
//

#import "RBMinPlayerViewController.h"
#import <RBPlayer/RBVideoPlayer.h>

@interface RBMinPlayerViewController () <RBPlayerViewDelegate>

@property (nonatomic, strong) RBVideoPlayer *player;

@end

@implementation RBMinPlayerViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSString *url = @"http://v.jxvdy.com/sendfile/HbTMxpilOKa7NyPRqdN3FDvIrYgTLhBMB5Hj_-dHcy5IPDOZXFD1HW2WgQUYTpDcBSnUL2xD5rDf2BujUbiMg6_rJl50vg";
    
    self.player = [[RBVideoPlayer alloc] init];
    //self.player.view.ignoreScreenSystemLock = YES;
    [self.contentView addSubview:self.player.view];
    
    self.player.view.delegate = self;
    self.player.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[playerView]-10-|" options:0 metrics:nil views:@{@"playerView":self.player.view}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[playerView(200)]" options:0 metrics:nil views:@{@"playerView":self.player.view}]];
    
    RBPlayerItem *item = [[RBPlayerItem alloc] init];
    item.title = @"这都是什么jb电影";
    item.assetTitle = @"清晰";
    
    RBPlayerItemAsset *itemAsset1 = [[RBPlayerItemAsset alloc] initWithType:@"清晰" URL:[NSURL URLWithString:url]];
    RBPlayerItemAsset *itemAsset2 = [[RBPlayerItemAsset alloc] initWithType: @"高清" URL:[NSURL URLWithString:url]];
    
    item.assets = @[itemAsset1, itemAsset2];
    
    [self.player replaceCurrentItemWithPlayerItem:item];
    [self.player playWithItemAsset:itemAsset1];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - RBPlayerViewDelegate

- (BOOL)playerView:(RBPlayerView *)playerView willOrientationChange:(UIInterfaceOrientation)orientation {
    
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (orientation != UIInterfaceOrientationUnknown) {
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        
        if (UIInterfaceOrientationIsLandscape(statusBarOrientation) && [playerView containsMask:self.player.topMask]) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        } else {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        });
    }
    return YES;
}

- (BOOL)playerView:(RBPlayerView *)playerView willAddMask:(RBPlayerViewMask *)mask animated:(BOOL)animated {
    if ([mask isEqual:self.player.topMask]) {        
        UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(statusBarOrientation)) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
        }
    }
    return YES;
}

- (BOOL)playerView:(RBPlayerView *)playerView willRemoveMask:(RBPlayerViewMask *)mask animated:(BOOL)animated {
    if ([mask isEqual:self.player.topMask] && playerView.isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    }
    return YES;
}

@end
