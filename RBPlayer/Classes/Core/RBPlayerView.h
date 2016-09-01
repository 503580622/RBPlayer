//
//  RBPlayerView.h
//  Pods
//
//  Created by Ribs on 16/8/22.
//
//

#import <UIKit/UIKit.h>
#import "RBPlayerViewMask.h"
#import "RBPlayerContainerView.h"
#import "RBPlayerControlButton.h"

extern NSString *const RBPlayerViewWillOrientationChangeNotificationName;
extern NSString *const RBPlayerViewDidChangedOrientationNotificationName;
extern NSString *const RBPlayerViewTapControlButtoneNotificationName;

extern NSString *const RBPlayerViewWillChangeOrientationKey;
extern NSString *const RBPlayerViewWillChangeFromOrientationKey;


@class RBCorePlayer;
@class RBPlayerView;

@protocol RBPlayerViewDelegate <NSObject>

@optional

- (BOOL)playerView:(RBPlayerView *)playerView willOrientationChange:(UIInterfaceOrientation)orientation;
- (void)playerView:(RBPlayerView *)playerView didChangedOrientation:(UIInterfaceOrientation)orientation fromOrientation:(UIInterfaceOrientation)fromOrientation;
- (BOOL)playerView:(RBPlayerView *)playerView willAddMask:(RBPlayerViewMask *)mask animated:(BOOL)animated;
- (BOOL)playerView:(RBPlayerView *)playerView willRemoveMask:(RBPlayerViewMask *)mask animated:(BOOL)animated;
- (BOOL)playerView:(RBPlayerView *)playerView willTapControlButton:(RBPlayerControlButton *)controlButton;

@end

@interface RBPlayerView : UIView

@property (nonatomic, weak) id<RBPlayerViewDelegate> delegate;
@property (nonatomic, weak, readonly) RBCorePlayer *currentPlayer;

@property (nonatomic) BOOL autoChangedOrientation;
@property (nonatomic) BOOL autoFullScreen;
@property (nonatomic) BOOL ignoreScreenSystemLock;
@property (nonatomic) UIInterfaceOrientationMask supportedOrientations;
@property (nonatomic, readonly) UIInterfaceOrientation visibleInterfaceOrientation;
@property (nonatomic, readonly) BOOL isFullScreen;

@property (nonatomic, strong, readonly) RBPlayerContainerView *containerView;
@property (nonatomic, strong, readonly) NSArray<RBPlayerViewMask *> *masks;

- (instancetype)initWithPlayer:(RBCorePlayer *)player;

- (void)addMask:(RBPlayerViewMask *)mask animated:(BOOL)animated;
- (void)removeMask:(RBPlayerViewMask *)mask animated:(BOOL)animated;

- (BOOL)containsMask:(RBPlayerViewMask *)mask;
- (NSArray<RBPlayerViewMask *> *)findMaskWithClass:(Class)maskClass;

- (void)lockAutoRemove:(BOOL)lock withMask:(RBPlayerViewMask *)mask;

- (void)performOrientationChange:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

@end
