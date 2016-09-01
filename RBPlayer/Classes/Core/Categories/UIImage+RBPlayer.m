//
//  UIImage+RBPlayer.m
//  Pods
//
//  Created by Ribs on 16/8/30.
//
//

#import "UIImage+RBPlayer.h"
#import "NSBundle+RBPlayer.h"

@implementation UIImage (RBPlayer)

+ (UIImage *)rbp_imageNamed:(NSString *)name {
    return [self rbp_imageNamed:name inBundle:[NSBundle rbp_bundle]];
}


+ (UIImage *)rbp_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
#elif __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:@"png"]];
#else
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:@"png"]];
    }
#endif
}

@end
