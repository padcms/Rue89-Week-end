//
//  UIView+Log.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 9/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "objc/runtime.h"

@implementation UIView (Log)

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"View touch down : %@", NSStringFromClass(self.class));
    [super touchesBegan:touches withEvent:event];
}

@end

@implementation UIButton (Log)

+ (void) load
{
    Method prevMethod = class_getInstanceMethod([UIButton class], @selector(initWithCoder:));
    Method newMethod = class_getInstanceMethod([UIButton class], @selector(initCoder:));
    
    Method prevMethod2 = class_getInstanceMethod([UIButton class], @selector(initFrame:));
    Method newMethod2 = class_getInstanceMethod([UIButton class], @selector(initWithFrame:));
    
    method_exchangeImplementations(prevMethod, newMethod);
    method_exchangeImplementations(prevMethod2, newMethod2);
}

- (id) initCoder:(NSCoder *)aDecoder
{
    self = [self initCoder:aDecoder];
    [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    return self;
}

- (id) initFrame:(CGRect)frame
{
    self = [self initFrame:frame];
    [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    return self;
}

- (void) touchDown
{
    NSMutableString* logString = [NSMutableString stringWithFormat:@"%@ touch down in view : %@", NSStringFromClass(self.class), NSStringFromClass(self.superview.class)];
    
    UIView* superView = self.superview;
    
    while (superView.superview != nil)
    {
        [logString appendFormat:@" -> %@", NSStringFromClass(superView.superview.class)];
        superView = superView.superview;
    }
    
    NSLog(@"%@", logString);
}

@end