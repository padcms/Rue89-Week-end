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

@implementation PCKioskControlElementDetailsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat paddingLeft = 5.0f;
    CGFloat paddingTop = 6.0f;
    
    CGRect textViewRect = CGRectMake(paddingLeft, paddingTop, 385, self.frame.size.height - paddingLeft*2);
    self.descriptionTextView = [[UITextView alloc] initWithFrame:textViewRect];
    //self.descriptionTextView.backgroundColor = [UIColor orangeColor];
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.font = [UIFont fontWithName:PCFontInterstateRegular size:15.0f];
    self.descriptionTextView.textColor = UIColorFromRGB(0x34495e);
    [self.descriptionTextView setHidden:YES];
    [self addSubview:self.descriptionTextView];
    
    self.descriptionTextView.text = @"De passage à Paris, le président islandais nous a raconté comment son pays avait vaincu la crise, et il nous a glissé quelques conseils valables pour la France au passage.";
    
    [self fixTextViewKerning];
    
    
    CGFloat textViewInset = 8.0f;
    CGFloat authorsWidth = 130.0f;
    
    CGRect autorsLabelRect = CGRectMake(self.frame.size.width - authorsWidth, textViewRect.origin.y + textViewInset, authorsWidth, 50);
    self.autorsLabel = [[UILabel alloc] initWithFrame:autorsLabelRect];
    self.autorsLabel.text = @"Par Jean-Patrick\nAntoine Trèslongnom";
    //self.autorsLabel.backgroundColor = [UIColor cyanColor];
    self.autorsLabel.font = [UIFont fontWithName:PCFontInterstateBold size:11.0f];
    self.autorsLabel.textColor = UIColorFromRGB(0x34495e);
    [self addSubview:self.autorsLabel];
    [self.autorsLabel setNumberOfLines:2];
    [self.autorsLabel sizeToFit];
    autorsLabelRect = self.autorsLabel.frame;
    
    self.numberOfWordsLabel = [[UILabel alloc] initWithFrame:CGRectMake(autorsLabelRect.origin.x, CGRectGetMaxY(autorsLabelRect), autorsLabelRect.size.width, 30)];
    //self.numberOfWordsLabel.backgroundColor = [UIColor greenColor];
    self.numberOfWordsLabel.font = [UIFont fontWithName:PCFontInterstateLight size:11.0f];
    self.numberOfWordsLabel.textColor = UIColorFromRGB(0x34495e);
    [self addSubview:self.numberOfWordsLabel];
    
    self.numberOfWordsLabel.text = @"1 500 mots";
    [self.numberOfWordsLabel sizeToFit];
}

- (void)fixTextViewKerning {
    NSString *css = @"*{text-rendering: optimizeLegibility; line-height:125%; letter-spacing:-0.5px;}";
    NSString * text = self.descriptionTextView.text;
    NSString *html = [NSString stringWithFormat:@"<html><head><style>%@</style></head><body>%@</body></html>", css, text];
    @try {
        SEL setContentToHTMLString = NSSelectorFromString([@[@"set", @"Content", @"To", @"HTML", @"String", @":"] componentsJoinedByString:@""]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.descriptionTextView performSelector:setContentToHTMLString withObject:html];
#pragma clang diagnostic pop
    }
    @catch (NSException *exception) {
        // html+css could not be applied to text view, so no kerning
    }
}

@end
