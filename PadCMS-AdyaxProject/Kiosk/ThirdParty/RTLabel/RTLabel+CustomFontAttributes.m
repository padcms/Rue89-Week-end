//
//  RTLabel+CustomFontAttributes.m
//  Pad CMS
//
//  Created by tar on 25.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RTLabel+CustomFontAttributes.h"
#import "PCFonts.h"

@implementation RTLabel (RTLabel_CustomFontAttributes)

- (CTFontRef)boldFontRefForFontName:(NSString *)fontName size:(CGFloat)fontSize {
    if ([fontName rangeOfString:@"Interstate"].location != NSNotFound) {
        UIFont * font = [UIFont fontWithName:PCFontInterstateBold size:fontSize];
        
        return CFBridgingRetain(font);
    }
    
    return nil;
}

- (CTFontRef)italicFontRefForFontName:(NSString *)fontName size:(CGFloat)fontSize {
    if ([fontName rangeOfString:@"Interstate"].location != NSNotFound) {
        UIFont * font = [UIFont fontWithName:PCFontInterstateItalic size:fontSize];
        
        return CFBridgingRetain(font);
    }
    
    return nil;
}

@end
