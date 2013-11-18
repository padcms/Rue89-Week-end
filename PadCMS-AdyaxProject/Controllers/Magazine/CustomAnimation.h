//
//  CustomAnimation.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/18/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomAnimation : NSObject

- (id) initForView:(UIView*)view duration:(NSTimeInterval)duration finalFrame:(CGRect)toFrame finalTransform:(CGAffineTransform)toTransform;

- (void) performWithCompletion:(void(^)())completion;
- (void) invalidate;

@end
