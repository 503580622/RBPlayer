//
//  RBPlayer.m
//  Pods
//
//  Created by Ribs on 16/8/22.
//
//

#import "RBCorePlayer.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

NSString *const RBPlayerPlayItemAssetNotificationName = @"RBPlayerPlayItemAssetNotificationName";
NSString *const RBPlayerDidPlayToEndNotificationName = @"RBPlayerDidPlayToEndNotificationName";
NSString *const RBPlayerDidStateChangeNotificationName = @"RBPlayerDidStateChangeNotificationName";
NSString *const RBPlayerUpdateCurrentSecondsNotificationName = @"RBPlayerUpdateCurrentSecondsNotificationName";
NSString *const RBPlayerUpdateBufferedSecondsNotificationName = @"RBPlayerUpdateBufferedSecondsNotificationName";

@interface RBPlayerItem (Update)

- (void)updateDuration:(NSUInteger)duration;
- (void)updateCurrentSeconds:(NSUInteger)currentSeconds;
- (void)updateBufferedSeconds:(NSUInteger)bufferedSeconds;
- (void)updatePlayingAsset:(RBPlayerItemAsset *)playingAsset;

@end

@interface RBCorePlayer ()

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic) AVPlayerItemStatus lastPlayerItemStatus;

@property (nonatomic, strong) RBPlayerItem *currentItem;
@property (nonatomic, strong) RBPlayerView *view;
@property (nonatomic, strong) UIView *fullScreenContainerView;

@property (nonatomic) RBPlayerState state;
@property (nonatomic) RBPlayerState beforeEnterBackgroundState;

@property (nonatomic) NSInteger seekSeconds;
@property (nonatomic, copy) void (^seekCompletionHandler)(BOOL finished);

@end

@implementation RBCorePlayer

@synthesize rate = _rate;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.playInMoreBufferSeconds = 10;
        self.state = RBPlayerStateInit;
        self.rate = 1;
        
        [self addTimerObserver];
        [self addNotification];
    }
    return self;
}

- (void)dealloc {
    
    self.playerItem = nil;
    
    [self.view removeFromSuperview];
    [self.view.containerView.playerLayer removeFromSuperlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)replaceCurrentItemWithPlayerItem:(RBPlayerItem *)playerItem {
    if (playerItem == nil) return;
    
    self.state = RBPlayerStateStoped;
    self.currentItem = playerItem;
}

- (void)playWithItemAsset:(RBPlayerItemAsset *)itemAsset {
    if (itemAsset == nil || itemAsset.URL == nil) return;
    
    if ([self.delegate respondsToSelector:@selector(player:willPlayItemAsset:originalItemAsset:)]) {
        if (![self.delegate player:self willPlayItemAsset:itemAsset originalItemAsset:self.currentItem.playingAsset]) {
            return;
        }
    }
    
    if (self.currentItem == nil || ![self.currentItem.assets containsObject:itemAsset]) {
        RBPlayerItem *item = [[RBPlayerItem alloc] init];
        item.assets = @[itemAsset];
        [self replaceCurrentItemWithPlayerItem:item];
    } else {
        self.state = RBPlayerStateStoped;
    }
    
    self.lastPlayerItemStatus = AVPlayerItemStatusUnknown;
    [self.currentItem updatePlayingAsset:itemAsset];
    
    self.playerItem = [[AVPlayerItem alloc] initWithURL:itemAsset.URL];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RBPlayerPlayItemAssetNotificationName object:self];
    
}

- (void)playWithURL:(NSURL *)URL {
    RBPlayerItemAsset *itemAsset = [[RBPlayerItemAsset alloc] initWithType:@"" URL:URL];
    
    RBPlayerItem *item = [[RBPlayerItem alloc] init];
    item.assets = @[itemAsset];
    
    [self replaceCurrentItemWithPlayerItem:item];
    [self playWithItemAsset:itemAsset];
}

- (void)resumeOrPause {
    if (self.state == RBPlayerStatePlaying) {
        [self pause];
    } else {
        [self resume];
    }
}

- (void)resume {
    if (self.playerItem == nil) {
        if (self.currentItem != nil && self.currentItem.playingAsset != nil) {
            [self playWithItemAsset:self.currentItem.playingAsset];
        }
        return;
    } else if (self.playerItem.status != AVPlayerItemStatusReadyToPlay) {
        return;;
    }
    
    if (self.seekSeconds > -1) {
        __weak typeof(self) weaKSelf = self;
        [self seekToSeconds:self.seekSeconds completionHandler:^(BOOL finished) {
            if (weaKSelf.seekCompletionHandler != nil) {
                weaKSelf.seekCompletionHandler(finished);
            }
            weaKSelf.seekSeconds = -1;
            weaKSelf.seekCompletionHandler = nil;
        }];
    } else {
        self.state = RBPlayerStatePlaying;
    }
}

- (void)pause {
    
    if (self.playerItem == nil || self.playerItem.status != AVPlayerItemStatusReadyToPlay) return;
    
    self.state = RBPlayerStatePaused;
}

- (void)stop {
    self.state = RBPlayerStateStoped;
}

- (void)seekToSeconds:(NSUInteger)seconds {
    [self seekToSeconds:seconds completionHandler:^(BOOL finished) {
        if (finished) {
            NSUInteger canPlaySeconds = self.currentItem.currentSeconds + self.playInMoreBufferSeconds;
            if (canPlaySeconds > self.currentItem.duration) {
                canPlaySeconds = self.currentItem.duration;
            }
            if (self.currentItem.bufferedSeconds >= canPlaySeconds) {
                self.state = RBPlayerStatePlaying;
            } else {
                self.state = RBPlayerStateBuffering;
            }
        }
    }];
}

- (void)seekToSeconds:(NSUInteger)seconds completionHandler:(void (^)(BOOL finished))completionHandler {
    if (self.playerItem.status != AVPlayerItemStatusReadyToPlay) {
        self.seekSeconds = seconds;
        self.seekCompletionHandler = completionHandler;
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(player:willSeekToSeconds:)]) {
        if (![self.delegate player:self willSeekToSeconds:seconds]) {
            if (completionHandler != nil) {
                completionHandler(NO);
            }
            return;
        }
    }
    
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(seconds, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (completionHandler != nil) {
            completionHandler(finished);
        }
    }];
}

#pragma mark - selector

- (void)playEnd:(NSNotification *)notification {
    
    if (![self.playerItem isEqual:notification.object]) return;
    
    self.state = RBPlayerStateStoped;
    
    if ([self.delegate respondsToSelector:@selector(didPlayToEndInPlayer:)]) {
        [self.delegate didPlayToEndInPlayer:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RBPlayerDidPlayToEndNotificationName object:self];
}

- (void)applicationDidEnterBackground {
    if (self.state != RBPlayerStatePlaying) return;
    self.beforeEnterBackgroundState = self.state;
    self.state = RBPlayerStatePaused;
}

- (void)applicationWillEnterForeground {
    if (self.beforeEnterBackgroundState == RBPlayerStatePlaying) {
        self.state = RBPlayerStatePlaying;
        self.beforeEnterBackgroundState = RBPlayerStateInit;
    }
}

#pragma mark - KVO

- (void)addTimerObserver {
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
        if (weakSelf == nil ||
            weakSelf.state == RBPlayerStateInit || weakSelf.state == RBPlayerStateError ||
            weakSelf.view.superview == nil) return;
        
        NSUInteger currentSeconds = time.value * 1.0 / time.timescale;
        
        [weakSelf.currentItem updateCurrentSeconds:currentSeconds];
        
        if ([weakSelf.delegate respondsToSelector:@selector(player:updateCurrentSeconds:)]) {
            [weakSelf.delegate player:weakSelf updateCurrentSeconds:currentSeconds];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RBPlayerUpdateCurrentSecondsNotificationName object:weakSelf];
    }];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    
    if (self.view.superview == nil) return;
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = self.playerItem.status;
        if (self.lastPlayerItemStatus == status) return;
        self.lastPlayerItemStatus = status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay: {
                
                NSUInteger duration = floor(self.playerItem.asset.duration.value * 1.0 / self.playerItem.asset.duration.timescale);
                [self.currentItem updateDuration:duration];
                
                self.state = RBPlayerStatePrepared;
                [self resume];
                break;
            }
            case AVPlayerItemStatusFailed: {
                NSLog(@"%@", self.playerItem.error);
                self.state = RBPlayerStateError;
                break;
            }
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        if (self.view.superview == nil || self.state == RBPlayerStateInit || self.state == RBPlayerStateError) return;
        
        //缓冲进度
        NSArray *loadedTimeRanges = [self.playerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSUInteger bufferedSeconds = startSeconds + durationSeconds;
        
        [self.currentItem updateBufferedSeconds:bufferedSeconds];
        
        if (self.state == RBPlayerStateBuffering) {
            NSUInteger canPlaySeconds = self.currentItem.currentSeconds + self.playInMoreBufferSeconds;
            if (canPlaySeconds > self.currentItem.duration) {
                canPlaySeconds = self.currentItem.duration;
            }
            if (bufferedSeconds >= canPlaySeconds) {
                self.state = RBPlayerStatePlaying;
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(player:updateBufferedSeconds:)]) {
            [self.delegate player:self updateBufferedSeconds:bufferedSeconds];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RBPlayerUpdateBufferedSecondsNotificationName object:self];
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        //播放未完成，但缓冲不足
        self.state = RBPlayerStateBuffering;
    }
}

#pragma mark - Notification

- (void)addNotification {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(playEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //[defaultCenter addObserver:self selector:@selector(jumped:) name:AVPlayerItemTimeJumpedNotification object:nil];
    //[defaultCenter addObserver:self selector:@selector(playbackStalled:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - getters setters

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if ([_playerItem isEqual:playerItem]) return;
    
    if (_playerItem != nil) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        
        [self.avPlayer pause];
        [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
        [self.avPlayer removeTimeObserver:self.timeObserver];
        self.view.containerView.playerLayer.player = nil;
        self.timeObserver = nil;
    }
    _playerItem = playerItem;
    if (_playerItem != nil) {
        self.avPlayer = [[AVPlayer alloc] init];
        self.view.containerView.playerLayer.player = self.avPlayer;
        [self.avPlayer replaceCurrentItemWithPlayerItem:_playerItem];
        [self addTimerObserver];
        
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)setState:(RBPlayerState)state {
    if (_state == state) return;
    if (_state == RBPlayerStateInit && state != RBPlayerStatePrepared) return;
    
    switch (state) {
        case RBPlayerStatePlaying: {
            if ([self.delegate respondsToSelector:@selector(willResumeInPlayer:)]) {
                if (![self.delegate willResumeInPlayer:self]) {
                    return;
                }
            }
            break;
        }
        default:
            break;
    }
    
    _state = state;
    
    switch (_state) {
        case RBPlayerStatePrepared: {
            break;
        }
        case RBPlayerStatePlaying: {
            [self.avPlayer play];
            self.avPlayer.rate = self.rate;
            break;
        }
        case RBPlayerStateBuffering:
        case RBPlayerStatePaused: {
            [self.avPlayer pause];
            break;
        }
        case RBPlayerStateError:
        case RBPlayerStateStoped: {
            if (self.playerItem != nil) {
                [self.avPlayer pause];
                self.playerItem = nil;
            }
            break;
        }
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(player:didStateChanged:)]) {
        [self.delegate player:self didStateChanged:_state];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RBPlayerDidStateChangeNotificationName object:self];
}

- (void)setRate:(float)rate {
    _rate = rate;
    self.avPlayer.rate = rate;
}

- (NSError *)error {
    return self.playerItem.error;
}

- (RBPlayerView *)view {
    if (_view == nil) {
        _view = [[RBPlayerView alloc] initWithPlayer:self];
    }
    return _view;
}

- (UIView *)fullScreenContainerView {
    if (_fullScreenContainerView == nil) {
        _fullScreenContainerView = [[UIView alloc] init];
        _fullScreenContainerView.backgroundColor = [UIColor clearColor];
        _fullScreenContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _fullScreenContainerView;
}

@end

