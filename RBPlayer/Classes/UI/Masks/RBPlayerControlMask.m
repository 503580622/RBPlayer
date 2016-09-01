//
//  RBPlayerControlMask.m
//  Pods
//
//  Created by Ribs on 16/8/24.
//
//

#import "RBPlayerControlMask.h"
#import "RBVideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

#define UNIT_PIXEL (5 * [UIScreen mainScreen].scale)

typedef NS_ENUM(NSUInteger, RBGestureOperateType) {
    RBGestureOperateTypeUnknow,
    RBGestureOperateTypeLumina,
    RBGestureOperateTypeProgress,
    RBGestureOperateTypeVolume,
};

@interface RBPlayerControlMask ()

@property (nonatomic, strong) CALayer *luminaLayer;
@property (nonatomic, strong) UISlider *mpVolumeSlider;
@property (nonatomic, strong) UIView *volumeSliderContainerView;
@property (nonatomic, strong) RBPlayerSlider *volumeSlider;

@end

@implementation RBPlayerControlMask

- (instancetype)initWithPlayerView:(RBPlayerView *)playerView {
    self = [super initWithPlayerView:playerView];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self.layer addSublayer:self.luminaLayer];
        
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        volumeView.frame = CGRectMake(-1000, -1000, 1, 1);
        [self addSubview:volumeView];
        for (UIControl *view in volumeView.subviews) {
            if ([view.superclass isSubclassOfClass:[UISlider class]]) {
                self.mpVolumeSlider = (UISlider *)view;
                break;
            }
        }
        [self.mpVolumeSlider addTarget:self action:@selector(volumeChanged) forControlEvents:UIControlEventValueChanged];
        self.volumeSlider.maximumValue = self.mpVolumeSlider.maximumValue;
        self.volumeSlider.value = self.mpVolumeSlider.value;
        
        [self.volumeSliderContainerView addSubview:self.volumeSlider];
        [self addSubview:self.volumeSliderContainerView];
        
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGr];
        
        UITapGestureRecognizer *doubleTapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTapGr.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGr];
        
        [tapGr requireGestureRecognizerToFail:doubleTapGr];
        
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    }
    return self;
}

- (void)dealloc {
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.superview == nil) {
        return;
    }
    
    self.frame = self.superview.bounds;
    
    self.volumeSliderContainerView.frame = CGRectMake(20, self.frame.size.height/2 - (self.frame.size.height/2)/2, 30, self.frame.size.height/2);
    self.volumeSlider.frame = CGRectMake(10, 0, self.volumeSliderContainerView.frame.size.height - 20, self.volumeSliderContainerView.frame.size.width);
    
    [CATransaction setDisableActions:YES];
    self.luminaLayer.frame = self.bounds;
    [CATransaction setDisableActions:NO];
}

#pragma mark - selector

- (void)volumeChanged {
    self.volumeSlider.value = self.mpVolumeSlider.value;
}

- (void)tap:(UITapGestureRecognizer *)gr {
    RBVideoPlayer *player = (RBVideoPlayer *)self.currentPlayerView.currentPlayer;
    RBPlayerItemAssetMenuMask *itemAssetMenuMask =  (RBPlayerItemAssetMenuMask *)[[player.view findMaskWithClass:[RBPlayerItemAssetMenuMask class]] firstObject];
    if (itemAssetMenuMask != nil) {
        [player.view removeMask:itemAssetMenuMask animated:YES];
    } else {
        if ([player.view containsMask:player.bottomMask]) {
            [player.view removeMask:player.bottomMask animated:YES];
        } else {
            [player.view addMask:player.bottomMask animated:YES];
        }
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)gr {
    [self.currentPlayerView.currentPlayer resumeOrPause];
}

- (void)pan:(UIPanGestureRecognizer *)gr {
    static CGPoint _startTranslation;
    static BOOL _isLeft;
    static float _oldVolume;
    static float _oldLumina;
    static NSUInteger _oldSeconds;
    static RBGestureOperateType _opType;
    
    CGPoint currentTranslation = [gr translationInView:self];
    
    switch (gr.state) {
        case UIGestureRecognizerStateBegan: {
            _startTranslation = currentTranslation;
            _isLeft = [gr locationInView:self].x < CGRectGetMidX(self.bounds);
            
            _oldVolume = self.mpVolumeSlider.value;
            _oldLumina = 1 - self.luminaLayer.opacity;
            _oldSeconds = self.currentPlayerView.currentPlayer.currentItem.currentSeconds;
            _opType = RBGestureOperateTypeUnknow;
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (_opType == RBGestureOperateTypeUnknow) {
                if (ABS(currentTranslation.x - _startTranslation.x) > ABS(currentTranslation.y - _startTranslation.y)) {
                    _opType = RBGestureOperateTypeProgress;
                    RBVideoPlayer *player = (RBVideoPlayer *)self.currentPlayerView.currentPlayer;
                    [player pause];
                    [player.view addMask:player.bottomMask animated:YES];
                    [player.view lockAutoRemove:YES withMask:player.bottomMask];
                }  else {
                    if (_isLeft) {
                        _opType = RBGestureOperateTypeLumina;
                    } else {
                        _opType = RBGestureOperateTypeVolume;
                        
                        self.volumeSliderContainerView.hidden = NO;
                        self.volumeSliderContainerView.alpha = 0;
                        [UIView animateWithDuration:0.2 animations:^{
                            self.volumeSliderContainerView.alpha = 1;
                        }];
                    }
                }
            }
            
            if (_opType == RBGestureOperateTypeProgress) {
                CGFloat uint = currentTranslation.x - _startTranslation.x / UNIT_PIXEL;
                if (ABS(uint) >= 1) {
                    NSUInteger seconds = _oldSeconds + uint;
                    if (seconds > self.currentPlayerView.currentPlayer.currentItem.duration) {
                        seconds = self.currentPlayerView.currentPlayer.currentItem.duration;
                    }
                    
                    RBVideoPlayer *player = (RBVideoPlayer *)self.currentPlayerView.currentPlayer;
                    if ([player.bottomMask isKindOfClass:[RBPlayerBottomMask class]]) {
                        RBPlayerBottomMask *bottomMask = (RBPlayerBottomMask *)player.bottomMask;
                        bottomMask.timeSlider.value = (double)seconds / (double)player.currentItem.duration;;
                    }
                }
            } else {
                CGFloat uint = currentTranslation.y - _startTranslation.y / UNIT_PIXEL;
                if (ABS(uint) >= 1) {
                    if (_opType == RBGestureOperateTypeLumina) {
                        float newLumina = _oldLumina + -uint * 0.01;
                        if (newLumina < 0.1) {
                            newLumina = 0.1;
                        } else if (newLumina > 1) {
                            newLumina = 1;
                        }
                        [CATransaction setDisableActions:YES];
                        self.luminaLayer.opacity = 1 - newLumina;
                        [CATransaction setDisableActions:NO];
                    } else {
                        float newVolume = _oldVolume + -uint * 0.01;
                        if (newVolume > self.mpVolumeSlider.maximumValue) {
                            newVolume = self.mpVolumeSlider.maximumValue;
                        } else if (newVolume < 0) {
                            newVolume = 0;
                        }
                        self.mpVolumeSlider.value = newVolume;
                    }
                }
            }
            
            break;
        }
        default: {
            if (_opType == RBGestureOperateTypeProgress) {
                
                RBVideoPlayer *player = (RBVideoPlayer *)self.currentPlayerView.currentPlayer;
                
                CGFloat uint = currentTranslation.x - _startTranslation.x / UNIT_PIXEL;
                if (ABS(uint) >= 1) {
                    NSUInteger seconds = _oldSeconds + uint;
                    if (seconds > player.currentItem.duration) {
                        seconds = player.currentItem.duration;
                    }
                    [player seekToSeconds:seconds];
                }
                
                [player.view lockAutoRemove:NO withMask:player.bottomMask];
                
            } else if (_opType == RBGestureOperateTypeVolume) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.volumeSliderContainerView.alpha = 0;
                } completion:^(BOOL finished) {
                    self.volumeSliderContainerView.hidden = YES;
                }];
            }
            break;
        }
    }
}

#pragma mark - mask

- (void)reload {
    
}

#pragma mark - setters getters

- (UIView *)volumeSliderContainerView {
    if (_volumeSliderContainerView == nil) {
        _volumeSliderContainerView = [[UIView alloc] init];
        _volumeSliderContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _volumeSliderContainerView.layer.cornerRadius = 15;
        _volumeSliderContainerView.transform = CGAffineTransformMakeRotation((M_PI * -90 / 180.0f));
        _volumeSliderContainerView.hidden = YES;
    }
    return _volumeSliderContainerView;
}

- (RBPlayerSlider *)volumeSlider {
    if (_volumeSlider == nil) {
        _volumeSlider = [[RBPlayerSlider alloc] init];
        _volumeSlider.thumbSize = 10;
    }
    return _volumeSlider;
}

- (CALayer *)luminaLayer {
    if (_luminaLayer == nil) {
        _luminaLayer = [CALayer layer];
        _luminaLayer.opacity = 0;
        _luminaLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    return _luminaLayer;
}
@end
