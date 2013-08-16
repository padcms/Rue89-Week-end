//
//  PCKioskFooterView.m
//  Pad CMS
//
//  Created by tar on 16.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskFooterView.h"
#import "PCKioskShelfSettings.h"

@interface PCKioskFooterView()

@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) NSMutableArray * buttonsArray;
@property (nonatomic, strong) UIButton * selectedButton;

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
    
    
    //arrow
    UIImage * arrowImage = [UIImage imageNamed:@"home_footer_arrow"];
    UIImageView * arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - arrowImage.size.width - 8, 16, arrowImage.size.width, arrowImage.size.height)];
    arrowImageView.image = arrowImage;
    [self addSubview:arrowImageView];
    
}

- (UILabel *)separatorlabel {
    UILabel * separatorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    separatorLabel.backgroundColor = [UIColor clearColor];
    separatorLabel.text = @"|";
    separatorLabel.textColor = UIColorFromRGB(0xaeb2ce);
    separatorLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18];
    [separatorLabel sizeToFit];
    return separatorLabel;
}

- (void)initButtons {
    
    NSArray * buttonNames = @[@"TOUT", @"ARCHIVÉS", @"GRATUIT", @"PHOTO", @"BD", @"VIDÉO", @"COURT", @"REPORTAGES"];
    
    int i = 0;
    CGFloat buttonHeight = 44;
    CGFloat previousButtonX = 0;
    int buttonsCount = buttonNames.count;
    for (NSString * buttonName in buttonNames) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];        
        button.frame = CGRectMake(previousButtonX, 4, 0, 0);
        button.backgroundColor = [UIColor clearColor];
        button.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
        button.titleLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [button setTitleColor:UIColorFromRGB(0x91b4d7) forState:UIControlStateSelected];
        [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        //button.backgroundColor = [UIColor orangeColor];
        [self.scrollView addSubview:button];
        [self.buttonsArray addObject:button];
        
        //adjusting frame
        
        CGFloat sidePadding = 15.0f;
        
        [button sizeToFit];
        CGRect buttonFrame = button.frame;
        buttonFrame.size.height = buttonHeight;
        buttonFrame.size.width += sidePadding*2;
        button.frame = buttonFrame;
        
        
        //separator
        if (i < buttonsCount - 1) {
            previousButtonX = CGRectGetMaxX(button.frame);
            
            UILabel * separatorLabel = [self separatorlabel];
            CGRect separatorFrame = separatorLabel.frame;
            separatorFrame.origin.x = previousButtonX;
            separatorFrame.origin.y = 18;
            separatorLabel.frame = separatorFrame;
            [self.scrollView addSubview:separatorLabel];
            
            previousButtonX = CGRectGetMaxX(separatorLabel.frame);
        }
        
        //select first button
        if (i == 0) {
            button.selected = YES;
            self.selectedButton = button;
        }
        
        
        i++;
    }
    
    UIButton * lastButton = [self.buttonsArray lastObject];
    self.scrollView.contentSize = CGSizeMake(lastButton.frame.origin.x  + lastButton.frame.size.width + 30, self.scrollView.contentSize.height);
}

#pragma mark - Actions

- (void)buttonAction:(UIButton *)sender {
    
    sender.selected = YES;
    self.selectedButton.selected = NO;
    self.selectedButton = sender;
}

@end
