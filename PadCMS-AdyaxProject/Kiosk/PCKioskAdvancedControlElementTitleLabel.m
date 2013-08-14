//
//  PCKioskAdvancedControlElementTitleLabel.m
//  Pad CMS
//
//  Created by tar on 14.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskAdvancedControlElementTitleLabel.h"
#import <CoreText/CoreText.h>

@implementation PCKioskAdvancedControlElementTitleLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.text) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.text];
        
        CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)[self.font fontName], [self.font pointSize], NULL);
        
        [string addAttribute:(__bridge NSString *)kCTFontAttributeName
                       value:(__bridge id)aFont
                       range:NSMakeRange(0, [string length])];
        
        [string addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName
                       value:(id)[self textColor].CGColor
                       range:NSMakeRange(0, [string length])];
        
        CFRelease(aFont);
        
        // Highlight the text specified..
        if (self.highlightText) {
            
            NSUInteger length = [self.text length];
            NSRange range = NSMakeRange(0, length);
            
            while(range.location != NSNotFound)
            {
                range = [self.text rangeOfString:self.highlightText options:NSCaseInsensitiveSearch range:range];
                if(range.location != NSNotFound) {
                    [string addAttribute:@"HighlightText" value:[UIColor yellowColor] range:NSMakeRange(range.location, [self.highlightText length])];
                    range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                }
            }
        }
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(6, 0, /*self.bounds.size.width*/300 - 6, self.bounds.size.height));
        
        CTFrameRef totalFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // Highlight the text specified..
        if (self.highlightText) {
            
            NSArray* lines = (__bridge NSArray*)CTFrameGetLines(totalFrame);
            CFIndex lineCount = [lines count];
            
            CGPoint origins[lineCount];
            CTFrameGetLineOrigins(totalFrame, CFRangeMake(0, 0), origins);
            
            for(CFIndex index = 0; index < lineCount; index++)
            {
                CTLineRef line = CFArrayGetValueAtIndex((CFArrayRef)lines, index);
                
                CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
                CFIndex glyphCount = CFArrayGetCount(glyphRuns);
                
                for (int i = 0; i < glyphCount; ++i)    {
                    CTRunRef run = CFArrayGetValueAtIndex(glyphRuns, i);
                    
                    NSDictionary *attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
                    
                    if ([attributes objectForKey:@"HighlightText"]){
                        CGRect runBounds;
                        CGFloat ascent, descent;
                        
                        runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL) + 7;
                        runBounds.size.height = ascent + descent;
                        
                        runBounds.origin.x = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                        runBounds.origin.y = origins[index].y - 7;/*self.frame.size.height - origins[lineCount - index].y - runBounds.size.height*/;
                        
                        CGColorRef highlightColor = (_highlightColor) ? _highlightColor.CGColor : [UIColor yellowColor].CGColor;
                        CGContextSetFillColorWithColor(context, highlightColor);
                        CGContextSetStrokeColorWithColor(context, highlightColor);
                        CGContextStrokePath(context);
                        CGContextFillRect(context, runBounds);
                    }
                }
            }
        }
        
        CTFrameDraw(totalFrame, context);
        
        CFRelease(totalFrame);
        CGPathRelease(path);
        CFRelease(framesetter);
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setHighlightText:text];
}

- (void)setHighlightText:(NSString *)highlightText {
    _highlightText = highlightText;
    [self setNeedsDisplay];
}

@end
