//
//  PCKioskTitledPopupView.m
//  Pad CMS
//
//  Created by tar on 04.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskTitledPopupView.h"

@implementation PCKioskTitledPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)loadContent {
    [super loadContent];
    
    [self initTitle];
    [self initDescription];
}

- (void)initTitle {
    CGRect contentFrame = self.contentView.frame;
    self.titleLabel = [[MTLabel alloc] initWithFrame:CGRectMake( 0, 20, contentFrame.size.width, 50)];
    self.titleLabel.text = @"Title";
    self.titleLabel.font = [UIFont fontWithName:PCFontLeckerliOne size:40];
    self.titleLabel.textAlignment = MTLabelTextAlignmentCenter;
    [self.titleLabel setCharacterSpacing:-0.8f];
    [self.titleLabel setFontColor:UIColorFromRGB(0x34495e)];
    [self.contentView addSubview:self.titleLabel];
}

- (void)initDescription {
    CGRect contentFrame = self.contentView.frame;
    self.descriptionLabel = [[RTLabel alloc] initWithFrame:CGRectMake(0, 90, contentFrame.size.width, 50)];
    self.descriptionLabel.text = @"Description";
    self.descriptionLabel.font = [UIFont fontWithName:PCFontInterstateRegular size:15];
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    [self.descriptionLabel setKernValue:-0.5f];
    self.descriptionLabel.textColor = UIColorFromRGB(0x34495e);
    [self.contentView addSubview:self.descriptionLabel];
}


@end
