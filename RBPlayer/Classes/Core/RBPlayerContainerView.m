//
//  RBPlayerContainerView.m
//  Pods
//
//  Created by 黄泽新 on 16/8/23.
//
//

#import "RBPlayerContainerView.h"

@interface RBPlayerContainerView ()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIView *maskContainerView;

@end

@implementation RBPlayerContainerView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        [self.layer addSublayer:self.playerLayer];
        [self addSubview:self.maskContainerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    self.maskContainerView.frame = self.bounds;
    
    [self.maskContainerView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview setNeedsLayout];
    }];
}

#pragma mark - getters setters

- (UIView *)maskContainerView {
    if (_maskContainerView == nil) {
        _maskContainerView = [[UIView alloc] init];
        _maskContainerView.backgroundColor = [UIColor clearColor];
        _maskContainerView.autoresizesSubviews = YES;
    }
    return _maskContainerView;
}

- (AVPlayerLayer *)playerLayer {
    if (_playerLayer == nil) {
        _playerLayer = [AVPlayerLayer layer];
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _playerLayer;
}

@end
