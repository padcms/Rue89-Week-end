//
//  PCKioskSubscribeButton.m
//  Pad CMS
//
//  Created by tar on 19.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskSubscribeButton.h"
#import <QuartzCore/QuartzCore.h>

@interface PCKioskSubscribeButton ()

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activity;

@end

@implementation PCKioskSubscribeButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    NSString * fontName = @"QuicksandBold-Regular";
    
    [self.topLabel setFont:[UIFont fontWithName:fontName size:20]];
    [self.bottomLabel setFont:[UIFont fontWithName:fontName size:14.1]];
    
    [self.subscribedLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:18]];
    
    self.activity.layer.cornerRadius = (int) (self.activity.frame.size.width / 2);
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

- (void) setState:(PCKioskSubscribeButtonState)state
{
    _state = state;
    switch (state)
    {
        case PCKioskSubscribeButtonStateNotSubscribed:
            
            self.subscribedLabel.hidden = YES;
            self.topLabel.hidden = NO;
            self.bottomLabel.hidden = NO;
            [self.activity stopAnimating];
            self.button.userInteractionEnabled = YES;
            break;
            
        case PCKioskSubscribeButtonStateSubscribing:
            
            self.subscribedLabel.hidden = YES;
            self.topLabel.hidden = NO;
            self.bottomLabel.hidden = NO;
            [self.activity startAnimating];
            self.button.userInteractionEnabled = NO;
            break;
            
        case PCKioskSubscribeButtonStateSubscribed:
            
            self.subscribedLabel.hidden = NO;
            self.topLabel.hidden = YES;
            self.bottomLabel.hidden = YES;
            [self.activity stopAnimating];
            self.button.userInteractionEnabled = NO;
            break;
    }
}

- (void)setIsSubscribedState:(BOOL)isSubscribedState {
    _isSubscribedState = isSubscribedState;
    
    self.subscribedLabel.hidden = !isSubscribedState;
    self.topLabel.hidden = isSubscribedState;
    self.bottomLabel.hidden = isSubscribedState;
    
    self.button.enabled = !isSubscribedState;
}
@end
