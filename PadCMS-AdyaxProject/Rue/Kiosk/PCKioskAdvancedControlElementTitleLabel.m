//
//  PCKioskAdvancedControlElementTitleLabel.m
//  Pad CMS
//
//  Created by tar on 14.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskAdvancedControlElementTitleLabel.h"
#import <CoreText/CoreText.h>

@interface PCKioskAdvancedControlElementTitleLabel()

@property (nonatomic) CGSize textSize;

@end

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
        
        [string addAttribute:(__bridge NSString *)kCTKernAttributeName
                       value:@(-0.65f)
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
        CGRect textRect = CGRectMake(6, 0, self.bounds.size.width, self.bounds.size.height);
        CGPathAddRect(path, NULL, textRect);
        
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
                //CFIndex glyphCount = CFArrayGetCount(glyphRuns);
                
                for (int i = 0; i < 1; ++i)    {
                    CTRunRef run = CFArrayGetValueAtIndex(glyphRuns, i);
                    
                    NSDictionary *attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
                    
                    if ([attributes objectForKey:@"HighlightText"]){
                        CGRect runBounds;
                        CGFloat ascent, descent;
                        
                        runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL)+14;
                        
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0f) {
                            runBounds.size.height = 36 + (((index == lineCount-1) && (index != 0)) ? -2 : 0) ;
                        } else {
                            runBounds.size.height = roundf(ascent + descent) + ((index == 0) ? 6 : 0);
                        }
                        //roundf(ascent + descent) + ((index == 0) ? 6 : 0);
                        
                        runBounds.origin.x = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                        runBounds.origin.y = roundf(origins[index].y) - 9;/*self.frame.size.height - origins[lineCount - index].y - runBounds.size.height*/;
                        
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
        
        
        CGFloat widthConstraint = textRect.size.width; // Your width constraint, using 500 as an example
        CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                                                                            framesetter,
                                                                            CFRangeMake(0, string.length),
                                                                            NULL, /* Frame attributes */
                                                                            CGSizeMake(widthConstraint, CGFLOAT_MAX), /* Constraints (CGFLOAT_MAX indicates unconstrained) */
                                                                            NULL /* Gives the range of string that fits into the constraints, doesn't matter in your situation */
                                                                            );
        self.textSize = CGSizeMake(ceilf(suggestedSize.width + 20), ceilf(suggestedSize.height + 10));
        //[self performSelector:@selector(sizeToFit) withObject:nil afterDelay:0.0f];
        
        CFRelease(totalFrame);
        CGPathRelease(path);
        CFRelease(framesetter);
    }
}

- (void)setText:(NSString *)text {
    
    text = [text stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
    
    [super setText:text];
    [self setHighlightText:text];
}

- (void)setHighlightText:(NSString *)highlightText {
    _highlightText = highlightText;
    [self setNeedsDisplay];
}

- (void)sizeToFit {
    if ((self.textSize.width > 0) && (self.textSize.height > 0)) {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(self.textSize.width, self.textSize.height);
        self.frame = frame;
    }
}

@end
