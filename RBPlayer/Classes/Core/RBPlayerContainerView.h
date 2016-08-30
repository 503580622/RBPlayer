//
//  RBPlayerContainerView.h
//  Pods
//
//  Created by 黄泽新 on 16/8/23.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RBPlayerContainerView : UIView

@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, strong, readonly) UIView *maskContainerView;

@end
