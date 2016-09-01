//
//  RBPlayerItem.m
//  Pods
//
//  Created by Ribs on 16/8/25.
//
//

#import "RBPlayerItem.h"

@interface RBPlayerItem ()

@property (nonatomic) NSUInteger duration;
@property (nonatomic) NSUInteger currentSeconds;
@property (nonatomic) NSUInteger bufferedSeconds;

@property (nonatomic, strong) RBPlayerItemAsset *playingAsset;

@end

@implementation RBPlayerItem

- (void)updateDuration:(NSUInteger)duration {
    self.duration = duration;
}

- (void)updateCurrentSeconds:(NSUInteger)currentSeconds {
    self.currentSeconds = currentSeconds;
}

- (void)updateBufferedSeconds:(NSUInteger)bufferedSeconds {
    self.bufferedSeconds = bufferedSeconds;
}

- (void)updatePlayingAsset:(RBPlayerItemAsset *)playingAsset {
    self.playingAsset = playingAsset;
}

@end

@implementation RBPlayerItemAsset

- (instancetype)initWithType:(NSString *)type URL:(NSURL *)URL {
    self = [super init];
    if (self) {
        _type = type;
        _URL = URL;
    }
    return self;
}

@end
