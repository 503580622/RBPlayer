//
//  RBPlayerChangeOrientationOperation.h
//  Pods
//
//  Created by Ribs on 16/8/23.
//
//

#import <Foundation/Foundation.h>

typedef void(^RBPlayerChangeOrientationOperationCompletionHandler)();

@interface RBPlayerChangeOrientationOperation : NSOperation

+ (instancetype)blockOperationWithBlock:(void (^)(RBPlayerChangeOrientationOperationCompletionHandler completionHandler))block;

@end
