//
//  RTLabelWithWordWrap.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/8/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RTLabelWithWordWrap.h"

@interface RTLabelWithWordWrap ()
{
    
}
@end

@implementation RTLabelWithWordWrap

- (void)setText:(NSString *)text
{
    text = [text stringByReplacingOccurrencesOfString:@"|" withString:@" "];
    [super setText:text];
    if(self.shouldResizeHeightToFit)
    {
        self.frame = CGRectMake(((int)self.frame.origin.x), ((int)self.frame.origin.y), ((int)self.frame.size.width), ((int)self.optimumSize.height));
    }
}

- (void) applyDefaultParagraphStyleToText:(CFMutableAttributedStringRef)text
{
    int limitOfLines = self.maximumLinesNumber;
    BOOL needResize = self.shouldResizeHeightToFit;
    
    if(limitOfLines)
    {
        if(needResize)
        {
            CFArrayRef frameLines = [self createLinesArrayUnlimitedByHeightFromText:text];
            int linesCount = CFArrayGetCount(frameLines);
            
            if(linesCount > limitOfLines)
            {
                [self setTruncatedLineAtIndex:(limitOfLines - 1) ofLines:frameLines inText:text];
            }
            else
            {
                [self setNoTruncationForText:text];
            }
            
            CFRelease(frameLines);
        }
        else
        {
            BOOL needTruncation;
            
            CFArrayRef frameLines = [self createLinesArrayForCurrentHeightFromText:text allTextIsVisible:&needTruncation];
            
            int linesCount = CFArrayGetCount(frameLines);
            
            if(linesCount <= limitOfLines)
            {
                if(needTruncation)
                {
                    [self setTruncatedLineAtIndex:(linesCount - 1) ofLines:frameLines inText:text];
                }
                else
                {
                    [self setNoTruncationForText:text];
                }
            }
            else
            {
                [self setTruncatedLineAtIndex:limitOfLines - 1 ofLines:frameLines inText:text];
            }
            
            CFRelease(frameLines);
        }
    }
    else
    {
        if(needResize)
        {
            [self setNoTruncationForText:text];
        }
        else
        {
            BOOL needTruncation;
            CFArrayRef frameLines = [self createLinesArrayForCurrentHeightFromText:text allTextIsVisible:&needTruncation];
            
            if(needTruncation)
            {
                int linesCount = CFArrayGetCount(frameLines);
                
                [self setTruncatedLineAtIndex:(linesCount - 1) ofLines:frameLines inText:text];
            }
            else
            {
                [self setNoTruncationForText:text];
            }
            CFRelease(frameLines);
        }
    }
}

- (CFArrayRef) createLinesArrayForCurrentHeightFromText:(CFMutableAttributedStringRef)text allTextIsVisible:(BOOL*)allVisible
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(text);
    
    CGMutablePathRef pathFromBounds = CGPathCreateMutable();
    CGRect bounds = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    CGPathAddRect(pathFromBounds, NULL, bounds);
    
    int textLength = CFAttributedStringGetLength(text);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, textLength), pathFromBounds, NULL);
    CFArrayRef frameLines = CTFrameGetLines(frame);
    
    CFRetain(frameLines);
    
    if(allVisible)
    {
        *allVisible = CTFrameGetVisibleStringRange(frame).length < textLength;
    }
    
    CFRelease(pathFromBounds);
    CFRelease(frame);
    CFRelease(framesetter);
    
    return frameLines;
}

- (CFArrayRef) createLinesArrayUnlimitedByHeightFromText:(CFMutableAttributedStringRef)text
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(text);
    
    CGMutablePathRef maxPath = CGPathCreateMutable();
    CGRect max_bounds = CGRectMake(0.0, 0.0, self.frame.size.width, CGFLOAT_MAX);
    CGPathAddRect(maxPath, NULL, max_bounds);
    
    int textLength = CFAttributedStringGetLength(text);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, textLength), maxPath, NULL);
    CFArrayRef frameLines = CTFrameGetLines(frame);
    
    CFRetain(frameLines);
    
    CFRelease(maxPath);
    CFRelease(frame);
    CFRelease(framesetter);
    
    return frameLines;
}

- (void) setTruncatedLineAtIndex:(int)index ofLines:(CFArrayRef)linesArray inText:(CFMutableAttributedStringRef)text
{
    for (CFIndex i = 0; i < index; i++)
    {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(linesArray, i);
        CFRange lineRange = CTLineGetStringRange(line);
        
        NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithObject:@"wordwrap" forKey:@"linebreakmode"];
        int strPosition = lineRange.location;
        int strLength = lineRange.length;
        
        [self applyParagraphStyleToText:text attributes:attributes atPosition:strPosition withLength:strLength];
    }
    
    CTLineRef lastLine = (CTLineRef)CFArrayGetValueAtIndex(linesArray, index);
    CFRange lineRange = CTLineGetStringRange(lastLine);
    
    NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"truncatingtail", @"linebreakmode", nil];
    int strPosition = lineRange.location;
    int fullLength = CFAttributedStringGetLength(text);
    int strLength = fullLength - strPosition;;
    
    [self applyParagraphStyleToText:text attributes:attributes atPosition:strPosition withLength:strLength];
}

- (void) setNoTruncationForText:(CFMutableAttributedStringRef)text
{
    [self applyParagraphStyleToText:text attributes:nil atPosition:0 withLength:CFAttributedStringGetLength(text)];
}

@end
