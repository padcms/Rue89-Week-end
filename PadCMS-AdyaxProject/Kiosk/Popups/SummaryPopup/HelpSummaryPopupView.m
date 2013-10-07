//
//  HelpSummaryPopupView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/4/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "HelpSummaryPopupView.h"
#import "MTLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "PCFonts.h"

@interface HelpSummaryPopupView () <MTLabelDelegate>

@property (nonatomic, strong) IBOutlet UIButton* infoButton;
@property (nonatomic, strong) IBOutlet MTLabel* label;

@end

@implementation HelpSummaryPopupView

+ (HelpSummaryPopupView*) helpView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"HelpSummaryPopupView" owner:nil options:nil] lastObject];
}

- (void) awakeFromNib
{
    self.infoButton.layer.affineTransform = CGAffineTransformMakeScale(1.5, 1.5);
    
    [self.label setResizeToFitText:YES];
    self.label.text = @"LES ARTICLES\nDEJA TELECHARGES\nS'AFFICHENT\nDANS CE MENU";
    self.label.font = [UIFont fontWithName:PCFontInterstateLight size:15];
    self.label.textAlignment = MTLabelTextAlignmentCenter;
    [self.label setCharacterSpacing:-0.5f];
    [self.label setFontColor:UIColorFromRGB(0x969696)];
    self.label.contentMode = UIViewContentModeRedraw;
    self.label.delegate = self;
}

- (void)label:(MTLabel *)label didChangeFrame:(CGRect)frame {
    [label setNeedsDisplay];
    
}

@end
