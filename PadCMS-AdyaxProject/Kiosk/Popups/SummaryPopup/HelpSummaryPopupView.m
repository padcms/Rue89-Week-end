//
//  HelpSummaryPopupView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/4/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "HelpSummaryPopupView.h"
#import "RTLabelWithWordWrap.h"
#import <QuartzCore/QuartzCore.h>
#import "PCFonts.h"

@interface HelpSummaryPopupView ()// <MTLabelDelegate>

@property (nonatomic, strong) IBOutlet UIButton* infoButton;
@property (nonatomic, strong) IBOutlet RTLabelWithWordWrap* label;

@end

@implementation HelpSummaryPopupView

+ (HelpSummaryPopupView*) helpView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"HelpSummaryPopupView" owner:nil options:nil] lastObject];
}

- (void) awakeFromNib
{
    self.infoButton.layer.affineTransform = CGAffineTransformMakeScale(1.5, 1.5);
    
    self.label.text = @"<font kern=-0.5>LES ARTICLES\nDEJA TELECHARGES\nS'AFFICHENT\nDANS CE MENU</font>";
    self.label.font = [UIFont fontWithName:PCFontInterstateLight size:15];
    self.label.textAlignment = RTTextAlignmentCenter;
    self.label.textColor = UIColorFromRGB(0x969696);
}


@end
