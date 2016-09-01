//
//  RBPlayerBottomMask.m
//  Pods
//
//  Created by Ribs on 16/8/22.
//
//

#import "RBPlayerBottomMask.h"
#import "RBVideoPlayer.h"

#define kRBPlayerBottomHeight 40.0f
#define kRBPlayerBottomFullScreenHeight 50.0f
#define kRBPlayerBottomButtonWidth 50.0f

@interface RBPlayerBottomMask ()

@property (nonatomic, strong) RBPlayerSlider *timeSlider;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic) BOOL removeAnimcating;

@end

@implementation RBPlayerBottomMask

- (instancetype)initWithPlayerView:(RBPlayerView *)playerView {
    self = [super initWithPlayerView:playerView];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        
        self.leftButtons = @[
                              [[RBPlayerControlPlayOrPauseButton alloc] initWithMask:self]
                              ];
        self.rightButtons = @[
                              [[RBPlayerControlFullScreenButton alloc] initWithMask:self],
                              [[RBPlayerControlRateButton alloc] initWithMask:self],
                              [[RBPlayerControlItemAssetMenuButton alloc] initWithMask:self]
                              ];
       
        [self addSubview:self.timeSlider];
        [self addSubview:self.timeLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerUpdateCurrentSeconds)
                                                     name:RBPlayerUpdateCurrentSecondsNotificationName
                                                   object:self.currentPlayerView.currentPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerUpdateBufferedSeconds)
                                                     name:RBPlayerUpdateBufferedSecondsNotificationName
                                                   object:self.currentPlayerView.currentPlayer];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RBPlayerUpdateCurrentSecondsNotificationName object:self.currentPlayerView.currentPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RBPlayerUpdateBufferedSecondsNotificationName object:self.currentPlayerView.currentPlayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.superview == nil) return;
    
    CGRect superviewFrame = self.superview.frame;
    CGFloat height = self.currentPlayerView.currentPlayer.view.isFullScreen ? kRBPlayerBottomFullScreenHeight : kRBPlayerBottomHeight;
    CGRect frame = CGRectMake(0, superviewFrame.size.height - height, superviewFrame.size.width, height);
    
    self.frame = frame;
    
    __block CGFloat leftButtonX = 0;
    [self.leftButtons enumerateObjectsUsingBlock:^(RBPlayerControlButton *obj, NSUInteger idx, BOOL *stop) {
        if (!obj.button.hidden)  {
            obj.button.frame = CGRectMake(leftButtonX, 0, kRBPlayerBottomButtonWidth, height);
            leftButtonX = leftButtonX + kRBPlayerBottomButtonWidth;
        }
    }];
    
    __block CGFloat rightButtonX = frame.size.width;
    [self.rightButtons enumerateObjectsUsingBlock:^(RBPlayerControlButton *obj, NSUInteger idx, BOOL *stop) {
        if (!obj.button.hidden)  {
            rightButtonX = rightButtonX - kRBPlayerBottomButtonWidth;
            obj.button.frame = CGRectMake(rightButtonX, 0, kRBPlayerBottomButtonWidth, height);
        }
    }];
    
    CGFloat timeLabelX;
    if (self.currentPlayerView.currentPlayer.view.isFullScreen) {
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        [self.timeLabel sizeToFit];
        timeLabelX = leftButtonX;
    } else {
        self.timeLabel.font = [UIFont systemFontOfSize:10];
        [self.timeLabel sizeToFit];
        timeLabelX = rightButtonX - self.timeLabel.frame.size.width;
    }
    self.timeLabel.frame = CGRectMake(timeLabelX, 0, self.timeLabel.frame.size.width + 2, height);
    
    if (self.currentPlayerView.currentPlayer.view.isFullScreen) {
        self.timeSlider.frame = CGRectMake(0, -3, frame.size.width, 8);
    } else {
        self.timeSlider.frame = CGRectMake(leftButtonX, 0, self.timeLabel.frame.origin.x - 10 - leftButtonX, height);
    }
}

#pragma mark - selector

- (void)playerUpdateCurrentSeconds {
    self.timeSlider.value = (double)self.currentPlayerView.currentPlayer.currentItem.currentSeconds / (double)self.currentPlayerView.currentPlayer.currentItem.duration;
    [self setCurrentDisplayTime:self.currentPlayerView.currentPlayer.currentItem.currentSeconds];
}

- (void)playerUpdateBufferedSeconds {
    self.timeSlider.loadedValue = (double)self.currentPlayerView.currentPlayer.currentItem.bufferedSeconds / (double)self.currentPlayerView.currentPlayer.currentItem.duration;
}

- (void)scrubbingBegin {
    [self.currentPlayerView.currentPlayer pause];
    [self.currentPlayerView.currentPlayer.view lockAutoRemove:YES withMask:self];
}

- (void)scrubbingChanged {
    NSUInteger time = (self.timeSlider.value / self.timeSlider.maximumValue) * self.currentPlayerView.currentPlayer.currentItem.duration;
    [self setCurrentDisplayTime:time];
}

- (void)scrubbingEnd {
    [self.currentPlayerView.currentPlayer seekToSeconds:self.timeSlider.value*self.currentPlayerView.currentPlayer.currentItem.duration];
    [self.currentPlayerView.currentPlayer.view lockAutoRemove:NO withMask:self];
}

#pragma mark - mask

- (void)reload {
    [self setCurrentDisplayTime:0];
    [self.timeLabel sizeToFit];
}

- (NSTimeInterval)autoRemoveSeconds {
    return 5;
}

- (void)willAddToPlayerView:(RBPlayerView *)playerView animated:(BOOL)animated {
    RBVideoPlayer *player = (RBVideoPlayer *)playerView.currentPlayer;
    if (player.view.isFullScreen) {
        [player.view addMask:player.topMask animated:YES];
    }
}

- (void)willRemoveFromPlayerView:(RBPlayerView *)playerView animated:(BOOL)animated {
    RBVideoPlayer *player = (RBVideoPlayer *)playerView.currentPlayer;
    [player.view removeMask:player.topMask animated:YES];
}

- (void)addAnimationWithCompletion:(void(^)())completion {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)removeAnimationWithCompletion:(void(^)())completion {
    
    self.removeAnimcating = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 40);
    } completion:^(BOOL finished) {
        
        self.removeAnimcating = NO;
        
        if (completion) {
            completion();
        }
    }];
}

- (void)playerDidChangedState {
    
    if (self.currentPlayerView.currentPlayer.state != RBPlayerStatePlaying &&
        self.currentPlayerView.currentPlayer.state != RBPlayerStateBuffering &&
        self.currentPlayerView.currentPlayer.state != RBPlayerStatePaused) {
        self.timeSlider.value = 0;
        self.timeSlider.loadedValue = 0;
        self.timeSlider.userInteractionEnabled = NO;
    } else {
        self.timeSlider.userInteractionEnabled = YES;
    }
    
    [self setNeedsLayout];
}

- (void)playerViewWillChangeOrientation:(UIInterfaceOrientation)orientation fromOrientation:(UIInterfaceOrientation)fromOrientation {

    RBVideoPlayer *player = (RBVideoPlayer *)self.currentPlayerView.currentPlayer;
    
    if (orientation != UIInterfaceOrientationUnknown) {
        if ([player.view containsMask:self] && !self.removeAnimcating) {
            [player.view addMask:player.topMask animated:NO];
        }
    } else {
        [player.view removeMask:player.topMask animated:NO];
    }
}

#pragma mark - private

- (void)setCurrentDisplayTime:(NSUInteger)currentSeconds {
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@",
                           [self timeShowTextWithPlaySeconds:currentSeconds],
                           [self timeShowTextWithPlaySeconds:self.currentPlayerView.currentPlayer.currentItem.duration]];
}

- (NSString*)timeShowTextWithPlaySeconds:(Float64)playSeconds {
    NSInteger nPlaySeconds = (NSInteger)playSeconds;
    NSInteger hour = nPlaySeconds / 3600;
    NSInteger minute = (nPlaySeconds - hour * 3600) / 60;
    NSInteger seconds = nPlaySeconds - hour * 3600 - minute * 60;
    NSString *timeText;
    if (hour > 0) {
        timeText = [NSString stringWithFormat:@"%.02zd:%.02zd:%.02zd", hour, minute, seconds];
    } else {
        timeText = [NSString stringWithFormat:@"%.02zd:%.02zd", minute, seconds];
    }
    return timeText;
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

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.text = @"00:00 / 00:00";
        [_timeLabel sizeToFit];
    }
    return _timeLabel;
}

- (RBPlayerSlider *)timeSlider {
    if (_timeSlider== nil) {
        _timeSlider = [[RBPlayerSlider alloc] init];
        [_timeSlider addTarget:self action:@selector(scrubbingBegin) forControlEvents:UIControlEventTouchDown];
        [_timeSlider addTarget:self action:@selector(scrubbingChanged) forControlEvents:UIControlEventValueChanged];
        [_timeSlider addTarget:self action:@selector(scrubbingEnd) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeSlider;
}

@end
