//
//  PCKioskAdvancedControlElementDateLabel.m
//  Pad CMS
//
//  Created by tar on 30.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskAdvancedControlElementDateLabel.h"
#import "PCFonts.h"

@implementation PCKioskAdvancedControlElementDateLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setText:@"11\nDEC\n2013"];
        [self setFont:[UIFont fontWithName:PCFontInterstateRegular size:21.5f]];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFontColor:UIColorFromRGB(0x91b4d7)];
        [self setLineHeight:18];
        [self setResizeToFitText:YES];
        [self setCharacterSpacing:-1.0f];
        [self setNumberOfLines:3];
        [self sizeToFit];
    }
    return self;
}

- (NSString *)monthStringForMonth:(NSInteger)month {
    switch (month) {
        case 1:  return @"JAN"; break;
        case 2:  return @"FÉV"; break;
        case 3:  return @"MAR"; break;
        case 4:  return @"AVR"; break;
        case 5:  return @"MAI"; break;
        case 6:  return @"JUIN"; break;
        case 7:  return @"JUIL"; break;
        case 8:  return @"AOÛ"; break;
        case 9:  return @"SEP"; break;
        case 10:  return @"OCT"; break;
        case 11:  return @"NOV"; break;
        case 12:  return @"DÉC"; break;
        default:
            break;
    }
    
    return @"";
}

- (void)setDate:(NSDate *)date {
    _date = date;
    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd"];
    NSString * dayString = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * yearString = [dateFormatter stringFromDate:date];
    
    [dateFormatter setDateFormat:@"M"];
    NSString * monthString = [dateFormatter stringFromDate:date];
    NSInteger month = monthString.integerValue;
    
    NSString * convertedMonth = [self monthStringForMonth:month];
    
    NSString * dateStringWithMonth = [NSString stringWithFormat:@"%@\n%@\n%@", dayString, convertedMonth, yearString];
    
    self.text = dateStringWithMonth;
    
    [self sizeToFit];
    
}

@end
