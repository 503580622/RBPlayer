//
//  RBPlayerSlider.h
//  Pods
//
//  Created by Ribs on 16/8/22.
//
//

#import <UIKit/UIKit.h>

@interface RBPlayerSlider : UIControl

@property(nonatomic) float value;
@property(nonatomic) float loadedValue;
@property(nonatomic) float maximumValue;

@property(nonatomic, strong) UIColor *maximumTrackTintColor;
@property(nonatomic, strong) UIColor *loadedTrackTintColor;
@property(nonatomic, strong) UIColor *tintColor;
@property(nonatomic, strong) UIColor *thumbTintColor;

@property(nonatomic) CGFloat thumbSize;
@property(nonatomic) CGFloat trackSize;

@property(nonatomic,getter=isContinuous) BOOL continuous;

- (void)setValue:(float)value animated:(BOOL)animated;

@end
