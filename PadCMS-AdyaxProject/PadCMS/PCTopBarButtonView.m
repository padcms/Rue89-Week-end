//
//  PCTopBarButtonView.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 6/12/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCTopBarButtonView.h"

@interface PCTopBarButtonView ()
{
    UIImageView *_substrateImageView;
}

- (void)initialize;
- (void)deinitialize;

@end

@implementation PCTopBarButtonView
@synthesize button = _button;

- (void)initialize
{
    _substrateImageView = [[UIImageView alloc] init];
    [self addSubview:_substrateImageView];

    _button = [[UIButton alloc] init];
    [self addSubview:_button];
}

- (void)deinitialize
{
    [_substrateImageView removeFromSuperview];
    [_substrateImageView release];

    [_button removeFromSuperview];
    [_button release];
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
    
    _substrateImageView.frame = self.bounds;
    CGSize selfSize = self.bounds.size;
    CGSize buttonSize = _button.bounds.size;
    
    CGRect buttonFrame = CGRectMake((selfSize.width - buttonSize.width) / 2, 
                                    (selfSize.height - buttonSize.height) / 2, 
                                    buttonSize.width, 
                                    buttonSize.height);
    _button.frame = buttonFrame;
}

#pragma mark - public methods

- (void)setSubstrateImage:(UIImage *)image
{
    _substrateImageView.image = image;
}

@end
