//
//  PCRevisionSummaryCell.m
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevisionSummaryCell.h"

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

@end
