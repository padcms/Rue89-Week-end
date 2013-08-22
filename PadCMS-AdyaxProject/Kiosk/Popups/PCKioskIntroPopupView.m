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

@interface PCKioskIntroPopupView()

@property (nonatomic, strong) MTLabel * titleLabel;
@property (nonatomic, strong) MTLabel * descriptionLabel;
@property (nonatomic, strong) PCKioskSubscribeButton * subscribeButton;

@end

@implementation PCKioskIntroPopupView

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
    [self initSubscribeButton];
}

- (void)initTitle {
    CGRect contentFrame = self.contentView.frame;
    self.titleLabel = [[MTLabel alloc] initWithFrame:CGRectMake( 0, 20, contentFrame.size.width, 50)];
    self.titleLabel.text = @"Bienvenue !";
    self.titleLabel.font = [UIFont fontWithName:PCFontLeckerliOne size:40];
    self.titleLabel.textAlignment = MTLabelTextAlignmentCenter;
    [self.titleLabel setCharacterSpacing:-0.8f];
    [self.titleLabel setFontColor:UIColorFromRGB(0x34495e)];
    [self.contentView addSubview:self.titleLabel];
}

- (void)initDescription {
    CGRect contentFrame = self.contentView.frame;
    CGFloat leftPadding = 50;
    self.descriptionLabel = [[MTLabel alloc] initWithFrame:CGRectMake(leftPadding, 90, contentFrame.size.width - leftPadding*2, 300)];

    self.descriptionLabel.font = [UIFont fontWithName:PCFontInterstateRegular size:15];
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    [self.descriptionLabel setCharacterSpacing:-0.5f];
    [self.descriptionLabel setLineHeight:20];
    [self.descriptionLabel setTextAlignment:MTLabelTextAlignmentLeft];
    self.descriptionLabel.fontColor = UIColorFromRGB(0x34495e);
    [self.contentView addSubview:self.descriptionLabel];
    
    self.descriptionLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec dui ligula. Cras lacus enim, condimentum et massa ac, iaculis tincidunt tortor. Ut velit neque, rutrum at nunc vel, vehicula tempus velit. Cras a orci sapien. Sed nibh magna, bibendum at facilisis eget, accumsan vitae neque.\n\nAenean vehicula, magna in elementum suscipit, augue risus dapibus eros, sit amet elementum enim sem in massa. In hac habitasse platea dictumst.Integer sem nibh, imperdiet ac sapien at, venenatis eleifend felis. Nulla commodo libero eget libero iaculis, et dignissim quam auctor. Vestibulum mauris neque, consectetur at mi ut, ornare fermentum nunc.\n\nVestibulum semper feugiat ligula et suscipit. Curabitur egestas commodo augue, non lobortis eros sagittis eget.";
}

- (void)initSubscribeButton {
    //set the right one
    self.subscribeButton = [[[UINib nibWithNibName:@"PCKioskSubscribeButton" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [self.contentView addSubview:self.subscribeButton];
    //self.subscribeButton.frame = CGRectMake(0, 0, 143, 55);
    self.subscribeButton.center = CGPointMake(self.contentView.frame.size.width/2, 420);
    [self.subscribeButton.button addTarget:self action:@selector(purchaseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.subscribeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.subscribeButton.layer.shadowOpacity = 0.3f;
    self.subscribeButton.layer.shadowRadius = 3.0f;
    self.subscribeButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.subscribeButton.layer.shouldRasterize = YES;
    self.subscribeButton.layer.shadowOffset = CGSizeMake(0, 0);
}

- (void)purchaseAction:(UIButton *)sender {
    if ([self.purchaseDelegate respondsToSelector:@selector(subscribeButtonTapped)]) {
        [self.purchaseDelegate subscribeButtonTapped];
    }
}

@end
