//
//  RBPlayerTopMask.m
//  Pods
//
//  Created by Ribs on 16/8/24.
//
//

#import "RBPlayerTopMask.h"
#import "RBVideoPlayer.h"

#define kRBPlayerTopHeight 44.0f
#define kRBPlayerTopButtonWidth 50.0f

@interface RBPlayerTopMask ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation RBPlayerTopMask

- (instancetype)initWithPlayerView:(RBPlayerView *)playerView {
    self = [super initWithPlayerView:playerView];
    if (self) {        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.superview == nil) return;
    
    CGRect superviewFrame = self.superview.frame;
    
    CGFloat y = 0;
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(statusBarOrientation)) {
        y = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    CGFloat height = kRBPlayerTopHeight + y;
    
    CGRect frame = CGRectMake(0, 0, superviewFrame.size.width, height);
    
    self.frame = frame;
    
    __block CGFloat leftButtonX = 0;
    [self.leftButtons enumerateObjectsUsingBlock:^(RBPlayerControlButton *obj, NSUInteger idx, BOOL *stop) {
        if (!obj.button.hidden)  {
            obj.button.frame = CGRectMake(leftButtonX, y, kRBPlayerTopButtonWidth, kRBPlayerTopHeight);
            leftButtonX = leftButtonX + kRBPlayerTopButtonWidth;
        }
    }];
    
    __block CGFloat rightButtonX = frame.size.width;
    [self.rightButtons enumerateObjectsUsingBlock:^(RBPlayerControlButton *obj, NSUInteger idx, BOOL *stop) {
        if (!obj.button.hidden)  {
            rightButtonX = rightButtonX - kRBPlayerTopButtonWidth;
            obj.button.frame = CGRectMake(rightButtonX, y, kRBPlayerTopButtonWidth, kRBPlayerTopHeight);
        }
    }];
    
    CGFloat titleLabelX = leftButtonX > 0 ? leftButtonX : 10;
    self.titleLabel.frame = CGRectMake(titleLabelX,
                                       y,
                                       rightButtonX - titleLabelX,
                                       kRBPlayerTopHeight);
}

#pragma mark - mask

- (void)reload {
    
    self.titleLabel.text = self.currentPlayerView.currentPlayer.currentItem.title;
    
    [self layoutSubviews];
}

- (void)addAnimationWithCompletion:(void(^)())completion {
    self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)removeAnimationWithCompletion:(void(^)())completion {
    self.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        self.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - getters setters

- (void)setLeftButtons:(NSArray<RBPlayerControlButton *> *)leftButtons {
    if ([_leftButtons isEqual:leftButtons]) return;
    
    [_leftButtons enumerateObjectsUsingBlock:^(RBPlayerControlButton *obj, NSUInteger idx, BOOL *stop) {
        [obj.button removeFromSuperview];
    }];
    
    _leftButtons = leftButtons;
    
    [_leftButtons enumerateObjectsUsingBlock:^(RBPlayerControlButton *obj, NSUInteger idx, BOOL *stop) {
        [self addSubview:obj.button];
    }];
}

- (void)setRightButtons:(NSArray<RBPlayerControlButton *> *)rightButtons {
    if ([_rightButtons isEqual:rightButtons]) return;
    
    [_rightButtons enumerateObjectsUsingBlock:^(RBPlayerControlButton *obj, NSUInteger idx, BOOL *stop) {
        [obj.button removeFromSuperview];
    }];
    
    _rightButtons = rightButtons;
    
    [_rightButtons enumerateObjectsUsingBlock:^(RBPlayerControlButton *obj, NSUInteger idx, BOOL *stop) {
        [self addSubview:obj.button];
    }];
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

@end
