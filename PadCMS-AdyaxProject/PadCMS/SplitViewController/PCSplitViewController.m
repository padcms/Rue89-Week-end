//
//  PCSplitViewController.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCSplitViewController.h"

#import "PCTopBarButtonView.h"

//#define TopBarHeight 67.5f
#define TopBarHeight 75
#define TopBarOverlap 10
// Master view will take MasterWidthRatio * 100 percent of split view width (31.25% is 320 points)
#define MasterWidthRatio 0.3125
#define BarButtonsSpacing 10

#define ButtonBackgroundImage @"top-bar-button-background.png"
#define ButtonSubstrateImage @"top-bar-button-substrate.png"

@interface PCSplitViewController ()
{
    UIView *_topBarView;
    UIPopoverController *_popoverController;
    PCTopBarButtonView *_popoverButtonView;
    NSMutableArray *_leftBarButtons;
    NSMutableArray *_rightBarButtons;
}

- (void)popoverButtonTapped:(UIButton *)sender;
- (void)layoutViews;
- (void)animateViewsLayoutForInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration;
- (void)layoutBarButtons;
- (void)animateBarButtonsLayoutForInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                              duration:(NSTimeInterval)duration;

@end


@implementation PCSplitViewController

@synthesize masterViewController = _masterViewController;
@synthesize detailViewController = _detailViewController;

#pragma mark - public class methods 

+ (PCTopBarButtonView *)topBarButtonViewWithImage:(UIImage *)image title:(NSString *)title size:(CGSize)size
{
    UIFont *buttonFont = [UIFont boldSystemFontOfSize:13];
    UIColor *buttonTextColor = [UIColor blackColor];
    
    PCTopBarButtonView *topBarButtonView = [[PCTopBarButtonView alloc] init];
    topBarButtonView.frame = CGRectMake(0, 0, size.width, size.height);
    topBarButtonView.button.frame = CGRectMake(0, 0, size.width, size.height);
    topBarButtonView.button.titleLabel.font = buttonFont;
    topBarButtonView.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [topBarButtonView.button setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [topBarButtonView.button setImage:image forState:UIControlStateNormal];
    [topBarButtonView.button setTitle:title forState:UIControlStateNormal];
    
    
    UIImage *resizableBackgroundImage = [[UIImage imageNamed:ButtonBackgroundImage] 
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [topBarButtonView.button setBackgroundImage:resizableBackgroundImage 
                                       forState:UIControlStateNormal];
    [topBarButtonView setSubstrateImage:[UIImage imageNamed:ButtonSubstrateImage]];
    
    return [topBarButtonView autorelease];
}

#pragma mark - private

- (void)dealloc
{
    [_leftBarButtons release];
    [_rightBarButtons release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        _topBarView = nil;
        _popoverController = nil;
        _popoverButtonView = nil;
        _masterViewController = nil;
        _detailViewController = nil;
        _leftBarButtons = [[NSMutableArray alloc] init];
        _rightBarButtons = [[NSMutableArray alloc] init];;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutViews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self animateViewsLayoutForInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self animateBarButtonsLayoutForInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)popoverButtonTapped:(UIButton *)sender
{
    [_masterViewController.view removeFromSuperview];
    _popoverController = [[UIPopoverController alloc] initWithContentViewController:_masterViewController];
    _popoverController.delegate = self;
    [_popoverController presentPopoverFromRect:sender.frame 
                                        inView:self.view 
                      permittedArrowDirections:UIPopoverArrowDirectionUp 
                                      animated:YES];
}

#pragma mark subviews

- (void)layoutViews
{
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self animateViewsLayoutForInterfaceOrientation:currentInterfaceOrientation 
                                           duration:0];
}

- (void)animateViewsLayoutForInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
    CGSize windowSize = [UIApplication sharedApplication].delegate.window.frame.size;
    
    CGRect newTopBarFrame;
    CGRect newMasterFrame;
    CGRect newDetailFrame;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        newTopBarFrame = CGRectMake(0, 0, windowSize.height, TopBarHeight);
        
        CGFloat masterLeft = 0;
        CGFloat masterTop = TopBarHeight - TopBarOverlap;
        CGFloat masterWidth = windowSize.height * MasterWidthRatio;
        CGFloat masterHeight = windowSize.width - TopBarHeight - TopBarOverlap;
        newMasterFrame = CGRectMake(masterLeft, masterTop, masterWidth, masterHeight);
        
        CGFloat detailLeft = masterWidth;
        CGFloat detailTop = TopBarHeight - TopBarOverlap;
        CGFloat detailWidth = windowSize.height - masterWidth;
        CGFloat detailHeight = windowSize.width - TopBarHeight - TopBarOverlap;
        newDetailFrame = CGRectMake(detailLeft, detailTop, detailWidth, detailHeight);
        
        if (![self.view.subviews containsObject:_masterViewController.view])
        {
            [self.view addSubview:_masterViewController.view];
            _masterViewController.view.autoresizingMask = UIViewAutoresizingNone;
        }
        
        [self dismissPopoverViewControllerAnimated:NO];
        
        _popoverButtonView.hidden = YES;
    }
    else
    {
        newTopBarFrame = CGRectMake(0, 0, windowSize.width, TopBarHeight);
        
        CGFloat masterLeft = -(windowSize.width * MasterWidthRatio);
        CGFloat masterTop = TopBarHeight - TopBarOverlap;
        CGFloat masterWidth = windowSize.width * MasterWidthRatio;
        CGFloat masterHeight = windowSize.height - TopBarHeight - TopBarOverlap;
        newMasterFrame = CGRectMake(masterLeft, masterTop, masterWidth, masterHeight);
        
        CGFloat detailLeft = 0;
        CGFloat detailTop = TopBarHeight - TopBarOverlap;
        CGFloat detailWidth = windowSize.width;
        CGFloat detailHeight = windowSize.height - TopBarHeight - TopBarOverlap;
        newDetailFrame = CGRectMake(detailLeft, detailTop, detailWidth, detailHeight);
        
        _popoverButtonView.hidden = NO;
    }
    
    [UIView animateWithDuration:duration animations:^{
        
        _topBarView.frame = newTopBarFrame;
        [self.view bringSubviewToFront:_topBarView];
        
        if (_masterViewController != nil) {
            _masterViewController.view.frame = newMasterFrame;
        }
        
        if (_detailViewController != nil) {
            _detailViewController.view.frame = newDetailFrame;
        }
    }];
    
    [self animateBarButtonsLayoutForInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark bar buttons

- (void)layoutBarButtons
{
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self animateBarButtonsLayoutForInterfaceOrientation:currentInterfaceOrientation duration:0];
}

- (void)animateBarButtonsLayoutForInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                              duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        
        // layout popover button
        CGSize popoverButtonSize = _popoverButtonView.frame.size;
        CGFloat popoverButtonLeft = 20;
        
        if (![_topBarView.subviews containsObject:_popoverButtonView]) 
        {
            [_topBarView addSubview:_popoverButtonView];
        }
        _popoverButtonView.frame = CGRectMake(popoverButtonLeft, 
                                              0, 
                                              popoverButtonSize.width, 
                                              _topBarView.bounds.size.height);
        
        // layout left buttons
        CGFloat buttonOffset = 20 - BarButtonsSpacing;
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        {
            buttonOffset = _popoverButtonView.frame.origin.x + _popoverButtonView.frame.size.width;
        }        
        
        for (PCTopBarButtonView *buttonView in _leftBarButtons)
        {
            if (![_topBarView.subviews containsObject:buttonView])
            {
                [_topBarView addSubview:buttonView];
            }
            
            CGSize currentButtonSize = buttonView.frame.size;
            CGFloat currentButtonLeft = buttonOffset + BarButtonsSpacing;

            buttonView.frame = CGRectMake(currentButtonLeft, 
                                          0, 
                                          currentButtonSize.width, 
                                          _topBarView.frame.size.height);
            buttonOffset = buttonView.frame.origin.x + buttonView.frame.size.width;
        }
        
        // layout right buttons
        CGFloat previousButtonLeft = _topBarView.frame.size.width - 20 + BarButtonsSpacing;
        NSUInteger rightButtonsLastIndex = _rightBarButtons.count - 1;
        for (NSInteger index = rightButtonsLastIndex; index >= 0; index--)
        {
            PCTopBarButtonView *currentButtonView = [_rightBarButtons objectAtIndex:index];
            if (![_topBarView.subviews containsObject:currentButtonView])
            {
                [_topBarView addSubview:currentButtonView];
            }
            
            CGSize currentButtonSize = currentButtonView.frame.size;
            CGFloat currentButtonLeft = previousButtonLeft - currentButtonSize.width - BarButtonsSpacing;

            currentButtonView.frame = CGRectMake(currentButtonLeft, 
                                                 0, 
                                                 currentButtonSize.width, 
                                                 _topBarView.frame.size.height);
            previousButtonLeft = currentButtonView.frame.origin.x;
        }
        
    }];
}

#pragma mark - public

- (void)setMasterViewController:(UIViewController *)masterViewController
{
    if (_masterViewController != masterViewController)
    {
        [_masterViewController.view removeFromSuperview];
        [_masterViewController release];
        _masterViewController = [masterViewController retain];
        [self.view addSubview:_masterViewController.view];
        _masterViewController.view.autoresizingMask = UIViewAutoresizingNone;
    }
}

- (void)setDetailViewController:(UIViewController *)detailViewController
{
    if (_detailViewController != detailViewController)
    {
        [_detailViewController.view removeFromSuperview];
        [_detailViewController release];
        _detailViewController = [detailViewController retain];
        [self.view addSubview:_detailViewController.view];
        _detailViewController.view.autoresizingMask = UIViewAutoresizingNone;
    }
}

#pragma mark - bar buttons

- (void)setTopBarView:(UIView *)view
{
    if (_topBarView != view)
    {
        [_topBarView removeFromSuperview];
        [_topBarView release];
        _topBarView = [view retain];
        [self.view addSubview:_topBarView];
        [self layoutViews];
        [self layoutBarButtons];
    }
}

- (void)setPopoverButtonView:(PCTopBarButtonView *)buttonView
{
    if (_popoverButtonView != buttonView && buttonView != nil)
    {
        [_popoverButtonView.button removeTarget:self action:@selector(popoverButtonTapped:) 
                               forControlEvents:UIControlEventTouchUpInside];
        [_popoverButtonView removeFromSuperview];
        [_popoverButtonView release];
        _popoverButtonView = [buttonView retain];
        
        [_popoverButtonView.button addTarget:self action:@selector(popoverButtonTapped:) 
                            forControlEvents:UIControlEventTouchUpInside];
        [self layoutBarButtons];
    }
}

- (void)addLeftBarButton:(PCTopBarButtonView *)buttonView
{
    if ([_leftBarButtons containsObject:buttonView]) 
    {
        return;
    }
    
    [_leftBarButtons addObject:buttonView];
    [_topBarView addSubview:buttonView];
    [self layoutBarButtons];
}

- (void)insertLeftBarButton:(PCTopBarButtonView *)buttonView atIndex:(NSUInteger)index;
{
    if ([_leftBarButtons containsObject:buttonView]) 
    {
        return;
    }
    
    if (index < _leftBarButtons.count)
    {
        [_leftBarButtons insertObject:buttonView atIndex:index];
    }
    else
    {
        [_leftBarButtons addObject:buttonView];
    }
    
    [_topBarView addSubview:buttonView];
    [self layoutBarButtons];
}

- (void)removeLeftBarButton:(PCTopBarButtonView *)buttonView
{
    if ([_leftBarButtons containsObject:buttonView])
    {
        return;
    }
    
    [buttonView removeFromSuperview];
    [_leftBarButtons removeObject:buttonView];
    [self layoutBarButtons];
}

- (void)addRightBarButton:(UIButton *)buttonView
{
    if ([_rightBarButtons containsObject:buttonView])
    {
        return;
    }
    
    [_rightBarButtons addObject:buttonView];
    [_topBarView addSubview:buttonView];
    [self layoutBarButtons];
}

- (void)insertRightBarButton:(PCTopBarButtonView *)buttonView atIndex:(NSUInteger)index
{
    if ([_rightBarButtons containsObject:buttonView]) 
    {
        return;
    }
    
    if (index < _rightBarButtons.count)
    {
        [_rightBarButtons insertObject:buttonView atIndex:index];
    }
    else
    {
        [_rightBarButtons addObject:buttonView];
    }
    
    [_topBarView addSubview:buttonView];
    [self layoutBarButtons];
}

- (void)removeRightBarButton:(PCTopBarButtonView *)buttonView
{
    if ([_rightBarButtons containsObject:buttonView])
    {
        return;
    }
    
    [buttonView removeFromSuperview];
    [_rightBarButtons addObject:buttonView];
    [self layoutBarButtons];
}

- (void)dismissPopoverViewControllerAnimated:(BOOL)animated
{
    if (_popoverController != nil)
    {
        [_popoverController dismissPopoverAnimated:animated];
    }
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [_masterViewController.view removeFromSuperview];
}

@end
