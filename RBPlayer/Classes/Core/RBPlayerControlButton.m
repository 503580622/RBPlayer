//
//  RBPlayerControlButton.m
//  Pods
//
//  Created by Ribs on 16/8/26.
//
//

#import "RBPlayerControlButton.h"
#import "RBCorePlayer.h"

@interface RBPlayerControlButton ()

@property (nonatomic, weak) RBPlayerViewMask *currentMask;
@property (nonatomic, strong) UIButton *button;

@property (nonatomic, copy) void(^mainBlock)();

@end

@implementation RBPlayerControlButton

- (instancetype)initWithMask:(RBPlayerViewMask *)mask mainBlock:(void(^)())mainBlock {
    self = [self initWithMask:mask];
    if (self) {
        self.mainBlock = mainBlock;
    }
    return self;
}

- (instancetype)initWithMask:(RBPlayerViewMask *)mask {
    self = [super init];
    if (self) {
        self.currentMask = mask;
        [self.button addTarget:self action:@selector(buttonTap) forControlEvents:UIControlEventTouchUpInside];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_playerDidChangedState:)
                                                     name:RBPlayerDidStateChangeNotificationName
                                                   object:self.currentMask.currentPlayerView.currentPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_playerViewWillChangeOrientation:)
                                                     name:RBPlayerViewWillOrientationChangeNotificationName
                                                   object:self.currentMask.currentPlayerView];
    }
    return self;
}

- (void)dealloc {
    self.mainBlock = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RBPlayerDidStateChangeNotificationName object:self.currentMask.currentPlayerView.currentPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RBPlayerViewWillOrientationChangeNotificationName object:self.currentMask.currentPlayerView];
}

- (void)reload {
    
}

- (void)main {
    
}


#pragma mark - selector

- (void)_playerDidChangedState:(NSNotification *)notification {
    
    if (self.currentMask.currentPlayerView.currentPlayer.state == RBPlayerStatePrepared) {
        [self reload];
    }
    
    if ([self respondsToSelector:@selector(playerDidChangedState)]) {
        [self playerDidChangedState];
    }
}

- (void)_playerViewWillChangeOrientation:(NSNotification *)notification {
    UIInterfaceOrientation willChangeOrientation = [[notification.userInfo objectForKey:RBPlayerViewWillChangeOrientationKey] integerValue];
    UIInterfaceOrientation changeFromOrientation = [[notification.userInfo objectForKey:RBPlayerViewWillChangeFromOrientationKey] integerValue];
    if ([self respondsToSelector:@selector(playerViewWillChangeOrientation:fromOrientation:)]) {
        [self playerViewWillChangeOrientation:willChangeOrientation fromOrientation:changeFromOrientation];
    }
}

- (void)buttonTap {
    if ([self.currentMask.currentPlayerView.delegate respondsToSelector:@selector(playerView:willTapControlButton:)]) {
        if (![self.currentMask.currentPlayerView.delegate playerView:self.currentMask.currentPlayerView willTapControlButton:self]) {
            return;
        }
    }
    
    if (self.mainBlock != nil) {
        self.mainBlock();
    } else {
        [self main];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RBPlayerViewTapControlButtoneNotificationName object:self];
}

#pragma mark - getters setters 

- (UIButton *)button {
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.titleLabel.font = [UIFont systemFontOfSize:14];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _button;
}

@end