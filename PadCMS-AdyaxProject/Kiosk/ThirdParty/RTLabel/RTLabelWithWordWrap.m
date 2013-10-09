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
    [super setText:text];
    if(self.shouldResizeHeightToFit)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.optimumSize.height);
    }
}


- (void) applyDefaultParagraphStyleToText:(CFMutableAttributedStringRef)text
{
//    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString(text);
//    
//    double width = self.frame.size.width;
//    CFIndex lineStartIndex = 0;
//    
//    CFIndex lineLength = CTTypesetterSuggestLineBreak(typesetter, lineStartIndex, width);
//    
//    NSMutableDictionary* attributes = nil;
//    
//    attributes = [NSMutableDictionary dictionaryWithObject:@"wordwrap" forKey:@"linebreakmode"];
//    
//    [self applyParagraphStyleToText:text attributes:attributes atPosition:lineStartIndex withLength:lineLength];
//    
//    lineStartIndex = lineStartIndex + lineLength;
//    
//    lineLength = CFAttributedStringGetLength(text) - lineStartIndex;
//    
//    attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"truncatingtail", @"linebreakmode", nil];
//    
//    [self applyParagraphStyleToText:text attributes:attributes atPosition:lineStartIndex withLength:lineLength];
//    
//    NSLog(@"sel : %@", text);
//    
//    return;
    
    
    
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(text);
    
    //CTFramesetterSuggestFrameSizeWithConstraints(<#CTFramesetterRef framesetter#>, <#CFRange stringRange#>, <#CFDictionaryRef frameAttributes#>, <#CGSize constraints#>, <#CFRange *fitRange#>)
    
	//CGSize constraint = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
	//CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [self.plainText length]), nil, constraint, nil);
	
    
    int limitOfLines = self.linesNumber;
    BOOL needResize = self.shouldResizeHeightToFit;
    
    BOOL needTruncation = NO;
    
    CFIndex textLength = CFAttributedStringGetLength(text);
    
    if(limitOfLines)
    {
        if(needResize)
        {
            
        }
        else
        {
            
        }
    }
    else
    {
        if(needResize)
        {
            [self applyParagraphStyleToText:text attributes:nil atPosition:0 withLength:textLength];
        }
        else
        {
            CGMutablePathRef pathFromBounds = CGPathCreateMutable();
            CGRect bounds = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
            CGPathAddRect(pathFromBounds, NULL, bounds);
            
            CTFrameRef frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, textLength), pathFromBounds, NULL);
            
            needTruncation = CTFrameGetVisibleStringRange(frame).length < textLength;
            
            if(needTruncation)
            {
                CFArrayRef frameLines = CTFrameGetLines(frame);
                for (CFIndex i = 0;  i< CFArrayGetCount(frameLines); i++)
                {
                    CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(frameLines, i);
                    CFRange lineRange = CTLineGetStringRange(line);
                    
                    NSMutableDictionary* attributes = nil;
                    int strPosition = lineRange.location;
                    int strLength = lineRange.length;
                    
                    if(i == (CFArrayGetCount(frameLines) - 1))
                    {
                        attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"truncatingtail", @"linebreakmode", nil];
                        int fullLength = CFAttributedStringGetLength(text);
                        strLength = fullLength - strPosition;
                    }
                    else
                    {
                        attributes = [NSMutableDictionary dictionaryWithObject:@"wordwrap" forKey:@"linebreakmode"];
                    }
                    
                    [self applyParagraphStyleToText:text attributes:attributes atPosition:strPosition withLength:strLength];
                }
            }
            else
            {
                [self applyParagraphStyleToText:text attributes:nil atPosition:0 withLength:textLength];
            }
            
            CFRelease(pathFromBounds);
            CFRelease(frame);
        }
    }
    
    CFRelease(framesetter);
    
    //NSLog(@"limit : %i\nresize : %@\nneed truncation : %@\ntext : %@", limitOfLines, needResize?@"YES":@"NO", needTruncation?@"YES":@"NO", text);
    
    return;
    
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect bounds = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	CGPathAddRect(path, NULL, bounds);
    
    CGMutablePathRef maxPath = CGPathCreateMutable();
	CGRect max_bounds = CGRectMake(0.0, 0.0, self.frame.size.width, CGFLOAT_MAX);
	CGPathAddRect(maxPath, NULL, max_bounds);
	
    
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, CFAttributedStringGetLength(text)), path, NULL);
	
    CFArrayRef frameLines = CTFrameGetLines(frame);
    for (CFIndex i=0; i<CFArrayGetCount(frameLines); i++)
    {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(frameLines, i);
        CFRange lineRange = CTLineGetStringRange(line);
        
        NSMutableDictionary* attributes = nil;
        int strPosition = lineRange.location;
        int strLength = lineRange.length;
        
//        if(self.lineBreakMode == kCTLineBreakByTruncatingTail)
//        {
            if(i == (CFArrayGetCount(frameLines) - 1))
            {
                attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"truncatingtail", @"linebreakmode", nil];
                int fullLength = CFAttributedStringGetLength(text);
                strLength = fullLength - strPosition;
            }
            else
            {
                attributes = [NSMutableDictionary dictionaryWithObject:@"wordwrap" forKey:@"linebreakmode"];
            }
//        }
        
        [self applyParagraphStyleToText:text attributes:attributes atPosition:strPosition withLength:strLength];
        
    }
//    NSLog(@"sel : %@", text);
}

/*- (void)renderStrikeThroughForFrame:(CTFrameRef)leftFrame context:(CGContextRef)context
{
 
    // get lines
    CFArrayRef leftLines = CTFrameGetLines(leftFrame);
    NSLog(@"count of lines : %i", (int)CFArrayGetCount(leftLines));
    CGPoint *origins = malloc(sizeof(CGPoint)*[(__bridge NSArray *)leftLines count]);
    CTFrameGetLineOrigins(leftFrame,
                          CFRangeMake(0, 0), origins);
    NSInteger lineIndex = 0;
    
    for (id oneLine in (__bridge NSArray *)leftLines)
    {
        
        CTLineRef startLine = (__bridge CTLineRef)(oneLine);
        
        
        if([(__bridge NSArray *)leftLines indexOfObject:oneLine] == [(__bridge NSArray *)leftLines count] - 1)
        {
        
            CFStringRef string = (__bridge CFStringRef)self.plainText;
            CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
            CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), string);
            
            CFRange effectiveRange;
            CFDictionaryRef stringAttrs = CFAttributedStringGetAttributes(attrString, 0, &effectiveRange);
            
            CFAttributedStringRef truncationString = CFAttributedStringCreate(NULL, CFSTR("\u2026"), stringAttrs);
            CTLineRef truncationToken = CTLineCreateWithAttributedString(truncationString);
            CFRelease(truncationString);
            
            // now create the truncated line -- need to grab extra characters from the source string,
            // or else the system will see the line as already fitting within the given width and
            // will not truncate it.
            
            // range to cover everything from the start of lastLine to the end of the string
            CFRange rng = CFRangeMake(CTLineGetStringRange(startLine).location, 0);
            rng.length = CFAttributedStringGetLength(attrString) - rng.location;
            
            // substring with that range
            CFAttributedStringRef longString = CFAttributedStringCreateWithSubstring(NULL, attrString, rng);
            // line for that string
            CTLineRef longLine = CTLineCreateWithAttributedString(longString);
            CFRelease(longString);
            
            CTLineRef truncated = CTLineCreateTruncatedLine(longLine, self.frame.size.width - 50, kCTLineTruncationEnd, truncationToken);
            CFRelease(longLine);
            CFRelease(truncationToken);
            
            // if 'truncated' is NULL, then no truncation was required to fit it
            if (truncated == NULL)
                truncated = (CTLineRef)CFRetain(startLine);
            
            //CTLineRef newLine = CTLineCreateTruncatedLine(startLine, 50, kCTLineTruncationEnd, NULL);
            startLine = truncated;
            
        }
        
        CFArrayRef runs = CTLineGetGlyphRuns(startLine);//(__bridge CTLineRef)oneLine);
        CGRect lineBounds = CTLineGetImageBounds(startLine, context);//(__bridge CTLineRef)oneLine, context);
        
        lineBounds.origin.x += origins[lineIndex].x;
        lineBounds.origin.y += origins[lineIndex].y;
        lineIndex++;
        CGFloat offset = 0;
        
        for (id oneRun in (__bridge NSArray *)runs)
        {
            CGFloat ascent = 0;
            CGFloat descent = 0;
            
            CGFloat width = CTRunGetTypographicBounds((__bridge CTRunRef) oneRun,
                                                      CFRangeMake(0, 0),
                                                      &ascent,
                                                      &descent, NULL);
            
            CFDictionaryRef attrDictionaryRef = CTRunGetAttributes((__bridge CTRunRef) oneRun);
            NSDictionary *attributes = (__bridge NSDictionary *)attrDictionaryRef;
            //NSLog(@"%@", attributes.debugDescription);
            
            BOOL strikeOut = [[attributes objectForKey:(__bridge NSString *)((__bridge CFStringRef)@"CustomStrikeThrough")] boolValue];
            
            if (strikeOut)
            {
                CGRect bounds = CGRectMake(lineBounds.origin.x + offset,
                                           lineBounds.origin.y,
                                           width, ascent + descent);
                
                // don't draw too far to the right
                if (bounds.origin.x + bounds.size.width > CGRectGetMaxX(lineBounds))
                {
                    bounds.size.width = CGRectGetMaxX(lineBounds) - bounds.origin.x;
                }
                
                // get text color or use black
                id color = [attributes objectForKey:(id)kCTForegroundColorAttributeName];
                
                if (color)
                {
                    CGContextSetStrokeColorWithColor(context, (__bridge CGColorRef)color);
                }
                else
                {
                    CGContextSetGrayStrokeColor(context, 0, 1.0);
                }
                
                CGFloat y = roundf(bounds.origin.y + bounds.size.height / 2.0 - 1);
                CGContextMoveToPoint(context, bounds.origin.x, y);
                CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, y);
                
                CGContextStrokePath(context);
            }
            
            offset += width;
        }
    }
    
    // cleanup
    free(origins);
}*/

- (void)applyParagraphStyleToText:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length
{
    //NSLog(@"text : %@ pos : %i length : %i", text, position, length);
	CFMutableDictionaryRef styleDict = ( CFDictionaryCreateMutable( (0), 0, (0), (0) ) );
	
	// direction
	CTWritingDirection direction = kCTWritingDirectionLeftToRight;
	// leading
	CGFloat firstLineIndent = 0.0;
	CGFloat headIndent = 0.0;
	CGFloat tailIndent = 0.0;
	CGFloat lineHeightMultiple = 1.0;
	CGFloat maxLineHeight = 0;
	CGFloat minLineHeight = 0;
	CGFloat paragraphSpacing = 0.0;
	CGFloat paragraphSpacingBefore = 0.0;
	CTTextAlignment textAlignment = (CTTextAlignment)self.textAlignment;
	CTLineBreakMode lineBreakMode = (CTLineBreakMode)self.lineBreakMode;
    //    if(self.plainText.length != position + length)
    //    {
        //lineBreakMode = kCTLineBreakByWordWrapping;
    //    }
	CGFloat lineSpacing = self.lineSpacing;
	
	for (NSUInteger i=0; i<[[attributes allKeys] count]; i++)
	{
		NSString *key = [[attributes allKeys] objectAtIndex:i];
		id value = [attributes objectForKey:key];
		if ([key caseInsensitiveCompare:@"align"] == NSOrderedSame)
		{
			if ([value caseInsensitiveCompare:@"left"] == NSOrderedSame)
			{
				textAlignment = kCTLeftTextAlignment;
			}
			else if ([value caseInsensitiveCompare:@"right"] == NSOrderedSame)
			{
				textAlignment = kCTRightTextAlignment;
			}
			else if ([value caseInsensitiveCompare:@"justify"] == NSOrderedSame)
			{
				textAlignment = kCTJustifiedTextAlignment;
			}
			else if ([value caseInsensitiveCompare:@"center"] == NSOrderedSame)
			{
				textAlignment = kCTCenterTextAlignment;
			}
		}
		else if ([key caseInsensitiveCompare:@"indent"] == NSOrderedSame)
		{
			firstLineIndent = [value floatValue];
		}
		else if ([key caseInsensitiveCompare:@"linebreakmode"] == NSOrderedSame)
		{
			if ([value caseInsensitiveCompare:@"wordwrap"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByWordWrapping;
			}
			else if ([value caseInsensitiveCompare:@"charwrap"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByCharWrapping;
			}
			else if ([value caseInsensitiveCompare:@"clipping"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByClipping;
			}
			else if ([value caseInsensitiveCompare:@"truncatinghead"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByTruncatingHead;
			}
			else if ([value caseInsensitiveCompare:@"truncatingtail"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByTruncatingTail;
			}
			else if ([value caseInsensitiveCompare:@"truncatingmiddle"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByTruncatingMiddle;
			}
		}
	}
	
	CTParagraphStyleSetting theSettings[] =
	{
		{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlignment },
		{ kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode  },
		{ kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(CTWritingDirection), &direction },
		{ kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }, // leading
		{ kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing }, // leading
		{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstLineIndent },
		{ kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headIndent },
		{ kCTParagraphStyleSpecifierTailIndent, sizeof(CGFloat), &tailIndent },
		{ kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(CGFloat), &lineHeightMultiple },
		{ kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight },
		{ kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight },
		{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing },
		{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore }
	};
	
	
	CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, sizeof(theSettings) / sizeof(CTParagraphStyleSetting));
	CFDictionaryAddValue( styleDict, kCTParagraphStyleAttributeName, theParagraphRef );
	
	CFAttributedStringSetAttributes( text, CFRangeMake(position, length), styleDict, 0 );
	CFRelease(theParagraphRef);
    CFRelease(styleDict);
}



@end
