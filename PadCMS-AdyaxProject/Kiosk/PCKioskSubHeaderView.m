//
//  PCKioskSubHeaderView.m
//  Pad CMS
//
//  Created by tar on 10.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskSubHeaderView.h"
#import "PCFonts.h"

@implementation PCKioskSubHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadContent];
    }
    return self;
}

- (void)loadContent {
    UIImage * backgroundImage = [UIImage imageNamed:@"home_subheader_bg"];
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, backgroundImage.size.height)];
    backgroundImageView.image = backgroundImage;
    [self addSubview:backgroundImageView];
    
    _titleLabel = [[MTLabel alloc] initWithFrame:CGRectMake(37, 6, self.frame.size.width - 10, 30)];
    _titleLabel.font = [UIFont fontWithName:PCFontInterstateLight size:21.5];
    _titleLabel.fontColor = [UIColor whiteColor];
    _titleLabel.text = @"> ARTICLES ARCHIVÉS";
    [self addSubview:_titleLabel];
}

@end
