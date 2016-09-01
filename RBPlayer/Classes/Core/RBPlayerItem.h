//
//  RBPlayerItem.h
//  Pods
//
//  Created by Ribs on 16/8/25.
//
//

#import <Foundation/Foundation.h>

@interface RBPlayerItemAsset : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSURL *URL;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(NSString *)type URL:(NSURL *)URL;

@end


@interface RBPlayerItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *assetTitle;

@property (nonatomic, readonly) NSUInteger duration;
@property (nonatomic, readonly) NSUInteger currentSeconds;
@property (nonatomic, readonly) NSUInteger bufferedSeconds;

@property (nonatomic, strong, readonly) RBPlayerItemAsset *playingAsset;
@property (nonatomic, strong) NSArray<RBPlayerItemAsset *> *assets;

@end