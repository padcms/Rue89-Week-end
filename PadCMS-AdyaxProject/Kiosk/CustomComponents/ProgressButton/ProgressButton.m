//
//  ProgressButton.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/10/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "ProgressButton.h"
#import "ProgressView.h"
#import "PCFonts.h"
#import "UIView+EasyFrame.h"

@interface ProgressButton ()

@property (nonatomic, strong) ProgressView* progressView;

@end

@implementation ProgressButton

+ (ProgressButton*) progressButtonWithTitle:(NSString*)title
{
    ProgressButton * button = [ProgressButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat fontSize = 16.5;
    
    [button setBackgroundImage:[[UIImage imageNamed:@"home_issue_button_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
    [button setTitle:[title uppercaseString]
            forState:UIControlStateNormal];
    [button titleLabel].font = [UIFont fontWithName:PCFontQuicksandBold size:fontSize];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
    [button titleLabel].backgroundColor = [UIColor clearColor];
    [button titleLabel].textAlignment = NSTextAlignmentCenter;
    [button titleLabel].textColor = [UIColor whiteColor];
    [button sizeToFit];
    button.hidden = YES;
    
    [button setTitle:@"PATIENCE\u2026" forState:UIControlStateSelected];
    
    return button;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.progressView = [[ProgressView alloc]initWithFrame:CGRectMake(self.titleLabel.frameX, self.titleLabel.frameY + self.titleLabel.frameHeight, self.titleLabel.frameWidth, 4)];
        self.progressView.backgroundColor = [UIColor clearColor];
        self.progressView.trackTintColor = [UIColor clearColor];
        self.progressView.progressTintColor = [UIColor whiteColor];
        self.progressView.hidden = YES;
        
        [self addSubview:self.progressView];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.progressView.frame = CGRectMake(self.titleLabel.frameX, self.titleLabel.frameY + self.titleLabel.frameHeight - 2, self.titleLabel.frameWidth, self.progressView.frameHeight);
}

- (void) setProgress:(float)progress
{
    self.progressView.progress = progress;
}

- (void) showProgress
{
    if(self.progressView.hidden)
    {
        //self.progressView.progress = 0;
        self.progressView.hidden = NO;
        [self setNeedsLayout];
    }
}

- (void) hideProgress
{
    if(self.progressView.hidden == NO)
    {
        self.progressView.hidden = YES;
        [self setNeedsLayout];
    }
}

- (void) showPatience
{
    [self setSelected:YES];
}

- (void) hidePatience
{
    [self setSelected:NO];
}

@end
