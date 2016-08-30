//
//  NSBundle+RBPlayer.m
//  Pods
//
//  Created by 黄泽新 on 16/8/30.
//
//

#import "NSBundle+RBPlayer.h"
#import "RBCorePlayer.h"

@implementation NSBundle (RBPlayer)

+ (NSBundle *)rbp_bundle {
    return [self bundleWithURL:[self rbp_bundleURL]];
}

+ (NSURL *)rbp_bundleURL {
    NSBundle *bundle = [NSBundle bundleForClass:[RBCorePlayer class]];
    return [bundle URLForResource:@"RBPlayer" withExtension:@"bundle"];
}

@end
