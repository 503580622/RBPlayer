//
//  RBPlayerControlButton.h
//  Pods
//
//  Created by 黄泽新 on 16/8/25.
//
//

#import <UIKit/UIKit.h>

#import "RBPlayerViewMask.h"

@protocol RBPlayerControlButtonProtocol <NSObject>

- (void)reload;
- (void)main;

@optional

- (void)playerDidChangedState;
- (void)playerViewWillChangeOrientation:(UIInterfaceOrientation)orientation fromOrientation:(UIInterfaceOrientation)fromOrientation;

@end


@interface RBPlayerControlButton : NSObject <RBPlayerControlButtonProtocol>

@property (nonatomic, weak, readonly) RBPlayerViewMask *currentMask;
@property (nonatomic, strong, readonly) UIButton *button;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithMask:(RBPlayerViewMask *)mask;
- (instancetype)initWithMask:(RBPlayerViewMask *)mask mainBlock:(void(^)())mainBlock;

@end
