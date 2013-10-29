//
//  HelpSummaryPopupView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/4/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "HelpSummaryPopupView.h"
#import "RTLabelWithWordWrap.h"
//#import <QuartzCore/QuartzCore.h>
#import "PCFonts.h"

@interface HelpSummaryPopupView ()// <MTLabelDelegate>

//@property (nonatomic, strong) IBOutlet UIButton* infoButton;
@property (nonatomic, strong) IBOutlet RTLabelWithWordWrap* label;

@end

@implementation HelpSummaryPopupView

+ (HelpSummaryPopupView*) helpView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"HelpSummaryPopupView" owner:nil options:nil] lastObject];
}

- (void) awakeFromNib
{
    self.label.text = @"LES ARTICLES DEJA TELECHARGES S'AFFICHENT DANS CE MENU";
    self.label.kernValue = -0.5f;
    self.label.font = [UIFont fontWithName:PCFontInterstateLight size:15];
    self.label.textAlignment = RTTextAlignmentCenter;
    self.label.textColor = UIColorFromRGB(0x969696);
}


@end
