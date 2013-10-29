//
//  PCRueRevisionViewController.m
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueRevisionViewController.h"
#import "PCRevisionSummaryPopup.h"
#import "PCTMainViewController.h"

#import "PCScrollView.h"

@interface PCRueRevisionViewController () <PCRevisionSummaryPopupDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) PCRevisionSummaryPopup * summaryPopup;

@end

@implementation PCRueRevisionViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        
//    }
//    return self;
//}

- (NSArray*) sortedListOfAllDownloadedRevisions
{
    NSMutableArray* allRev = [NSMutableArray arrayWithArray:[(PCTMainViewController*)self.mainViewController allDownloadedRevisions]];
    [allRev removeObject:self.revision];
    return [NSArray arrayWithArray:allRev];
}

- (void) viewDidDisappear:(BOOL)animated
{
    //owerrided for keeping controller alive
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self addLeftSwipeToBackGesture];
}

- (void) fadeInViewWithDuration:(NSTimeInterval)duration completion:(void(^)())complBlock
{
    void(^fadeIn)() = ^{
        
        self.mainScrollView.alpha = 0.0;
    };
    
    if(duration)
    {
        [UIView animateWithDuration:duration animations:^{
            
            fadeIn();
            
        } completion:^(BOOL finished) {
            
            if(complBlock) complBlock();
        }];
    }
    else
    {
        fadeIn();
        if(complBlock)complBlock();
    }
}

- (void) fadeOutViewWithDuration:(NSTimeInterval)duration completion:(void(^)())complBlock
{
    void(^fadeOut)() = ^{
        
        self.mainScrollView.alpha = 1.0;
    };
    
    if(duration)
    {
        [UIView animateWithDuration:duration animations:^{
            
            fadeOut();
            
        } completion:^(BOOL finished) {
            
            if(complBlock) complBlock();
        }];
    }
    else
    {
        fadeOut();
        if(complBlock)complBlock();
    }
}

- (void) showSummaryMenuAnimated:(BOOL)animated
{
    [self.summaryPopup setRevisionsList:[self sortedListOfAllDownloadedRevisions]];
    [self.summaryPopup showAnimated:animated completion:nil];
}


- (void) hideSummaryMenuAnimated:(BOOL)animated
{
    [self.summaryPopup hideAnimated:animated completion:nil];
}

- (void)addLeftSwipeToBackGesture
{
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandler:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    swipe.delegate = self;
    [self.view addGestureRecognizer:swipe];
}

#pragma mark - Gesture recognizer delagete

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (((UIScrollView *)self.mainScrollView).contentOffset.x > 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(self.summaryPopup.frame, [touch locationInView:self.summaryPopup])) {
        return NO;
    }
    
    return YES;
}

#pragma mark - HUD (top summary view for Rue) Overrides

- (void)createHUDView {
    
    NSLog(@"TOC %@", self.revision.toc);
    
    self.summaryPopup = [[PCRevisionSummaryPopup alloc] initWithSize:CGSizeMake(self.view.frame.size.width, 146) viewToShowIn:self.view tocItems:self.revision.toc];
    [self.summaryPopup setPresentationStyle:PCKioskPopupPresentationStyleFromTop];
    [self.summaryPopup setDelegate:self];
}

- (void)destroyHUDView {
    [super destroyHUDView];
    

}

#pragma mark - Transition

- (void)switchToKiosk {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - tap handler

- (void)tapGesture:(UIGestureRecognizer *)recognizer
{
    if (self.summaryPopup.isShown)
    {
        [self.summaryPopup hide];
    }
}

#pragma mark - Left swipe handler

- (void)leftSwipeHandler:(UISwipeGestureRecognizer *)recognizer
{
    if (self.summaryPopup.isShown)
    {
        [self.summaryPopup hide];
    }
    [self topBarView:nil backButtonTapped:nil];
}

#pragma mark - PCRevisionSummaryPopupDelegate

- (void)revisionSummaryPopupDidTapHomeButton:(PCRevisionSummaryPopup *)popup {
    if (self.summaryPopup.isShown)
    {
        [self.summaryPopup hide];
    }
    [self topBarView:nil backButtonTapped:nil];
}

- (void)revisionSummaryPopupDidTapMenuButton:(PCRevisionSummaryPopup *)popup
{
    if (!self.summaryPopup.isShown)
    {
        [self.summaryPopup setRevisionsList:[self sortedListOfAllDownloadedRevisions]];
        [self.summaryPopup show];
    }
    else
    {
        [self.summaryPopup hide];
    }
}

- (void)revisionSummaryPopup:(PCRevisionSummaryPopup *)popup didSelectIndex:(NSInteger)index {
    [self hudView:nil didSelectIndex:index];
}

- (void) revisionSummaryPopup:(PCRevisionSummaryPopup *)popup didSelectRevision:(PCRevision *)revision
{
    //[popup hide];
    [(PCTMainViewController*)self.mainViewController switchToRevision:revision];
}

@end
