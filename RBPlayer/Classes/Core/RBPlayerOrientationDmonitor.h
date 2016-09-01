//
//  RBPlayerOrientationDmonitor.h
//  Pods
//
//  Created by Ribs on 16/8/23.
//
//

#import <UIKit/UIKit.h>

@interface RBPlayerOrientationDmonitor : NSObject

@property (nonatomic, readonly) UIDeviceOrientation deviceOrientation;
@property (nonatomic) BOOL ignoreScreenSystemLock;

- (instancetype)initWidthUpdateHandler:(void(^)(UIDeviceOrientation deviceOrientation))updateHandler;

- (void)startDmonitor;
- (void)stopDmonitor;

@end
