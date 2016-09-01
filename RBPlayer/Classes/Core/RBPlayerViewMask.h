//
//  RBPlayerViewMask.h
//  Pods
//
//  Created by Ribs on 16/8/22.
//
//
#import <UIKit/UIKit.h>

@class RBPlayerView;

@protocol RBPlayerViewMaskProtocol <NSObject>

- (void)reload;

@optional

- (NSTimeInterval)autoRemoveSeconds;

- (void)willAddToPlayerView:(RBPlayerView *)playerView animated:(BOOL)animated;
- (void)willRemoveFromPlayerView:(RBPlayerView *)playerView animated:(BOOL)animated;

- (void)addAnimationWithCompletion:(void(^)())completion;
- (void)removeAnimationWithCompletion:(void(^)())completion;

- (void)playerDidChangedState;
- (void)playerViewWillChangeOrientation:(UIInterfaceOrientation)orientation fromOrientation:(UIInterfaceOrientation)fromOrientation;

@end


@interface RBPlayerViewMask : UIView <RBPlayerViewMaskProtocol>


@property (nonatomic, weak, readonly) RBPlayerView *currentPlayerView;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithPlayerView:(RBPlayerView *)playerView;

@end
