//
//  PCKioskSubscribeButton.m
//  Pad CMS
//
//  Created by tar on 19.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskSubscribeButton.h"

@implementation PCKioskSubscribeButton

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
    
    [self.topLabel setFont:[UIFont fontWithName:fontName size:20]];
    [self.bottomLabel setFont:[UIFont fontWithName:fontName size:14.1]];
}


#pragma mark - Button actions

- (IBAction)buttonTouchDownAction:(UIButton *)sender {
    [self selectLabels];
}

- (IBAction)buttonTouchUpInsideAction:(UIButton *)sender {
    [self deselectLabels];
}

- (IBAction)buttonTouchUpOutsideAction:(UIButton *)sender {
    [self deselectLabels];
}
- (IBAction)buttonTouchDragEnterAction:(UIButton *)sender {
    [self selectLabels];
}
- (IBAction)buttonTouchDragExitAction:(UIButton *)sender {
    [self deselectLabels];
}

- (IBAction)buttonTouchCancelAction:(UIButton *)sender {
    [self deselectLabels];
}


#pragma mark - Labels adjustments

- (void)selectLabels {
    [self.topLabel setTextColor:[UIColor lightGrayColor]];
    [self.bottomLabel setTextColor:[UIColor lightGrayColor]];
}

- (void)deselectLabels {
    [self.topLabel setTextColor:[UIColor whiteColor]];
    [self.bottomLabel setTextColor:[UIColor whiteColor]];
}


#pragma mark - Memory management

- (void)dealloc {
    [_topLabel release];
    [_bottomLabel release];
    [_button release];
    [super dealloc];
}

@end
