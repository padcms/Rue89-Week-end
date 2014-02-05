//
//  RueHorizontalScrollingPageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/4/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "RueHorizontalScrollingPageViewController.h"
#import "PCHorizontalPageElementViewController.h"
#import "PCSCrollView.h"
#import "PCConfig.h"
#import "PCStyler.h"
#import "PCDefaultStyleElements.h"
#import "PCPageControllersManager.h"
//#import "PCPageElementActiveZone.h"
//#import "PCPageElemetTypes.h"

@interface PCScrollingPageViewController()
{
    @protected
    PCScrollView *_paneScrollView;
    PCPageElementViewController *_paneContentViewController;
    UIButton *_scrollDownButton;
    UIButton *_scrollUpButton;
}

- (void)initializeScrollButtons;
- (void)deinitializeScrollButtons;
- (void)updateScrollButtons;

- (void)scrollDownButtonTapped:(UIButton *)sender;
- (void)scrollUpButtonTapped:(UIButton *)sender;

@end

@interface RueHorizontalScrollingPageViewController ()
{
//    PCScrollView *_paneScrollView;
//    PCHorizontalPageElementViewController *_paneContentViewController;
    UIButton *_scrollRightButton;
    UIButton *_scrollLeftButton;
}
//
//- (void)initializeScrollButtons;
//- (void)deinitializeScrollButtons;
//- (void)updateScrollButtons;
//
- (void)scrollLeftButtonTapped:(UIButton *)sender;
- (void)scrollRightButtonTapped:(UIButton *)sender;

@end

@implementation RueHorizontalScrollingPageViewController

+ (void) load
{
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[RueHorizontalScrollingPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCHorizontalScrollingPageTemplate]];
}

-(void)loadView
{
    [super loadView];
}

- (void) loadFullView
{
    [super loadFullView];
    
    [_paneScrollView setContentSize:CGSizeMake([_paneContentViewController.view frame].size.width, 1)];
    [self updateScrollButtons];
    _paneScrollView.scrollEnabled = YES;
}

- (void) unloadFullView
{
    [super unloadFullView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

- (PCPageElementViewController*) createPaneContentViewControllerForResource:(NSString *)fullResource
{
    PCHorizontalPageElementViewController* paneContentController = [[PCHorizontalPageElementViewController alloc] initWithResource:fullResource];
    if (self.page.revision.horizontalOrientation)
    {
        paneContentController.targetHeight = 768;
    }
    else
    {
        paneContentController.targetHeight = 1024;
    }
    return paneContentController;
}

- (void) initializeScrollButtons
{
    if ([PCConfig isScrollingPageHorizontalScrollButtonsDisabled]) {
        return;
    }
    
    NSDictionary *buttonOption = nil;
    UIColor *pageColor = self.page.color;
    if (pageColor != nil) {
        buttonOption = [NSDictionary dictionaryWithObject:self.page.color
                                                   forKey:PCButtonTintColorOptionKey];
    }
    // Scroll right button
    _scrollRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [[PCStyler defaultStyler] stylizeElement:_scrollRightButton withStyleName:PCScrollControlKey
                                 withOptions:buttonOption];
    
    CGRect paneScrollViewFrame = _paneScrollView.frame;
    CGRect scrollRightButtonFrame =
    CGRectMake(paneScrollViewFrame.origin.x + paneScrollViewFrame.size.width - _scrollRightButton.frame.size.height,
               paneScrollViewFrame.origin.y + (paneScrollViewFrame.size.height - _scrollRightButton.frame.size.width) / 2,
               _scrollRightButton.frame.size.height,
               _scrollRightButton.frame.size.width);
    
    _scrollRightButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _scrollRightButton.frame = scrollRightButtonFrame;
    [_scrollRightButton addTarget:self action:@selector(scrollRightButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:_scrollRightButton];
    
    _scrollLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[PCStyler defaultStyler] stylizeElement:_scrollLeftButton
                               withStyleName:PCScrollControlKey
                                 withOptions:buttonOption];
    
    // Scroll left button
    CGRect  scrollLeftButtonFrame =
    CGRectMake(paneScrollViewFrame.origin.x,
               paneScrollViewFrame.origin.y + (paneScrollViewFrame.size.height - _scrollLeftButton.frame.size.width) / 2,
               _scrollLeftButton.frame.size.height,
               _scrollLeftButton.frame.size.width);
    
    _scrollLeftButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [_scrollLeftButton setFrame:scrollLeftButtonFrame];
    [_scrollLeftButton addTarget:self action:@selector(scrollLeftButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:_scrollLeftButton];
    
    [self updateScrollButtons];
}

- (void)deinitializeScrollButtons
{
    if (_scrollLeftButton != nil) {
        [_scrollLeftButton removeFromSuperview];
        _scrollLeftButton = nil;
    }
    
    if (_scrollRightButton != nil) {
        [_scrollRightButton removeFromSuperview];
        _scrollRightButton = nil;
    }
}

- (void)updateScrollButtons
{
    _paneScrollView.scrollEnabled = YES;
    
    if (_scrollLeftButton) {
        _scrollLeftButton.hidden = _paneScrollView.contentOffset.x <= 0;
    }
    
    if (_scrollRightButton) {
        _scrollRightButton.hidden = (_paneScrollView.contentOffset.x >=
                                     _paneScrollView.contentSize.width - _paneScrollView.frame.size.width);
    }
}

- (void)scrollLeftButtonTapped:(UIButton *)sender
{
    [_paneScrollView scrollLeft];
    [self updateScrollButtons];
}

- (void)scrollRightButtonTapped:(UIButton *)sender
{
    [_paneScrollView scrollRight];
    [self updateScrollButtons];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _paneScrollView) {
        if (scrollView.decelerating) {
            return;
        }
        
        if (scrollView.contentOffset.x < 0) {
            _paneScrollView.scrollEnabled = NO;
            [self.magazineViewController showPrevColumn];
            return;
        }
        
        if (scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width) {
            _paneScrollView.scrollEnabled = NO;
            [self.magazineViewController showNextColumn];
            return;
        }
        
        [self updateScrollButtons];
    }
}

@end
