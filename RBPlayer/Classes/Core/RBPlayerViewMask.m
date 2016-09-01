//
//  RBPlayerViewMask.m
//  Pods
//
//  Created by Ribs on 16/8/26.
//
//

#import "RBPlayerViewMask.h"
#import "RBCorePlayer.h"

@interface RBPlayerViewMask ()

@property (nonatomic, weak) RBPlayerView *currentPlayerView;

@end

@implementation RBPlayerViewMask

- (instancetype)initWithPlayerView:(RBPlayerView *)playerView {
    self = [super init];
    if (self) {
        self.currentPlayerView = playerView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_playerDidChangedState:)
                                                     name:RBPlayerDidStateChangeNotificationName
                                                   object:self.currentPlayerView.currentPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_playerViewWillChangeOrientation:)
                                                     name:RBPlayerViewWillOrientationChangeNotificationName
                                                   object:self.currentPlayerView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RBPlayerDidStateChangeNotificationName object:self.currentPlayerView.currentPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RBPlayerViewWillOrientationChangeNotificationName object:self.currentPlayerView];
}

- (void)reload {
    
}

#pragma mark - selector

- (void)_playerDidChangedState:(NSNotification *)notification {
    if (self.currentPlayerView.currentPlayer.state == RBPlayerStatePrepared) {
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

@end