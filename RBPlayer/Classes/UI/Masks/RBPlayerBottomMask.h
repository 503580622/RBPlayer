//
//  RBPlayerBottomMask.h
//  Pods
//
//  Created by 黄泽新 on 16/8/22.
//
//

#import <UIKit/UIKit.h>
#import "RBPlayerViewMask.h"
#import "RBPlayerSlider.h"
#import "RBPlayerControlButton.h"

@interface RBPlayerBottomMask : RBPlayerViewMask

@property (nonatomic, strong, readonly) RBPlayerSlider *timeSlider;

@property (nonatomic, strong) NSArray<RBPlayerControlButton *> *leftButtons;
@property (nonatomic, strong) NSArray<RBPlayerControlButton *> *rightButtons;

@end
