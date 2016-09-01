//
//  RBVideoPlayer.h
//  Pods
//
//  Created by Ribs on 16/8/24.
//
//

#import <Foundation/Foundation.h>
#import "RBCorePlayer.h"
#import "RBPlayerSlider.h"
#import "RBPlayerTopMask.h"
#import "RBPlayerBottomMask.h"
#import "RBPlayerControlMask.h"
#import "RBPlayerLoadingMask.h"
#import "RBPlayerItemAssetMenuMask.h"
#import "RBPlayerControlPlayOrPauseButton.h"
#import "RBPlayerControlRateButton.h"
#import "RBPlayerControlItemAssetMenuButton.h"
#import "RBPlayerControlFullScreenButton.h"
#import "RBPlayerControlBackButton.h"

@interface RBVideoPlayer : RBCorePlayer

@property (nonatomic, strong) RBPlayerViewMask *topMask;
@property (nonatomic, strong) RBPlayerViewMask *bottomMask;
@property (nonatomic, strong) RBPlayerViewMask *controlMask;
@property (nonatomic, strong) RBPlayerViewMask *loadingMask;

@end