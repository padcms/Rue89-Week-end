//
//  PCKioskHeaderView.m
//  Pad CMS
//
//  Created by tar on 16.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskHeaderView.h"
#import "PCKioskSubscribeButton.h"

@interface PCKioskHeaderView()

@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *contactUsButton;
@property (retain, nonatomic) IBOutlet UIButton *restorePurchasesButton;
@property (retain, nonatomic) IBOutlet PCKioskSubscribeButton *subscribeButton;

@end

@implementation PCKioskHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    NSString * fontName = @"QuicksandBold-Regular";
    UIEdgeInsets insets = UIEdgeInsetsMake(4, 0, 0, 0);
    CGFloat fontSize = 16.5;
    
    [self.shareButton.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    [self.contactUsButton.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    [self.restorePurchasesButton.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    
    [self.shareButton setTitleEdgeInsets:insets];
    [self.contactUsButton setTitleEdgeInsets:insets];
    [self.restorePurchasesButton setTitleEdgeInsets:insets];
    
    //subscribe button
    
    //remove placeholer
    CGRect frame = self.subscribeButton.frame;
    [self.subscribeButton removeFromSuperview];
    
    //set the right one
    self.subscribeButton = [[[UINib nibWithNibName:@"PCKioskSubscribeButton" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [self addSubview:self.subscribeButton];
    self.subscribeButton.frame = frame;
    [self.subscribeButton.button addTarget:self action:@selector(purchaseAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Button actions

- (IBAction)shareButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(shareButtonTapped)]) {
        [self.delegate shareButtonTapped];
    }
}

- (IBAction)contactUsButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(contactUsButtonTapped)]) {
        [self.delegate contactUsButtonTapped];
    }
}

- (IBAction)restorePurchasesButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(restorePurchasesButtonTapped:)]) {
        [self.delegate restorePurchasesButtonTapped:YES];
    }
}
- (void)purchaseAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(subscribeButtonTapped)]) {
        [self.delegate subscribeButtonTapped];
    }
}

- (void)dealloc {
    [_shareButton release];
    [_contactUsButton release];
    [_restorePurchasesButton release];
    [_subscribeButton release];
    [super dealloc];
}
@end
