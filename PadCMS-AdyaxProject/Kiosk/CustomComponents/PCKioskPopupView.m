//
//  PCKioskPopupView.m
//  Pad CMS
//
//  Created by tar on 22.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskPopupView.h"

@interface PCKioskPopupView()

@property (nonatomic, strong) UIView * blockingView;
@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) UIButton * closeButton;
@property (nonatomic, strong) UITapGestureRecognizer * tapGesture;
@property (nonatomic, strong) UIView * viewToShowIn;
@property (nonatomic, strong) UIImageView * shadowImageView;
@property (nonatomic, strong, readonly) UIImage * shadowImage;
@property (nonatomic, readonly) CGFloat shadowWidth;

@end

const CGFloat kAnimationDuration = 0.5f;

@implementation PCKioskPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"PCKioskPopupView: please use initWithSize:viewToShowIn: method instead.");
    }
    return self;
}


#pragma mark - Designated initializer

- (id)initWithSize:(CGSize)size viewToShowIn:(UIView *)view {
    
    CGFloat aShadowWidth = 6;
    UIImage * aShadowImage = [[UIImage imageNamed:@"home_issue_bg_shadow_6px"] stretchableImageWithLeftCapWidth:aShadowWidth*2 topCapHeight:aShadowWidth*2];
    
    CGRect frame = CGRectMake((view.frame.size.width - size.width + aShadowWidth*2)/2, (view.frame.size.height - size.height + aShadowWidth*2)/2, size.width + aShadowWidth*2, size.height + aShadowWidth*2);
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _shadowImage = aShadowImage;
        _shadowWidth = aShadowWidth;
        _viewToShowIn = view;
        [self initialize];
    }
    
    return self;
}


#pragma mark - Initialization

- (void)initialize {
    
    self.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    
    [self initBlockingView];
    
    [self initContentView];
    
    [self initCloseButton];

}


- (void)initBlockingView {
    //blocking view
    self.blockingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.viewToShowIn.frame.size.width, self.viewToShowIn.frame.size.height)];
    [self.blockingView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.79f]];
    [self.blockingView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.viewToShowIn addSubview:self.blockingView];
    
    //tap
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [self.blockingView addGestureRecognizer:self.tapGesture];
}

- (void)initContentView {
    
    //shadow image view
    self.shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.shadowImageView.image = self.shadowImage;
    [self addSubview:self.shadowImageView];
    
    //content view
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(_shadowWidth, _shadowWidth, self.frame.size.width - _shadowWidth*2, self.frame.size.height - _shadowWidth*2)];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.contentView];
    
    [self.blockingView addSubview:self];
    
    self.blockingView.alpha = 0.0f;
}

- (void)initCloseButton {
    
    CGFloat closeButtonWidth = 44.0f;
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(self.frame.size.width - _shadowWidth - closeButtonWidth, _shadowWidth, closeButtonWidth, closeButtonWidth);
    [self.closeButton setImage:[UIImage imageNamed:@"popup_close_button"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
    
}

#pragma mark - Show/Hide public actions

- (void)show {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.blockingView.alpha = 1.0f;
    }];
}

- (void)hide {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.blockingView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.blockingView removeFromSuperview];
    }];
}


#pragma mark - Tap gesture action

- (void)tapGestureHandler:(UITapGestureRecognizer *)recognizer {
    self.closeButton.enabled = NO;
    [self hide];
}


#pragma mark - Close button action

- (void)closeAction:(UIButton *)sender {
    self.closeButton.enabled = NO;
    [self hide];
}


@end
