//
//  PCKioskPageControl.m
//  Pad CMS
//
//  Created by tar on 28.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskPageControl.h"
#import "PCFonts.h"
#import "PCKioskSHelfSettings.h"

#import <QuartzCore/QuartzCore.h>

const CGFloat kElementWidth = 46.0f;
const CGFloat kElementHeight = 40.0f;

const CGFloat kSeparatorWidth = 15.0f;

const CGFloat kPadding = 3.0f;

enum {
    SeparatorTypeLeft = 1,
    SeparatorTypeRight = 2,
};
typedef int SeparatorType;

@interface PCKioskPageControl() {
    NSMutableArray * elements;
}

@end


@implementation PCKioskPageControl

+ (PCKioskPageControl *)pageControl {
    CGFloat maxWidth = kElementWidth * 5 + kSeparatorWidth * 2;
    PCKioskPageControl * pageControl = [[PCKioskPageControl alloc] initWithFrame:CGRectMake(0, 0, maxWidth, kElementHeight)];
    return pageControl;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentPage = 1;
        elements = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Helpers

- (UIButton *)pageControlElementWithNumber:(NSInteger)number {
    UIButton * element = [UIButton buttonWithType:UIButtonTypeCustom];
    element.tag = number;
    element.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    [element setTitleColor:UIColorFromRGB(0xaeb2ce) forState:UIControlStateNormal];
    [element setTitleColor:UIColorFromRGB(0xf6f8fa) forState:UIControlStateSelected];
    [element setTitle:[NSString stringWithFormat:@"%d", number] forState:UIControlStateNormal];
    [element addTarget:self action:@selector(elementTapped:) forControlEvents:UIControlEventTouchUpInside];
    [element.titleLabel setFont:[UIFont fontWithName:PCFontQuicksandBold size:32.5f]];
    
    element.backgroundColor = UIColorFromRGB(0xf6f8fa);
    
    CALayer * layer = element.layer;
    layer.borderColor = UIColorFromRGB(0xaeb2ce).CGColor;
    layer.borderWidth = 2.5f;
    layer.cornerRadius = 6.0f;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.2f;
    layer.shadowRadius = 2.0f;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shouldRasterize = YES;
    
    
    
    return element;
}

- (UIButton *)separatorElement {
    UIButton * element = [UIButton buttonWithType:UIButtonTypeCustom];
    element.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
    [element setTitle:@"..." forState:UIControlStateNormal];
    [element.titleLabel setFont:[UIFont fontWithName:PCFontQuicksandBold size:20]];
    [element setTitleColor:UIColorFromRGB(0xaeb2ce) forState:UIControlStateNormal];
    element.enabled = NO;
    element.adjustsImageWhenDisabled = NO;
    return element;
}

- (CGFloat)totalElementsWidthForPage:(NSInteger)page {
    

    if (_pagesCount > 5) {
        //1,2, last - 1, last
        if ((page <= 2) || (page >= _pagesCount-1)) {
            return kElementWidth * 4 + kSeparatorWidth + kPadding * 4;
        }
        
        else
            
            //3, last - 2
            if ((page == 3) || (page == _pagesCount-2)) {
                return kElementWidth * 5 + kSeparatorWidth+ kPadding * 5;
            }
        
        //bigger than 3, less than last - 2
            else {
                return kElementWidth * 5 + kSeparatorWidth * 2 + kPadding * 6;
            }
    } else {
        return kElementWidth * _pagesCount + kPadding * (_pagesCount-1);
    }
}

- (CGFloat)centeredX {
    return self.frame.size.width/2 - [self totalElementsWidthForPage:_currentPage]/2;
}

- (BOOL)shouldShowSeparator:(SeparatorType)separatorType {
    BOOL shouldShowAnySeparator = (_pagesCount > 5);
    
    if (shouldShowAnySeparator) {
        if (separatorType == SeparatorTypeLeft) {
            if (_currentPage > 3) {
                return YES;
            }
        } else if (separatorType == SeparatorTypeRight) {
            if (_currentPage < _pagesCount - 2) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)removeAllElements {
    for (UIView * element in elements) {
        [element removeFromSuperview];
    }
    
    [elements removeAllObjects];
}

- (void)createViewsForPage:(NSInteger)page {
    
    [self removeAllElements];
    
    //first element
    UIButton * firstElement = [self pageControlElementWithNumber:1];
    firstElement.frame = CGRectMake([self centeredX], 0, kElementWidth, kElementHeight);
    [self addSubview:firstElement];
    [elements addObject:firstElement];
    
    if (_pagesCount > 1) {
        //last element
        UIButton * lastElement = [self pageControlElementWithNumber:_pagesCount];
        lastElement.frame = CGRectMake([self centeredX] + [self totalElementsWidthForPage:_currentPage] - kElementWidth, 0, kElementWidth, kElementHeight);
        [self addSubview:lastElement];
        [elements addObject:lastElement];
    }

    
    //other elements
    if ((_pagesCount > 2)) {
        if ((_pagesCount <= 5)) {
            
            CGFloat x = CGRectGetMaxX(firstElement.frame);
            x+=kPadding;
            NSInteger startPage = 2;
            NSRange range = NSMakeRange(startPage, _pagesCount - startPage);
            [self createElementsWithRange:range startX:x];
//            for (int i = startPage; i <= _pagesCount - 1; i++) {
//                UIButton * button = [self pageControlElementWithNumber:i];
//                button.frame = CGRectMake(x, 0, kElementWidth, kElementHeight);
//                [self addSubview:button];
//                [elements addObject:button];
//                x+= kElementWidth;
//            }
        } else {
            CGFloat x = CGRectGetMaxX(firstElement.frame) + kPadding;
            
            if ([self shouldShowSeparator:SeparatorTypeLeft]) {
                x += kSeparatorWidth + kPadding;
            }
            
            NSInteger startPage = _currentPage - 1;
            NSInteger length = 3;
            
            if (_currentPage < 3) {
                length = 2;
                
                if (_currentPage == 1) {
                    startPage += 2;
                } else if (_currentPage == 2) {
                    startPage += 1;
                }
            
            } else if ( _currentPage > _pagesCount - 2) {
                length = 2;
                
                if (_currentPage == _pagesCount) {
                    startPage -= 1;
                }
            }
            
            NSRange range = NSMakeRange(startPage, length);
            
            [self createElementsWithRange:range startX:x];
        }
    }
    
    
    //separators
    [self createSeparators];
    
    //select current page
    [self selectCurrentPageButton];
    
}

- (void)createElementsWithRange:(NSRange)range startX:(CGFloat)x {
    for (int i = range.location; i < range.location + range.length; i++) {
        UIButton * button = [self pageControlElementWithNumber:i];
        button.frame = CGRectMake(x, 0, kElementWidth, kElementHeight);
        [self addSubview:button];
        [elements addObject:button];
        x+= kElementWidth + kPadding;
    }
}

- (void)createSeparators {
    
    
    if ([self shouldShowSeparator:SeparatorTypeLeft]) {
        UIButton * leftSeparator = [self separatorElement];
        leftSeparator.frame = CGRectMake([self centeredX] + kElementWidth + kPadding, 0, kSeparatorWidth, kElementHeight);
        [self addSubview:leftSeparator];
        [elements addObject:leftSeparator];
    }
    
    if ([self shouldShowSeparator:SeparatorTypeRight]) {
        UIButton * rightSeparator = [self separatorElement];
        rightSeparator.frame = CGRectMake([self centeredX] + [self totalElementsWidthForPage:_currentPage]  - kElementWidth - kSeparatorWidth - kPadding, 0, kSeparatorWidth, kElementHeight);
        [self addSubview:rightSeparator];
        [elements addObject:rightSeparator];
    }
}

- (void)selectCurrentPageButton {
    for (UIButton * button in elements) {
        if (button.tag == _currentPage) {
            button.selected = YES;
            button.backgroundColor = UIColorFromRGB(0xaeb2ce);
        }
    }
}

#pragma mark - Button actions

- (void)elementTapped:(UIButton *)sender {
    NSInteger page = sender.tag;
    
    [self setCurrentPage:page];
}

#pragma mark - Setters

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    
    [self createViewsForPage:currentPage];
    
    if ([self.delegate respondsToSelector:@selector(kioskPageControl:didChangePage:)]) {
        [self.delegate kioskPageControl:self didChangePage:_currentPage];
    }
}

- (void)setPagesCount:(NSInteger)pagesCount {
    _pagesCount = pagesCount;
    
    [self createViewsForPage:_currentPage];
}

@end
