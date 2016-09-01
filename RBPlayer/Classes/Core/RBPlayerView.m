//
//  RBPlayerView.m
//  Pods
//
//  Created by Ribs on 16/8/22.
//
//
#import "RBPlayerView.h"
#import "RBCorePlayer.h"
#import "RBPlayerOrientationDmonitor.h"
#import "RBPlayerChangeOrientationOperation.h"

NSString *const RBPlayerViewWillOrientationChangeNotificationName = @"RBPlayerViewWillOrientationChangeNotificationName";
NSString *const RBPlayerViewDidChangedOrientationNotificationName = @"RBPlayerViewDidChangedOrientationNotificationName";
NSString *const RBPlayerViewTapControlButtoneNotificationName = @"RBPlayerViewTapControlButtoneNotificationName";

NSString *const RBPlayerViewWillChangeOrientationKey = @"RBPlayerViewWillChangeOrientationKey";
NSString *const RBPlayerViewWillChangeFromOrientationKey = @"RBPlayerViewWillChangeFromOrientationKey";

@interface RBPlayerView ()

@property (nonatomic, strong) RBPlayerContainerView *containerView;

@property (nonatomic, weak) RBCorePlayer *currentPlayer;

@property (nonatomic, strong) NSOperationQueue *changeOrientationQueue;
@property (nonatomic, strong) RBPlayerOrientationDmonitor *orientationDmonitor;
@property (nonatomic) UIInterfaceOrientation visibleInterfaceOrientation;

@property (nonatomic, strong) NSMutableArray *lockMasks;

@end

@implementation RBPlayerView

- (instancetype)initWithPlayer:(RBCorePlayer *)player {
    self = [super init];
    if (self) {
        self.currentPlayer = player;
        self.lockMasks = [NSMutableArray array];
        
        self.supportedOrientations = UIInterfaceOrientationMaskLandscape;
        self.visibleInterfaceOrientation = UIInterfaceOrientationUnknown;
        self.autoChangedOrientation = YES;
        self.autoFullScreen = YES;
        
        [self addSubview:self.containerView];
        
        __weak typeof(self) weakSelf = self;
        self.orientationDmonitor = [[RBPlayerOrientationDmonitor alloc] initWidthUpdateHandler:^(UIDeviceOrientation deviceOrientation) {
            [weakSelf orientationChanged:deviceOrientation];
        }];
        [self.orientationDmonitor startDmonitor];
        
        self.changeOrientationQueue = [[NSOperationQueue alloc] init];
        self.changeOrientationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)dealloc {
    [self.changeOrientationQueue cancelAllOperations];
    [self.orientationDmonitor stopDmonitor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.containerView.superview isEqual:self]) {
        self.containerView.frame = self.bounds;
    }
}

- (void)addMask:(RBPlayerViewMask *)mask animated:(BOOL)animated {
    if ([self containsMask:mask]) return;
    
    if ([self.delegate respondsToSelector:@selector(playerView:willAddMask:animated:)]) {
        if (![self.delegate playerView:self willAddMask:mask animated:animated]) {
            return;
        }
    }
    
    if ([mask respondsToSelector:@selector(willAddToPlayerView:animated:)]) {
        [mask willAddToPlayerView:self animated:animated];
    }
    
    [self.containerView.maskContainerView addSubview:mask];
    
    if (self.currentPlayer.state != RBPlayerStateInit &&
        self.currentPlayer.state != RBPlayerStateStoped &&
        self.currentPlayer.state != RBPlayerStateError) {
        [mask reload];
    }
    
    void(^completionHanler)() = ^{
        if ([mask respondsToSelector:@selector(autoRemoveSeconds)] && [mask autoRemoveSeconds] > 0) {
            [self performSelector:@selector(delayRemoveMask:) withObject:mask afterDelay:[mask autoRemoveSeconds]];
        }
    };
    if (animated && [mask respondsToSelector:@selector(addAnimationWithCompletion:)]) {
        [mask addAnimationWithCompletion:completionHanler];
    } else {
        completionHanler();
    }
}

- (void)removeMask:(RBPlayerViewMask *)mask animated:(BOOL)animated {
    
    if (![self containsMask:mask]) return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRemoveMask:) object:mask];
    
    if ([self.delegate respondsToSelector:@selector(playerView:willRemoveMask:animated:)]) {
        if (![self.delegate playerView:self willRemoveMask:mask animated:animated]) {
            return;
        }
    }
    
    if ([mask respondsToSelector:@selector(willRemoveFromPlayerView:animated:)]) {
        [mask willRemoveFromPlayerView:self animated:animated];
    }
    
    if (animated && [mask respondsToSelector:@selector(removeAnimationWithCompletion:)]) {
        [mask removeAnimationWithCompletion:^{
            [mask removeFromSuperview];
        }];
    } else {
        [mask removeFromSuperview];
    }
}

- (BOOL)containsMask:(RBPlayerViewMask *)mask {
    return [self.masks containsObject:mask];
}

- (NSArray<RBPlayerViewMask *> *)findMaskWithClass:(Class)maskClass {
    return [self.masks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary<NSString *,id> *bindings) {
        return [evaluatedObject isKindOfClass:maskClass];
    }]];
}

- (void)lockAutoRemove:(BOOL)lock withMask:(RBPlayerViewMask *)mask {
    if (lock) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayRemoveMask:) object:mask];
    } else {
        if ([mask respondsToSelector:@selector(autoRemoveSeconds)] && [mask autoRemoveSeconds] > 0) {
            [self performSelector:@selector(delayRemoveMask:) withObject:mask afterDelay:[mask autoRemoveSeconds]];
        }
    }
}

- (void)performOrientationChange:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    
    __weak typeof(self) weakSelf = self;
    [self.changeOrientationQueue cancelAllOperations];
    [self.changeOrientationQueue addOperation:[RBPlayerChangeOrientationOperation blockOperationWithBlock:^(RBPlayerChangeOrientationOperationCompletionHandler completionHandler) {
        
        if (weakSelf == nil || weakSelf.superview == nil) {
            completionHandler();
            return;
        }
        
        UIInterfaceOrientation fromOrientation = weakSelf.visibleInterfaceOrientation;
        UIInterfaceOrientation changeToOrientation = orientation;
        
        if (!((1 << changeToOrientation) & weakSelf.supportedOrientations)) {
            changeToOrientation = UIInterfaceOrientationUnknown;
        }
        
        if ([weakSelf.delegate respondsToSelector:@selector(playerView:willOrientationChange:)]) {
            if (![weakSelf.delegate playerView:weakSelf willOrientationChange:changeToOrientation]) {
                completionHandler();
                return;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RBPlayerViewWillOrientationChangeNotificationName
                                                            object:weakSelf
                                                          userInfo:@{
                                                                     RBPlayerViewWillChangeOrientationKey: @(changeToOrientation),
                                                                     RBPlayerViewWillChangeFromOrientationKey: @(fromOrientation)
                                                                     }];
        
        CGFloat degrees = [weakSelf degreesForOrientation:changeToOrientation];
        CGFloat rotation = (M_PI * degrees / 180.0f);
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        
        BOOL isOriginalFullScreen = fromOrientation != UIInterfaceOrientationUnknown;
        BOOL isChangeFullScreen = changeToOrientation != UIInterfaceOrientationUnknown;
        
        weakSelf.visibleInterfaceOrientation = changeToOrientation;
        
        CGRect containerViewFrame = CGRectZero;
        if (isChangeFullScreen) {
            
            if ([weakSelf.currentPlayer.fullScreenContainerView.superview isEqual:keyWindow]) {
                weakSelf.currentPlayer.fullScreenContainerView.frame = keyWindow.bounds;
            }
            
            if (!isOriginalFullScreen) {
                
                if (weakSelf.currentPlayer.fullScreenContainerView.superview == nil) {
                    weakSelf.currentPlayer.fullScreenContainerView.frame = keyWindow.bounds;
                    [keyWindow addSubview:weakSelf.currentPlayer.fullScreenContainerView];
                }
                
                [weakSelf.containerView removeFromSuperview];
                weakSelf.containerView.frame = [weakSelf.currentPlayer.fullScreenContainerView convertRect:weakSelf.frame fromView:weakSelf.superview];
                [weakSelf.currentPlayer.fullScreenContainerView addSubview:weakSelf.containerView];
            }
            
            containerViewFrame = weakSelf.currentPlayer.fullScreenContainerView.bounds;
        } else {
            if ([weakSelf.containerView.superview isEqual:weakSelf.currentPlayer.fullScreenContainerView]) {
                containerViewFrame = [weakSelf.currentPlayer.fullScreenContainerView convertRect:weakSelf.frame fromView:weakSelf.superview];
            } else {
                containerViewFrame = weakSelf.bounds;
            }
        }
        
        void(^completionBlock)() = ^{
            if (!isChangeFullScreen) {
                
                [weakSelf.containerView removeFromSuperview];
                weakSelf.containerView.frame = weakSelf.bounds;
                [weakSelf addSubview:weakSelf.containerView];
                
                if ([weakSelf.currentPlayer.fullScreenContainerView.superview isEqual:keyWindow]) {
                    [weakSelf.currentPlayer.fullScreenContainerView removeFromSuperview];
                }
            }
            
            if ([weakSelf.delegate respondsToSelector:@selector(playerView:didChangedOrientation:fromOrientation:)]) {
                [weakSelf.delegate playerView:weakSelf didChangedOrientation:changeToOrientation fromOrientation:fromOrientation];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RBPlayerViewDidChangedOrientationNotificationName object:weakSelf];
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3f animations:^{
                
                weakSelf.containerView.transform = CGAffineTransformMakeRotation(rotation);
                weakSelf.containerView.frame = containerViewFrame;
                
            } completion:^(BOOL finished) {
                
                completionBlock();
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    completionHandler();
                });
            }];
        } else {
            weakSelf.containerView.transform = CGAffineTransformMakeRotation(rotation);
            weakSelf.containerView.frame = containerViewFrame;
            
            completionBlock();
            completionHandler();
        }
    }]];
}

#pragma mark - selector

- (void)delayRemoveMask:(RBPlayerViewMask *)mask {
    [self removeMask:mask animated:YES];
}

- (void)orientationChanged:(UIDeviceOrientation)deviceOrientation {
    if (!self.autoChangedOrientation) {
        return;
    }
    
    UIInterfaceOrientation rotateToOrientation;
    switch(deviceOrientation) {
        case UIDeviceOrientationPortrait:
            rotateToOrientation = UIInterfaceOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            rotateToOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            rotateToOrientation = UIInterfaceOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            rotateToOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
        default:
            return;
    }
    
    if ((!((1 << rotateToOrientation) & self.supportedOrientations) || self.visibleInterfaceOrientation == UIDeviceOrientationUnknown) && !self.autoFullScreen) {
        return;
    }
    
    [self performOrientationChange:rotateToOrientation animated:YES];
}

- (CGFloat)degreesForOrientation:(UIInterfaceOrientation)orientation {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow.bounds.size.width > keyWindow.bounds.size.height) {
        switch (orientation) {
            case UIInterfaceOrientationUnknown:
                return 0;
            case UIInterfaceOrientationPortrait:
                return -90;
            case UIInterfaceOrientationLandscapeRight: {
                if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
                    return -180;
                } else {
                    return 0;
                }
            }
            case UIInterfaceOrientationLandscapeLeft: {
                if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
                    return -180;
                } else {
                    return 0;
                }
            }
            case UIInterfaceOrientationPortraitUpsideDown:
                return 90;
        }
    } else {
        switch (orientation) {
            case UIInterfaceOrientationUnknown:
            case UIInterfaceOrientationPortrait:
                return 0;
            case UIInterfaceOrientationLandscapeRight:
                return 90;
            case UIInterfaceOrientationLandscapeLeft:
                return -90;
            case UIInterfaceOrientationPortraitUpsideDown:
                return 180;
        }
    }
}

#pragma mark - getters setters

- (BOOL)isFullScreen {
    return self.visibleInterfaceOrientation != UIDeviceOrientationUnknown;
}

- (void)setIgnoreScreenSystemLock:(BOOL)ignoreScreenSystemLock {
    self.orientationDmonitor.ignoreScreenSystemLock = ignoreScreenSystemLock;
}

- (BOOL)ignoreScreenSystemLock {
    return self.orientationDmonitor.ignoreScreenSystemLock;
}

- (NSArray<RBPlayerViewMask *> *)masks {
    return [self.containerView.maskContainerView.subviews copy];
}

- (RBPlayerContainerView *)containerView {
    if (_containerView == nil) {
        _containerView = [[RBPlayerContainerView alloc] init];
    }
    return _containerView;
}

@end
