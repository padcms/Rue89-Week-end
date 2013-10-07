//
//  PCKioskControlElementDetailsView.m
//  Pad CMS
//
//  Created by tar on 20.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskControlElementDetailsView.h"
#import "PCKioskShelfSettings.h"
#import "PCFonts.h"
#import "PCRevision.h"
#import "PCIssue.h"
#import "UIView+EasyFrame.h"

@interface PCKioskControlElementDetailsView ()

@property (nonatomic, strong) RTLabel * excerptLabel;
@property (nonatomic, strong) UILabel * autorsLabel;
@property (nonatomic, strong) UILabel * numberOfWordsLabel;

@end

@implementation PCKioskControlElementDetailsView

static const CGFloat padding_left = 10.0f;
static const CGFloat padding_top = 12.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    CGRect excerptRect = CGRectMake(padding_left, self.frameHeight - padding_left, 380, 0);
    self.excerptLabel = [[RTLabel alloc] initWithFrame:excerptRect];
    self.excerptLabel.font = [UIFont fontWithName:PCFontInterstateRegular size:15.0f];
    self.excerptLabel.textColor = UIColorFromRGB(0x34495e);
    self.excerptLabel.lineSpacing = 1.25;
    [self addSubview:self.excerptLabel];
    
    
    //[self setExcerptString:@"<font kern=-0.5>De passage à Paris, le président islandais nous a raconté comment son pays avait vaincu la crise, et il nous a glissé quelques conseils valables pour la France au passage.</font>"];
    //self.descriptionTextView.text = @"De passage à Paris, le président islandais nous a raconté comment son pays avait vaincu la crise, et il nous a glissé quelques conseils valables pour la France au passage.";
    
    //[self fixTextViewKerning];
    
    
    CGFloat authorsWidth = 130.0f;
    
    CGRect authorsLabelRect = CGRectMake(self.frame.size.width - authorsWidth, excerptRect.origin.y, authorsWidth, 50);
    self.autorsLabel = [[UILabel alloc] initWithFrame:authorsLabelRect];
    self.autorsLabel.text = @"Par Jean-Patrick\nAntoine Trèslongnom";
    //self.autorsLabel.backgroundColor = [UIColor cyanColor];
    self.autorsLabel.font = [UIFont fontWithName:PCFontInterstateBold size:11.0f];
    self.autorsLabel.textColor = UIColorFromRGB(0x34495e);
    [self addSubview:self.autorsLabel];
    [self.autorsLabel setNumberOfLines:2];
    [self.autorsLabel sizeToFit];
    authorsLabelRect = self.autorsLabel.frame;
    
    self.numberOfWordsLabel = [[UILabel alloc] initWithFrame:[self wordsLabelRectForAuthorsRect:authorsLabelRect]];
    //self.numberOfWordsLabel.backgroundColor = [UIColor greenColor];
    self.numberOfWordsLabel.font = [UIFont fontWithName:PCFontInterstateLight size:11.0f];
    self.numberOfWordsLabel.textColor = UIColorFromRGB(0x34495e);
    [self addSubview:self.numberOfWordsLabel];
    
    self.numberOfWordsLabel.text = @"1 500 mots";
    [self.numberOfWordsLabel sizeToFit];
    
    self.numberOfWordsLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.autorsLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.excerptLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.autoresizesSubviews = YES;
    self.clipsToBounds = YES;
}

- (CGRect)wordsLabelRectForAuthorsRect:(CGRect)authorsLabelRect {
    return CGRectMake(authorsLabelRect.origin.x, CGRectGetMaxY(authorsLabelRect), authorsLabelRect.size.width, 30);
}

/*//- (void)fixTextViewKerning {
//    NSString *css = @"*{text-rendering: optimizeLegibility; line-height:125%; letter-spacing:-0.5px;}";
//    NSString * text = self.descriptionTextView.text;
//    NSString *html = [NSString stringWithFormat:@"<html><head><style>%@</style></head><body>%@</body></html>", css, text];
//    @try {
//        SEL setContentToHTMLString = NSSelectorFromString([@[@"set", @"Content", @"To", @"HTML", @"String", @":"] componentsJoinedByString:@""]);
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//        [self.descriptionTextView performSelector:setContentToHTMLString withObject:html];
//#pragma clang diagnostic pop
//    }
//    @catch (NSException *exception) {
//        // html+css could not be applied to text view, so no kerning
//    }
//}*/

/*- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.autorsLabel sizeToFit];
    CGRect authorsLabelRect = self.autorsLabel.frame;
    
    CGSize textSize = [[self.autorsLabel text] sizeWithFont:[self.autorsLabel font] constrainedToSize:CGSizeMake(120, 9999) lineBreakMode:UILineBreakModeWordWrap];
    authorsLabelRect.size = textSize;
    self.autorsLabel.frame = authorsLabelRect;
    
    self.numberOfWordsLabel.frame = [self wordsLabelRectForAuthorsRect:authorsLabelRect];
    
    [self.numberOfWordsLabel sizeToFit];
}*/

- (void)setExcerptString:(NSString *)excerptString
{
    CGSize excerptTextSize = {0, 0};;
    
    if (excerptString)
    {
        excerptTextSize = [stringWithoutTagsFromString(excerptString) sizeWithFont:self.excerptLabel.font constrainedToSize:CGSizeMake(self.excerptLabel.frameWidth, 9999) lineBreakMode:self.excerptLabel.lineBreakMode];
        excerptString = [[@"<font kern=-0.5>" stringByAppendingString:excerptString] stringByAppendingString:@"</font>"];
        self.excerptLabel.text = excerptString;
    }
    excerptTextSize.height += 6;
    self.excerptLabel.frameHeight = excerptTextSize.height;
}

- (void) setupForRevision:(PCRevision*)revision
{
    NSString * excerptString = revision.issue.excerpt;
    NSString * authors = revision.issue.author;
    NSInteger wordsCount = revision.issue.wordsCount;
    
    [self setAuthorsString:authors];
    [self setNumberOfWords:wordsCount];
    [self setExcerptString:excerptString];
    
    CGRect authorsLabelRect = self.autorsLabel.frame;
    CGSize textSize = [[self.autorsLabel text] sizeWithFont:[self.autorsLabel font] constrainedToSize:CGSizeMake(120, 9999) lineBreakMode:UILineBreakModeWordWrap];
    authorsLabelRect.size = textSize;
    self.autorsLabel.frame = authorsLabelRect;
    self.numberOfWordsLabel.frame = [self wordsLabelRectForAuthorsRect:authorsLabelRect];
    [self.numberOfWordsLabel sizeToFit];
    
    float minHeight = self.numberOfWordsLabel.frameHeight + self.autorsLabel.frameHeight + padding_top + padding_left;
    _openedHeight = self.excerptLabel.frameHeight + padding_top + padding_left;
    if(_openedHeight < minHeight)
    {
        _openedHeight = minHeight;
    }
    
    self.autorsLabel.frameY = self.excerptLabel.frameY = self.frameHeight - _openedHeight + padding_top;
    self.numberOfWordsLabel.frameY = self.autorsLabel.frameY + self.autorsLabel.frameHeight;
}

- (void)setAuthorsString:(NSString *)authorsString {
    self.autorsLabel.text = authorsString;
}

- (void)setNumberOfWords:(NSInteger)numberOfWords {
    
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@" "];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];
    NSString * numberString = [formatter stringFromNumber:[NSNumber numberWithInt:numberOfWords]];
    
    self.numberOfWordsLabel.text = [NSString stringWithFormat:@"%@ %@", numberString, (numberOfWords > 1) ? @"mots" : @"mot"];
    
}

NSString* stringWithoutTagsFromString(NSString* str)
{
    NSRange firstTagOpenRange = [str rangeOfString:@"<"];
    NSRange firstTagCloseRange = [str rangeOfString:@">"];
    if(firstTagOpenRange.location != NSNotFound && firstTagCloseRange.location != NSNotFound)
    {
        NSRange tagRange = {firstTagOpenRange.location, firstTagCloseRange.location - firstTagOpenRange.location + 1};
        NSString* newStr = [str stringByReplacingCharactersInRange:tagRange withString:@""];
        return stringWithoutTagsFromString(newStr);
    }
    else
    {
        return str;
    }
}

@end
