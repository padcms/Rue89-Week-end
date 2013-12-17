//
//  RTLabel+Kern.h
//  Pad CMS
//
//  Created by tar on 24.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RTLabel.h"

@interface RTLabel (RTLabel_Kern)

- (NSString *)string:(NSString *)string kernedToValue:(CGFloat)aKernValue;

@end
