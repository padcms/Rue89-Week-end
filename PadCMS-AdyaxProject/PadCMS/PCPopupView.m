//
//  PCPopupView.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 6/12/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPopupView.h"

#import "QuartzCore/QuartzCore.h"


@interface PCPopupView ()
{
    UILabel *_titleLabel;
    UILabel *_messageLabel;
}

- (void)initialize;
- (void)deinitialize;

@end

@implementation PCPopupView

- (void)initialize
{
    self.layer.cornerRadius = 12;
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.8;
    
    UIFont *labelsFont = [UIFont boldSystemFontOfSize:20];
    
    // title label
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = labelsFont;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.text = @"";
    [self addSubview:_titleLabel];
    [_titleLabel release];
    
    // message label
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.font = labelsFont;
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.textAlignment = UITextAlignmentCenter;
    _messageLabel.text = @"";
    [self addSubview:_messageLabel];
    [_messageLabel release];
}

- (void)deinitialize
{
    [_titleLabel removeFromSuperview];
    [_titleLabel release];
    
    [_messageLabel removeFromSuperview];
    [_messageLabel release];
}

- (void)dealloc
{
    [self deinitialize];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize selfSize = self.bounds.size; 
    
    CGRect titleLabelFrame = CGRectMake(0, 0, selfSize.width, selfSize.height / 2);
    _titleLabel.frame = titleLabelFrame;
    
    CGRect messageLabelFrame = CGRectMake(0, selfSize.height / 2.5, 
                                          selfSize.width, selfSize.height / 2.5);
    _messageLabel.frame = messageLabelFrame;
}

#pragma mark - public methods

- (void)setPopupTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setPopupMessage:(NSString *)message
{
    _messageLabel.text = message;
}

#pragma mark - public class methods

+ (void)showPopupViewInView:(UIView *)view title:(NSString *)title message:(NSString *)message
{
    CGSize viewSize = view.bounds.size;
    CGRect popupViewFrame = CGRectMake((viewSize.width - 250 ) / 2, 
                                       (viewSize.height - 150 ) / 2, 
                                       285, 
                                       150);
    PCPopupView *popupView = [[PCPopupView alloc] initWithFrame:popupViewFrame];
    [popupView setPopupTitle:title];
    [popupView setPopupMessage:message];
    
    [view addSubview:popupView];
    [view bringSubviewToFront:popupView];
    
    [UIView animateWithDuration:2.5 animations:^{
        popupView.alpha = 0;
    } completion:^(BOOL finished) {
        [popupView release];
    }];
}

@end
