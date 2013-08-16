//
//  PCKioskHeaderView.m
//  Pad CMS
//
//  Created by tar on 16.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskHeaderView.h"

@interface PCKioskHeaderView()

@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *contactUsButton;
@property (retain, nonatomic) IBOutlet UIButton *restorePurchasesButton;

@property (retain, nonatomic) IBOutlet UILabel *subscribeButtonTopLabel;
@property (retain, nonatomic) IBOutlet UILabel *subscribeButtonBottomLabel;

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
    
    NSString * fontName = @"QuicksandBold-Regular";
    UIEdgeInsets insets = UIEdgeInsetsMake(4, 0, 0, 0);
    
    [self.shareButton.titleLabel setFont:[UIFont fontWithName:fontName size:15]];
    [self.contactUsButton.titleLabel setFont:[UIFont fontWithName:fontName size:15]];
    [self.restorePurchasesButton.titleLabel setFont:[UIFont fontWithName:fontName size:15]];
    
    [self.shareButton setTitleEdgeInsets:insets];
    [self.contactUsButton setTitleEdgeInsets:insets];
    [self.restorePurchasesButton setTitleEdgeInsets:insets];
    
    [self.subscribeButtonTopLabel setFont:[UIFont fontWithName:fontName size:18.3]];
    [self.subscribeButtonBottomLabel setFont:[UIFont fontWithName:fontName size:13]];
}

- (IBAction)shareButton:(UIButton *)sender {
}
- (void)dealloc {
    [_shareButton release];
    [_contactUsButton release];
    [_restorePurchasesButton release];
    [_subscribeButtonTopLabel release];
    [_subscribeButtonBottomLabel release];
    [super dealloc];
}
@end
