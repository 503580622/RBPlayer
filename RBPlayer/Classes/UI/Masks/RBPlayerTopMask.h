//
//  RBPlayerTopMask.h
//  Pods
//
//  Created by Ribs on 16/8/24.
//
//

#import <UIKit/UIKit.h>
#import "RBPlayerViewMask.h"
#import "RBPlayerControlButton.h"

@interface RBPlayerTopMask : RBPlayerViewMask

@property (nonatomic, strong) NSArray<RBPlayerControlButton *> *leftButtons;
@property (nonatomic, strong) NSArray<RBPlayerControlButton *> *rightButtons;

@end
