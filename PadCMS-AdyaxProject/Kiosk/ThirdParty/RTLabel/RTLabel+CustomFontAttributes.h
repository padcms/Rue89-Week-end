//
//  RTLabel+CustomFontAttributes.h
//  Pad CMS
//
//  Created by tar on 25.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTLabel.h"

#ifndef RTLABEL_CUSTOM_FONT_ATTRIBUTES
#define RTLABEL_CUSTOM_FONT_ATTRIBUTES
#endif

@interface RTLabel (RTLabel_CustomFontAttributes)

- (CTFontRef)boldFontRefForFontName:(NSString *)fontName size:(CGFloat)fontSize;
- (CTFontRef)italicFontRefForFontName:(NSString *)fontName size:(CGFloat)fontSize;

@end
