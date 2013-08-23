//
//  PCKioskPopupView.m
//  Pad CMS
//
//  Created by tar on 22.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskPopupView.h"

@interface PCKioskPopupView() <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UIImage * shadowImage;

@end

const CGFloat kAnimationDuration = 0.4f;

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
    
    CGRect frame = CGRectMake((view.frame.size.width - size.width - aShadowWidth*2)/2,
                              (view.frame.size.height - size.height - aShadowWidth*2)/2 - 20,
                              size.width + aShadowWidth*2,
                              size.height + aShadowWidth*2);
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _presentationStyle = PCKioskPopupPresentationStyleCenter;
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
    
    [self loadContent];
    
    [self prepareForPresentation];

}

- (void)loadContent {
    [self initTitle];
    [self initDescription];
}


- (void)initBlockingView {
    //blocking view
    self.blockingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.viewToShowIn.frame.size.width, self.viewToShowIn.frame.size.height)];
    [self.blockingView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.79f]];
    [self.blockingView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.viewToShowIn addSubview:self.blockingView];
    
    //tap
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    self.tapGesture.delegate = self;
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
    
    CGSize closeButtonSize = CGSizeMake(60, 46);
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(self.frame.size.width - _shadowWidth - closeButtonSize.width, _shadowWidth, closeButtonSize.width, closeButtonSize.height);
    [self.closeButton setImage:[UIImage imageNamed:@"popup_close_button"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
    
}

- (void)initTitle {
    CGRect contentFrame = self.contentView.frame;
    self.titleLabel = [[MTLabel alloc] initWithFrame:CGRectMake( 0, 20, contentFrame.size.width, 50)];
    self.titleLabel.text = @"Title";
    self.titleLabel.font = [UIFont fontWithName:PCFontLeckerliOne size:40];
    self.titleLabel.textAlignment = MTLabelTextAlignmentCenter;
    [self.titleLabel setCharacterSpacing:-0.8f];
    [self.titleLabel setFontColor:UIColorFromRGB(0x34495e)];
    [self.contentView addSubview:self.titleLabel];
}

- (void)initDescription {
    CGRect contentFrame = self.contentView.frame;
    self.descriptionLabel = [[MTLabel alloc] initWithFrame:CGRectMake(0, 90, contentFrame.size.width, 50)];
    self.descriptionLabel.text = @"Description";
    self.descriptionLabel.font = [UIFont fontWithName:PCFontInterstateRegular size:15];
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    [self.descriptionLabel setCharacterSpacing:-0.5f];
    self.descriptionLabel.fontColor = UIColorFromRGB(0x34495e);
    [self.contentView addSubview:self.descriptionLabel];
}

- (void)prepareForPresentation {
    if (self.presentationStyle == PCKioskPopupPresentationStyleFromBottom) {
        self.frame = [self bottomHiddenFrame:YES];
        //self.blockingView.alpha = 1.0f;
        self.blockingView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1f];
    }
}

#pragma mark - Presentation setter

- (void)setPresentationStyle:(PCKioskPopupPresentationStyle)presentationStyle {
    _presentationStyle = presentationStyle;
    
    [self prepareForPresentation];
}

#pragma mark - Show/Hide public actions

- (void)show {
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.blockingView.alpha = 1.0f;
        if (self.presentationStyle == PCKioskPopupPresentationStyleCenter) {
            
        } else if (self.presentationStyle == PCKioskPopupPresentationStyleFromBottom) {
            self.blockingView.alpha = 1.0f;
            self.frame = [self bottomHiddenFrame:NO];
        }
    }];
}

- (void)hide {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        
        self.blockingView.alpha = 0.0f;
        
        if (self.presentationStyle == PCKioskPopupPresentationStyleCenter) {
            
        } else if (self.presentationStyle == PCKioskPopupPresentationStyleFromBottom) {
            self.frame = [self bottomHiddenFrame:YES];
        }
    } completion:^(BOOL finished) {
        [self.blockingView removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(popupViewDidHide:)]) {
            [self.delegate popupViewDidHide:self];
        }
    }];
}

#pragma mark - Frame helpers

- (CGRect)bottomHiddenFrame:(BOOL)hidden {
    return CGRectMake(self.frame.origin.x,
                      self.blockingView.frame.size.height + (hidden ?  0 : -self.frame.size.height + _shadowWidth),
                      self.frame.size.width
                      , self.frame.size.height);
}


#pragma mark - Tap gesture action

- (void)tapGestureHandler:(UITapGestureRecognizer *)recognizer {
    self.closeButton.enabled = NO;
    [self hide];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self.blockingView) {
        return YES;
    }
    
    return NO;
}


#pragma mark - Close button action

- (void)closeAction:(UIButton *)sender {
    self.closeButton.enabled = NO;
    [self hide];
}


@end
