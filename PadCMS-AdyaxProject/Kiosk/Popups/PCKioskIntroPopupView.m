//
//  PCKioskIntroPopupView.m
//  Pad CMS
//
//  Created by tar on 22.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskIntroPopupView.h"
#import "MTLabel.h"
#import <QuartzCore/QuartzCore.h>

#import "RTLabelWithWordWrap.h"

@interface PCKioskIntroPopupView()

@property (nonatomic, strong) PCKioskSubscribeButton * subscribeButton;
@property (nonatomic, strong) RTLabelWithWordWrap* labelAfterSubscriptionButton;

@end

@implementation PCKioskIntroPopupView

- (void)loadContent {
    [super loadContent];
    [self initSubscribeButton];
    [self initAfterSubscriptionLabel];
    
    CGRect contentFrame = self.frame;
    CGFloat leftPadding = 50;
    self.titleLabel.frame = CGRectMake( 0, 20, contentFrame.size.width, 50);
    self.descriptionLabel.frame = CGRectMake(leftPadding, 90, contentFrame.size.width - leftPadding*2, 300);
    
    self.titleLabel.text = self.titleText ? self.titleText : @"Bienvenue !";
    self.descriptionLabel.text = self.descriptionText ? self.descriptionText : @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec dui ligula. Cras lacus enim, condimentum et massa ac, iaculis tincidunt tortor. Ut velit neque, rutrum at nunc vel, vehicula tempus velit. Cras a orci sapien. Sed nibh magna, bibendum at facilisis eget, accumsan vitae neque.\n\nAenean vehicula, magna in elementum suscipit, augue risus dapibus eros, sit amet elementum enim sem in massa. In hac habitasse platea dictumst.Integer sem nibh, imperdiet ac sapien at, venenatis eleifend felis. Nulla commodo libero eget libero iaculis, et dignissim quam auctor. Vestibulum mauris neque, consectetur at mi ut, ornare fermentum nunc.\n\nVestibulum semper feugiat ligula et suscipit. Curabitur egestas commodo augue, non lobortis eros sagittis eget.";
    
    self.labelAfterSubscriptionButton.text = self.infoText ? self.infoText : @"Je suis déjà qbonné ou je ux d'qbord voir à auoi something else wrote here but i do not known what.";
    
    UIButton* aboveLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aboveLabelButton addTarget:self action:@selector(tapLabel:) forControlEvents:UIControlEventTouchUpInside];
    aboveLabelButton.frame = self.labelAfterSubscriptionButton.frame;
    [self addSubview:aboveLabelButton];
}

- (void) initAfterSubscriptionLabel
{
    CGRect buttonFrame = self.subscribeButton.frame;
    
    self.labelAfterSubscriptionButton = [[RTLabelWithWordWrap alloc] initWithFrame:CGRectMake(buttonFrame.origin.x - buttonFrame.size.width / 4, buttonFrame.origin.y + buttonFrame.size.height + 15, buttonFrame.size.width * 1.5, 50)];
    self.labelAfterSubscriptionButton.font = [UIFont fontWithName:PCFontInterstateRegular size:15];
    self.labelAfterSubscriptionButton.backgroundColor = [UIColor clearColor];
    [self.labelAfterSubscriptionButton setKernValue:-0.5f];
    self.labelAfterSubscriptionButton.textColor = UIColorFromRGB(0x34495e);
    self.labelAfterSubscriptionButton.textAlignment = RTTextAlignmentCenter;
    [self addSubview:self.labelAfterSubscriptionButton];
}

- (void)tapLabel:(UIButton *)button
{
    button.userInteractionEnabled = NO;
    self.closeButton.enabled = NO;
    if (self.isShown)
    {
        [self hide];
    }
}

- (void)initSubscribeButton {
    //set the right one
    self.subscribeButton = [[[UINib nibWithNibName:@"PCKioskSubscribeButton" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [self addSubview:self.subscribeButton];
    
    //blur fix
    CGRect frame = self.subscribeButton.frame;
    frame.size.width += 1;
    frame.size.height += 1;
    self.subscribeButton.frame = frame;
    
    self.subscribeButton.center = CGPointMake(self.frame.size.width/2, 395);
    
    [self.subscribeButton.button addTarget:self action:@selector(purchaseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.subscribeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.subscribeButton.layer.shadowOpacity = 0.3f;
    self.subscribeButton.layer.shadowRadius = 3.0f;
    self.subscribeButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.subscribeButton.layer.shouldRasterize = YES;
    self.subscribeButton.layer.shadowOffset = CGSizeMake(0, 0);
}

- (void)purchaseAction:(PCKioskSubscribeButton *)sender {
    if ([self.purchaseDelegate respondsToSelector:@selector(subscribeButtonTapped:)]) {
        [self.purchaseDelegate subscribeButtonTapped:sender];
    }
}

@end
