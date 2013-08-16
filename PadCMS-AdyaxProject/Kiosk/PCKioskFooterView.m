//
//  PCKioskFooterView.m
//  Pad CMS
//
//  Created by tar on 16.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskFooterView.h"

@interface PCKioskFooterView()

@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) NSMutableArray * buttonsArray;

@end

@implementation PCKioskFooterView

+ (PCKioskFooterView *)footerViewForView:(UIView *)view {
    UIImage * backgroundImage = [UIImage imageNamed:@"home_footer_bg"];
    CGFloat footerHeight = backgroundImage.size.height;
    PCKioskFooterView * footerView = [[self alloc] initWithFrame:CGRectMake(0, view.frame.size.height - footerHeight, view.frame.size.width, footerHeight)];
    return footerView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initInterface];
    }
    return self;
}

- (void)initInterface {
    
    self.backgroundColor = [UIColor clearColor];
    
    CGRect fullFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.buttonsArray = [NSMutableArray array];
    
    //background
    UIImage * backgroundImage = [UIImage imageNamed:@"home_footer_bg"];
    UIImageView * backgroundImageView;
    backgroundImageView = [[UIImageView alloc] initWithFrame:fullFrame];
    backgroundImageView.image = backgroundImage;
    backgroundImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:backgroundImageView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:fullFrame];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    //buttons
    [self initButtons];
    
    //fade
    UIImage * footerFadeImage = [UIImage imageNamed:@"home_footer_fade"];
    UIImageView * fadeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - footerFadeImage.size.width, self.frame.size.height - footerFadeImage.size.height, footerFadeImage.size.width, footerFadeImage.size.height)];
    fadeImageView.image = footerFadeImage;
    [self addSubview:fadeImageView];
    
    //arrow button
    //UIButton * arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
}

- (void)initButtons {
    
    NSArray * buttonNames = @[@"Button1", @"Button2", @"Button3", @"Button4", @"Button5", @"Button6", @"Button7", @"Button7", @"Button7", @"Button7", @"Button7"];
    
    int i = 0;
    CGFloat buttonWidth = 100;
    CGFloat buttonHeight = 44;
    for (NSString * buttonName in buttonNames) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*buttonWidth, 5, buttonWidth, buttonHeight);
        button.backgroundColor = [UIColor clearColor];
        button.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
        button.titleLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18];
        [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        [self.scrollView addSubview:button];
        [self.buttonsArray addObject:button];
        
        i++;
    }
    
    UIButton * lastButton = [self.buttonsArray lastObject];
    self.scrollView.contentSize = CGSizeMake(lastButton.frame.origin.x  + lastButton.frame.size.width, self.scrollView.contentSize.height);
}

@end
