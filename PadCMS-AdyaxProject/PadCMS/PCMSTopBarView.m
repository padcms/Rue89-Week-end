//
//  PCMSTopBarView.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 6/12/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCMSTopBarView.h"

#define TopBarBackgroundImage @"top-bar-background.png"
#define TopBarTitleImage @"top-bar-title-background-image.png"
#define ButtonBackground @"top-bar-button-background.png"
#define ApplicationsButtonImage @"top-bar-apps-icon.png"
#define AccountButtonImage @"top-bar-account-icon.png"
#define ContactUsButtonImage @"top-bar-mail-icon.png"
#define InformationButtonImage @"top-bar-info-icon.png"

@interface PCMSTopBarView ()
{
    UIImageView *_backgroundImageView;
    UIImageView *_titleBackgroundImageView;
    UILabel *_accountLabel;
    UILabel *_titleLabel;
}

- (void)initialize;
- (void)deinitialize;

@end

@implementation PCMSTopBarView

- (void)initialize
{
    _backgroundImageView = [[UIImageView alloc] init];
    
    UIImage *topBarBackgroundImage = [UIImage imageNamed:TopBarBackgroundImage];
    _backgroundImageView.image = topBarBackgroundImage;
    _backgroundImageView.contentMode = UIViewContentModeTop;
//    _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:_backgroundImageView];
    
    _titleBackgroundImageView = [[UIImageView alloc] init];
    UIImage *image = [UIImage imageNamed:TopBarTitleImage];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10); 
    _titleBackgroundImageView.image = [image resizableImageWithCapInsets:edgeInsets];
    _titleBackgroundImageView.contentMode = UIViewContentModeTop;
    [self addSubview:_titleBackgroundImageView];
    
    _accountLabel = [[UILabel alloc] init];
    _accountLabel.backgroundColor = [UIColor clearColor];
    _accountLabel.textColor = [UIColor whiteColor];
    _accountLabel.textAlignment = UITextAlignmentCenter;
//    _accountLabel.text = @"<AccountName>";
//    [self addSubview:_accountLabel];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = UITextAlignmentCenter;
//    _titleLabel.text = @"<Title>";
    [self addSubview:_titleLabel];
    
    UIFont *alternateGothicFont = [UIFont fontWithName:@"Alternate-Gothic-No3" size:30];
    _titleLabel.font = alternateGothicFont;
}

- (void)deinitialize
{
    [_backgroundImageView removeFromSuperview];
    [_backgroundImageView release];
    
    [_titleBackgroundImageView removeFromSuperview];
    [_titleBackgroundImageView release];
    
    [_titleLabel removeFromSuperview];
    [_titleLabel release];
}

- (void)dealloc
{
    [self deinitialize];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)layoutSubviews
{
    CGSize selfSize = self.bounds.size;
    
    _backgroundImageView.frame = CGRectMake(0, 0, selfSize.width, selfSize.height - 5);
    _titleBackgroundImageView.frame = self.bounds;
//    _accountLabel.frame = CGRectMake(0, selfSize.height / 6, 
//                                     selfSize.width, selfSize.height / 3);
//    _titleLabel.frame = CGRectMake(0, selfSize.height / 3 + selfSize.height / 6 ,
//                                   selfSize.width, selfSize.height / 3);
    _titleLabel.frame = self.bounds;
}

- (void)setAccountName:(NSString *)accountName
{
    _accountLabel.text = accountName;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

@end
