//
//  PCKioskSharePopupView.m
//  Pad CMS
//
//  Created by tar on 22.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskSharePopupView.h"
#import "MTLabel.h"

@interface PCKioskSharePopupView()

@property (nonatomic, strong) MTLabel * titleLabel;
@property (nonatomic, strong) MTLabel * descriptionLabel;

@end

@implementation PCKioskSharePopupView

- (id)initWithSize:(CGSize)size viewToShowIn:(UIView *)view
{
    self = [super initWithSize:size viewToShowIn:view];
    if (self) {
        [self initContent];
    }
    return self;
}

- (void)initContent {
    [self initTitle];
    [self initDescription];
    [self initShareButtonsAndLabels];
}

- (void)initTitle {
    CGRect contentFrame = self.contentView.frame;
    self.titleLabel = [[MTLabel alloc] initWithFrame:CGRectMake( 0, 20, contentFrame.size.width, 50)];
    self.titleLabel.text = @"Partagez Rue89 Week-end";
    self.titleLabel.font = [UIFont fontWithName:PCFontLeckerliOne size:40];
    self.titleLabel.textAlignment = MTLabelTextAlignmentCenter;
    [self.titleLabel setCharacterSpacing:-0.8f];
    [self.titleLabel setFontColor:UIColorFromRGB(0x34495e)];
    [self.contentView addSubview:self.titleLabel];
}

- (void)initDescription {
    CGRect contentFrame = self.contentView.frame;
    self.descriptionLabel = [[MTLabel alloc] initWithFrame:CGRectMake(0, 90, contentFrame.size.width, 50)];
    self.descriptionLabel.text = @"Il n’y a pas d’amour, il n’y a que des preuves d’amour. Alors faites\ndécouvrir votre magazine tablettes préféré à tout votre réseau !";
    self.descriptionLabel.font = [UIFont fontWithName:PCFontInterstateRegular size:15];
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    [self.descriptionLabel setCharacterSpacing:-0.5f];
    [self.descriptionLabel setTextAlignment:MTLabelTextAlignmentCenter];
    self.descriptionLabel.fontColor = UIColorFromRGB(0x34495e);
    [self.contentView addSubview:self.descriptionLabel];
}

- (MTLabel *)shareTitleLabel {
    MTLabel * label = [[MTLabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:PCFontQuicksandBold size:16.5];
    label.characterSpacing = -0.4f;
    label.textAlignment = MTLabelTextAlignmentCenter;
    return label;
}

- (void)initShareButtonsAndLabels {
    
    //setup variables
    CGFloat padding = 7;
    CGPoint center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2 + 50);
    CGSize buttonSize = CGSizeMake(75, 75);
    
    //facebook button
    UIButton * facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookButton setImage:[UIImage imageNamed:@"share_facebook"] forState:UIControlStateNormal];
    [facebookButton setFrame:CGRectMake(center.x - buttonSize.width - padding, center.y - buttonSize.height - padding, buttonSize.width, buttonSize.height)];
    [self.contentView addSubview:facebookButton];
    
    //twitter button
    UIButton * twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [twitterButton setImage:[UIImage imageNamed:@"share_twitter"] forState:UIControlStateNormal];
    [twitterButton setFrame:CGRectMake(center.x + padding, center.y - buttonSize.height - padding, buttonSize.width, buttonSize.height)];
    [self.contentView addSubview:twitterButton];
    
    //google button
    UIButton * googlePlusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [googlePlusButton setImage:[UIImage imageNamed:@"share_google_plus"] forState:UIControlStateNormal];
    [googlePlusButton setFrame:CGRectMake(center.x - buttonSize.width - padding, center.y + padding, buttonSize.width, buttonSize.height)];
    [self.contentView addSubview:googlePlusButton];
    
    //google button
    UIButton * mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mailButton setImage:[UIImage imageNamed:@"share_mail"] forState:UIControlStateNormal];
    [mailButton setFrame:CGRectMake(center.x + padding, center.y + padding, buttonSize.width, buttonSize.height)];
    [self.contentView addSubview:mailButton];
    
    
    
    //LABELS
    
    CGFloat labelWidth = 140;
    CGFloat labelHeight = 40;
    CGFloat labelTopPadding = 20;
    
    MTLabel * facebookLabel = [self shareTitleLabel];
    facebookLabel.text = @"SUR\nFACEBOOK";
    facebookLabel.frame = CGRectMake(facebookButton.frame.origin.x - labelWidth, facebookButton.frame.origin.y + labelTopPadding, labelWidth, labelHeight);
    facebookLabel.fontColor = UIColorFromRGB(0x3160bf);
    [self.contentView addSubview:facebookLabel];
    //facebookLabel.backgroundColor = [UIColor orangeColor];
    
    MTLabel * googlePlusLabel = [self shareTitleLabel];
    googlePlusLabel.text = @"SUR\nGOOGLE+";
    googlePlusLabel.frame = CGRectMake(googlePlusButton.frame.origin.x - labelWidth, googlePlusButton.frame.origin.y + labelTopPadding, labelWidth, labelHeight);
    googlePlusLabel.fontColor = UIColorFromRGB(0xbf4031);
    [self.contentView addSubview:googlePlusLabel];
    
    MTLabel * twitterLabel = [self shareTitleLabel];
    twitterLabel.text = @"SUR\nTWITTER";
    twitterLabel.frame = CGRectMake(CGRectGetMaxX(twitterButton.frame), twitterButton.frame.origin.y + labelTopPadding, labelWidth, labelHeight);
    twitterLabel.fontColor = UIColorFromRGB(0x32bde6);
    [self.contentView addSubview:twitterLabel];
    
    MTLabel * emailLabel = [self shareTitleLabel];
    emailLabel.text = @"PAR\nE-MAIL";
    emailLabel.frame = CGRectMake(CGRectGetMaxX(mailButton.frame), mailButton.frame.origin.y + labelTopPadding, labelWidth, labelHeight);
    emailLabel.fontColor = UIColorFromRGB(0xabadbe);
    [self.contentView addSubview:emailLabel];
}

@end
