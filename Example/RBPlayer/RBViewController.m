//
//  RBViewController.m
//  RBPlayer
//
//  Created by 黄泽新 on 08/22/2016.
//  Copyright (c) 2016 黄泽新. All rights reserved.
//

#import "RBViewController.h"
#import "RBMinPlayerViewController.h"
#import <RBPlayer/RBPlayerViewController.h>

@interface RBViewController () <RBPlayerViewDelegate>
@end

@implementation RBViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
}

- (IBAction)showMinPlayer:(id)sender {
    [self presentViewController:[[RBMinPlayerViewController alloc] init] animated:YES completion:nil];
}

- (IBAction)showFullScreenPlayer:(id)sender {
 
    RBPlayerViewController *vc = [[RBPlayerViewController alloc] init];
    
    NSString *url = @"http://v.jxvdy.com/sendfile/HbTMxpilOKa7NyPRqdN3FDvIrYgTLhBMB5Hj_-dHcy5IPDOZXFD1HW2WgQUYTpDcBSnUL2xD5rDf2BujUbiMg6_rJl50vg";
    
    RBPlayerItem *item = [[RBPlayerItem alloc] init];
    item.title = @"这都是什么jb电影";
    item.assetTitle = @"清晰";
    
    RBPlayerItemAsset *itemAsset1 = [[RBPlayerItemAsset alloc] initWithType:@"清晰" URL:[NSURL URLWithString:url]];
    RBPlayerItemAsset *itemAsset2 = [[RBPlayerItemAsset alloc] initWithType: @"高清" URL:[NSURL URLWithString:url]];
    
    item.assets = @[itemAsset1, itemAsset2];
    
    [vc.player replaceCurrentItemWithPlayerItem:item];
    [vc.player playWithItemAsset:itemAsset1];
    vc.player.view.delegate = self;

    [self presentViewController:vc animated:YES completion:nil];
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

#pragma mark - RBPlayerViewDelegate

- (BOOL)playerView:(RBPlayerView *)playerView willOrientationChange:(UIInterfaceOrientation)orientation {
    if (orientation != UIInterfaceOrientationUnknown) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    return YES;
}

@end
