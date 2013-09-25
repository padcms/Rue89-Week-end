//
//  RTLabel+Kern.m
//  Pad CMS
//
//  Created by tar on 24.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RTLabel+Kern.h"

@implementation RTLabel (RTLabel_Kern)

- (NSString *)string:(NSString *)string kernedToValue:(CGFloat)aKernValue {
    
    NSString * kernedString = nil;
    
    if (string) {
        NSString * kernTag =@"font";
        NSString * kernOpenTag = [NSString stringWithFormat:@"<%@ kern=%f>", kernTag, aKernValue];
        NSString * kernCloseTag = [NSString stringWithFormat:@"</%@>", kernTag];
        
        kernedString = [[kernOpenTag stringByAppendingString:string] stringByAppendingString:kernCloseTag];
        
    }

    return kernedString;
    
}

@end
