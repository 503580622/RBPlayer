//
//  RBPlayerLoadingMask.m
//  Pods
//
//  Created by 黄泽新 on 16/8/26.
//
//

#import "RBPlayerLoadingMask.h"
#import "RBVideoPlayer.h"

@interface RBPlayerLoadingMask ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation RBPlayerLoadingMask

- (instancetype)initWithPlayerView:(RBPlayerView *)playerView {
    self = [super initWithPlayerView:playerView];
    if (self) {
        self.userInteractionEnabled = NO;
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.superview == nil) return;
    
    self.frame = self.superview.bounds;
    
    self.indicatorView.center = self.center;
    
    [self reload];
}

- (void)reload {
    if (self.currentPlayerView.currentPlayer.state == RBPlayerStateInit ||
        self.currentPlayerView.currentPlayer.state == RBPlayerStatePrepared ||
        self.currentPlayerView.currentPlayer.state == RBPlayerStateBuffering) {
        self.indicatorView.hidden = NO;
        [self.indicatorView startAnimating];
    } else {
        self.indicatorView.hidden = YES;
        [self.indicatorView stopAnimating];
    }
}

- (void)playerDidChangedState {
    [self reload];
}

#pragma mark - getters setters

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.hidden = NO;
        [_indicatorView startAnimating];
    }
    return _indicatorView;
}
@end
