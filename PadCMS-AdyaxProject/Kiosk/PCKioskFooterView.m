//
//  PCKioskFooterView.m
//  Pad CMS
//
//  Created by tar on 16.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskFooterView.h"
#import "PCKioskShelfSettings.h"
#import "PCFonts.h"
#import "PCTag.h"

@interface PCKioskFooterView() <UIScrollViewDelegate>
{
    NSTimer* _scrollingTimer;
}
@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) NSMutableArray * buttonsArray;
@property (nonatomic, strong) UIButton * selectedButton;
@property (nonatomic, strong) NSArray * allTags;

@property (nonatomic, strong) UIImageView * rightFadeImageView;
@property (nonatomic, strong) UIImageView * leftFadeImageView;

@property (nonatomic, strong) UIButton * leftArrowButton;
@property (nonatomic, strong) UIButton * rightArrowButton;

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

- (void)setTags:(NSArray *)tags {
    _tags = tags;
    [self initButtons];
}

- (NSArray *)staticTags {
    if (!_staticTags) {
        
        PCTag * tag1 = [[PCTag alloc] init];
        tag1.tagId = TAG_ID_MAIN;
        tag1.tagTitle = @"TOUT";
        
        PCTag * tag2 = [[PCTag alloc] init];
        tag2.tagId = TAG_ID_ARCHIVES;
        tag2.tagTitle = @"ARCHIVES";
        
        PCTag * tag3 = [[PCTag alloc] init];
        tag3.tagId = TAG_ID_FREE;
        tag3.tagTitle = @"GRATUIT";
        
        _staticTags = @[tag1, tag2, tag3];
    }

    
    return _staticTags;
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
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    //buttons
    [self initButtons];
    
    
    //fade
    UIImage * footerFadeImage = [UIImage imageNamed:@"home_footer_fade"];
    
    _rightFadeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - footerFadeImage.size.width, self.frame.size.height - footerFadeImage.size.height, footerFadeImage.size.width, footerFadeImage.size.height)];
    _rightFadeImageView.image = footerFadeImage;
    _rightFadeImageView.userInteractionEnabled = YES;
    [self addSubview:_rightFadeImageView];
    
    _leftFadeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - footerFadeImage.size.height, footerFadeImage.size.width, footerFadeImage.size.height)];
    _leftFadeImageView.image = footerFadeImage;
    _leftFadeImageView.transform = CGAffineTransformMakeScale(-1, 1);
    _leftFadeImageView.userInteractionEnabled = YES;
    [self addSubview:_leftFadeImageView];
    
    
    //arrow
    UIImage * arrowImage = [UIImage imageNamed:@"home_footer_arrow"];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 10, 4, 0);
    
    _leftArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftArrowButton.frame = CGRectMake(0, 0, footerFadeImage.size.width, footerFadeImage.size.height);
    [_leftArrowButton setImage:arrowImage forState:UIControlStateNormal];
    _leftArrowButton.imageEdgeInsets = insets;
    [_leftArrowButton addTarget:self action:@selector(arrowAction:) forControlEvents:UIControlEventTouchDown];
    [_leftFadeImageView addSubview:_leftArrowButton];
    _leftArrowButton.exclusiveTouch = YES;
    
    _leftFadeImageView.alpha = 0.0f;
    
    _rightArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightArrowButton.frame = CGRectMake(0, 0, footerFadeImage.size.width, footerFadeImage.size.height);
    [_rightArrowButton setImage:arrowImage forState:UIControlStateNormal];
    _rightArrowButton.imageEdgeInsets = insets;
    [_rightArrowButton addTarget:self action:@selector(arrowAction:) forControlEvents:UIControlEventTouchDown];
    [_rightFadeImageView addSubview:_rightArrowButton];
    _rightArrowButton.exclusiveTouch = YES;
    
    
//    UIImageView * arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - arrowImage.size.width - 8, 16, arrowImage.size.width, arrowImage.size.height)];
//    arrowImageView.image = arrowImage;
//    [self addSubview:arrowImageView];
    
}

- (UILabel *)separatorlabel {
    UILabel * separatorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    separatorLabel.backgroundColor = [UIColor clearColor];
    separatorLabel.text = @"|";
    separatorLabel.textColor = UIColorFromRGB(0xaeb2ce);
    separatorLabel.font = [UIFont fontWithName:PCFontQuicksandBold size:18];
    [separatorLabel sizeToFit];
    return separatorLabel;
}

- (void)initButtons {
    
    //NSArray * buttonNames = @[@"TOUT", @"ARCHIVÉS", @"GRATUIT", @"PHOTO", @"BD", @"VIDÉO", @"COURT", @"REPORTAGES"];
   
    
    self.allTags = [[self staticTags] arrayByAddingObjectsFromArray:self.tags];
    
    //remove old first
    for (UIView * view in self.buttonsArray) {
        [view removeFromSuperview];
    }
    [self.buttonsArray removeAllObjects];
    
    
    int i = 0;
    CGFloat buttonHeight = 44;
    CGFloat previousButtonX = 0;
    int buttonsCount = self.allTags.count;
    for (PCTag * tag in self.allTags) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.exclusiveTouch = YES;
        button.frame = CGRectMake(previousButtonX, 4, 0, 0);
        button.backgroundColor = [UIColor clearColor];
        button.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
        button.titleLabel.font = [UIFont fontWithName:PCFontQuicksandBold size:18];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [button setTitleColor:UIColorFromRGB(0x91b4d7) forState:UIControlStateSelected];
        [button setTitle:tag.tagTitle forState:UIControlStateNormal];
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
            button.userInteractionEnabled = NO;
        }
        
        
        i++;
    }
    
    UIButton * lastButton = [self.buttonsArray lastObject];
    self.scrollView.contentSize = CGSizeMake(lastButton.frame.origin.x  + lastButton.frame.size.width, self.scrollView.contentSize.height);
}

#pragma mark - Actions

- (void)selectFirstTag {
    if (self.buttonsArray.count) {
        UIButton * button = self.buttonsArray[0];
        [self buttonAction:button];
    }
}

- (void)buttonAction:(UIButton *)sender {
    
    sender.selected = YES;
    sender.userInteractionEnabled = NO;
    self.selectedButton.selected = NO;
    self.selectedButton.userInteractionEnabled = YES;
    self.selectedButton = sender;
    
    if([self.delegate respondsToSelector:@selector(kioskFooterView:didSelectTag:)]) {
        NSString * tagString = [self.selectedButton titleForState:UIControlStateNormal];
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"tagTitle LIKE %@", tagString];
        
        PCTag * tag = [[self.allTags filteredArrayUsingPredicate:predicate] lastObject];
        
        [self.delegate kioskFooterView:self didSelectTag:tag];
    }
}

- (void)arrowAction:(UIButton *)sender
{
    self.scrollView.userInteractionEnabled = NO;
    
    NSTimeInterval tickInteval = 0.01;
    BOOL isDirectionLeft = (sender == self.rightArrowButton);
    
    [NSTimer scheduledTimerWithTimeInterval:tickInteval target:self selector:@selector(scrollingTimerTick:) userInfo:@{@"isDirectionLeft" :[NSNumber numberWithBool:isDirectionLeft]} repeats:YES];
    
}

- (void) scrollingTimerTick:(NSTimer*)timer
{
    static const float speedPicsPerSec = 500;
    
    BOOL directionIsLeft = [timer.userInfo[@"isDirectionLeft"] boolValue];
    BOOL shouldContinue = (directionIsLeft ? _rightArrowButton.isHighlighted : _leftArrowButton.isHighlighted);
    
    if(shouldContinue)
    {
        float stepLength = speedPicsPerSec * timer.timeInterval;
        
        float leftOffset = self.scrollView.contentOffset.x;
        float rightOffset = self.scrollView.contentSize.width - leftOffset - self.scrollView.bounds.size.width;
        
        float maxPossibleStep = directionIsLeft ? rightOffset : leftOffset;
        
        stepLength = stepLength > maxPossibleStep ? maxPossibleStep : stepLength;
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + (directionIsLeft ? stepLength : -stepLength), self.scrollView.contentOffset.y)];
    }
    else
    {
        self.scrollView.userInteractionEnabled = YES;
        [timer invalidate];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat buttonWidth = 50.0f;
    CGFloat contentOffsetXLeft = scrollView.contentOffset.x;
    
    contentOffsetXLeft = MIN(MAX(0, contentOffsetXLeft), buttonWidth);
    CGFloat leftAlpha = contentOffsetXLeft / buttonWidth;
    self.leftFadeImageView.alpha = leftAlpha;
    
    CGFloat contentOffsetXRight = scrollView.contentSize.width - scrollView.contentOffset.x - scrollView.bounds.size.width;
    
    contentOffsetXRight = MIN(MAX(0, contentOffsetXRight), buttonWidth);
    CGFloat rightAlpha = contentOffsetXRight / buttonWidth;
    self.rightFadeImageView.alpha = rightAlpha;
    
    if(_leftArrowButton.isHighlighted || _rightArrowButton.isHighlighted)
    {
        
    }
    else
    {
        [scrollView setContentOffset:scrollView.contentOffset];
    }
}

@end
