//
//  RBCorePlayer.h
//  Pods
//
//  Created by Ribs on 16/8/22.
//
//

#import <Foundation/Foundation.h>
#import "RBPlayerItem.h"
#import "RBPlayerView.h"

@class RBCorePlayer;

extern NSString *const RBPlayerPlayItemAssetNotificationName;
extern NSString *const RBPlayerDidPlayToEndNotificationName;
extern NSString *const RBPlayerDidStateChangeNotificationName;
extern NSString *const RBPlayerUpdateCurrentSecondsNotificationName;
extern NSString *const RBPlayerUpdateBufferedSecondsNotificationName;

typedef NS_ENUM(int, RBPlayerState) {
    RBPlayerStateInit,
    RBPlayerStatePrepared,
    RBPlayerStatePlaying,
    RBPlayerStateBuffering,
    RBPlayerStatePaused,
    RBPlayerStateStoped,
    RBPlayerStateError
};

@protocol RBPlayerDelegate <NSObject>

@optional

- (BOOL)player:(RBCorePlayer *)player willPlayItemAsset:(RBPlayerItemAsset *)itemAsset originalItemAsset:(RBPlayerItemAsset *)originalItemAsset;
- (BOOL)willResumeInPlayer:(RBCorePlayer *)player;
- (void)didPlayToEndInPlayer:(RBCorePlayer *)player;

- (BOOL)player:(RBCorePlayer *)player willSeekToSeconds:(NSUInteger)bufferingSeconds;

- (void)player:(RBCorePlayer *)player didStateChanged:(RBPlayerState)state;

- (void)player:(RBCorePlayer *)player updateCurrentSeconds:(NSUInteger)currentSeconds;
- (void)player:(RBCorePlayer *)player updateBufferedSeconds:(NSUInteger)bufferingSeconds;

@end

@interface RBCorePlayer : NSObject

@property (nonatomic, weak) id<RBPlayerDelegate> delegate;

@property (nonatomic, strong, readonly) RBPlayerItem *currentItem;
@property (nonatomic, strong, readonly) RBPlayerView *view;
@property (nonatomic, strong, readonly) UIView *fullScreenContainerView;

@property (nonatomic, strong, readonly) NSError *error;

@property (nonatomic) float rate;
@property (nonatomic) NSUInteger playInMoreBufferSeconds;

@property (nonatomic, readonly) RBPlayerState state;

- (void)replaceCurrentItemWithPlayerItem:(RBPlayerItem *)playerItem;

- (void)playWithItemAsset:(RBPlayerItemAsset *)itemAsset;
- (void)playWithURL:(NSURL *)URL;

- (void)resumeOrPause;
- (void)resume;
- (void)pause;
- (void)stop;

- (void)seekToSeconds:(NSUInteger)seconds;
- (void)seekToSeconds:(NSUInteger)seconds completionHandler:(void (^)(BOOL finished))completionHandler;

@end

