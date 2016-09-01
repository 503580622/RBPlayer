//
//  RBPlayerControlRateButton.m
//  Pods
//
//  Created by Ribs on 16/8/25.
//
//

#import "RBPlayerControlRateButton.h"
#import "RBVideoPlayer.h"

@interface RBPlayerControlRateButton ()

@end

@implementation RBPlayerControlRateButton

- (instancetype)initWithMask:(RBPlayerViewMask *)mask {
    self = [super initWithMask:mask];
    if (self) {
        self.rates = @[@(1), @(1.2), @(1.5), @(2)];
        self.button.hidden = YES;
        [self setButtonTitleWithRate:1];
    }
    return self;
}

- (void)reload {
    self.button.hidden = !self.currentMask.currentPlayerView.isFullScreen;
    [self setButtonTitleWithRate:self.currentMask.currentPlayerView.currentPlayer.rate];
}

- (void)main {
    if ([self.rates count] > 0) {
        __block float nextRate = [[self.rates firstObject] floatValue];
        [self.rates enumerateObjectsUsingBlock:^(NSNumber *rate, NSUInteger idx, BOOL *stop) {
            if ([rate doubleValue] > self.currentMask.currentPlayerView.currentPlayer.rate) {
                nextRate = [rate doubleValue];
                *stop = YES;
            }
        }];
        if (nextRate != self.currentMask.currentPlayerView.currentPlayer.rate) {
            self.currentMask.currentPlayerView.currentPlayer.rate = nextRate;
            [self setButtonTitleWithRate:nextRate];
        }
    }
}

- (void)setButtonTitleWithRate:(float)rate {
    NSString *rateString = [NSString stringWithFormat:@"%.1fX", rate];
    if ([rateString hasSuffix:@".0X"]) {
        rateString = [NSString stringWithFormat:@"%ldX", (long)rate];
    }
    [self.button setTitle:rateString forState:UIControlStateNormal];
}

- (void)playerViewWillChangeOrientation:(UIInterfaceOrientation)orientation fromOrientation:(UIInterfaceOrientation)fromOrientation {
    self.button.hidden = orientation == UIInterfaceOrientationUnknown;
}

@end
