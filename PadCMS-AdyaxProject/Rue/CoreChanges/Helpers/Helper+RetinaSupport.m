//
//  Helper+RetinaSupport.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/14/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "Helper.h"
#import <objc/runtime.h>

@implementation Helper (RetinaSupport)

+ (void) load
{
    Method oldGetSize = class_getClassMethod([Helper class], @selector(getSizeForImage:));
    Method newGetSize = class_getClassMethod([Helper class], @selector(getSizeForImageAdvanced:));
    method_exchangeImplementations(oldGetSize, newGetSize);
}

+ (CGSize) getSizeForImageAdvanced:(NSString *) imagePath
{
    CGSize superSize = [Helper getSizeForImageAdvanced:imagePath];
    
    if(CGSizeEqualToSize(superSize, CGSizeZero) == NO)
    {
        float screenScale = [UIScreen mainScreen].scale;
        superSize.width /= screenScale;
        superSize.height /= screenScale;
    }
    
    return superSize;
}

@end
