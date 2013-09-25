//
//  PCRevisionSummaryCell.m
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevisionSummaryCell.h"
#import "PCFonts.h"

@implementation PCRevisionSummaryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadCell];
    }
    return self;
}

- (void)loadCell {
    [self initSeparators];
    
    [self initTitle];
    [self initDescription];
}

- (void)initSeparators {
    UIImage * leftSeparatorImage = [[UIImage imageNamed:@"summary_separator_left"] stretchableImageWithLeftCapWidth:0 topCapHeight:40];
    UIImage * rightSeparatorImage = [[UIImage imageNamed:@"summary_separator_right"] stretchableImageWithLeftCapWidth:0 topCapHeight:40];
    
    CGFloat separatorPadding = 5.0f;
    
    UIImageView * leftSeparatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(separatorPadding, separatorPadding, leftSeparatorImage.size.width, self.frame.size.height - separatorPadding * 2)];
    leftSeparatorImageView.image = leftSeparatorImage;
    [self addSubview:leftSeparatorImageView];
    
    UIImageView * rightSeparatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - separatorPadding - rightSeparatorImage.size.width, separatorPadding, rightSeparatorImage.size.width, self.frame.size.height - separatorPadding * 2)];
    rightSeparatorImageView.image = rightSeparatorImage;
    [self addSubview:rightSeparatorImageView];
}


const CGFloat kLabelPadding = 30.0f;

- (void)initTitle {
    CGRect contentFrame = self.frame;
    self.titleLabel = [[MTLabel alloc] initWithFrame:CGRectMake(kLabelPadding, 30, contentFrame.size.width - kLabelPadding*2, 1)];
    [self.titleLabel setResizeToFitText:YES];
    self.titleLabel.text = @"Title long long title test";
    self.titleLabel.font = [UIFont fontWithName:PCFontInterstateLight size:26.5];
    self.titleLabel.textAlignment = MTLabelTextAlignmentCenter;
    [self.titleLabel setCharacterSpacing:-1.15f];
    [self.titleLabel setFontColor:UIColorFromRGB(0x34495e)];
    [self addSubview:self.titleLabel];
}

- (void)initDescription {
    CGRect contentFrame = self.frame;
    self.descriptionLabel = [[MTLabel alloc] initWithFrame:CGRectMake(kLabelPadding, 90, contentFrame.size.width - kLabelPadding*2, 1)];
    [self.descriptionLabel setResizeToFitText:YES];
    self.descriptionLabel.text = @"Description";
    self.descriptionLabel.font = [UIFont fontWithName:PCFontInterstateLight size:15];
    self.descriptionLabel.textAlignment = MTLabelTextAlignmentCenter;
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    [self.descriptionLabel setCharacterSpacing:-0.5f];
    self.descriptionLabel.fontColor = UIColorFromRGB(0x969696);
    self.descriptionLabel.contentMode = UIViewContentModeRedraw;
    self.descriptionLabel.delegate = self;
    [self addSubview:self.descriptionLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutLabels];
}

- (void)layoutLabels {
    self.titleLabel.center = CGPointMake(self.descriptionLabel.center.x, 50);
    self.descriptionLabel.center = CGPointMake(self.descriptionLabel.center.x, 110);
}

- (void)label:(MTLabel *)label didChangeFrame:(CGRect)frame {
    [label setNeedsDisplay];
}

@end
