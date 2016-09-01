//
//  RBPlayerMenuMask.h
//  Pods
//
//  Created by Ribs on 16/8/25.
//
//

#import <UIKit/UIKit.h>
#import "RBPlayerViewMask.h"

@interface RBPlayerMenuMask : RBPlayerViewMask

@property (nonatomic) CGFloat menuWidth;
@property (nonatomic) CGFloat menuItemHeight;
@property (nonatomic) CGPoint menuPosition;

@property (nonatomic, strong) NSArray<NSString *> *items;

@property (nonatomic) NSInteger selectedIndex;

- (void)selectedIndexDidChanged;

@end
