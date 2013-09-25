//
//  PCRueRevisionViewController.m
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueRevisionViewController.h"
#import "PCRevisionSummaryPopup.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self addLeftSwipeToBackGesture];
}

- (void)addLeftSwipeToBackGesture {
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
    if (CGRectContainsPoint(self.summaryPopup.contentView.frame, [touch locationInView:self.summaryPopup.contentView])) {
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

- (void)tapGesture:(UIGestureRecognizer *)recognizer {
    if (self.summaryPopup.isShown) {
        [self.summaryPopup hide];
    }
}

#pragma mark - Left swipe handler

- (void)leftSwipeHandler:(UISwipeGestureRecognizer *)recognizer {
    [self topBarView:nil backButtonTapped:nil];
}

#pragma mark - PCRevisionSummaryPopupDelegate

- (void)revisionSummaryPopupDidTapHomeButton:(PCRevisionSummaryPopup *)popup {
    [self topBarView:nil backButtonTapped:nil];
}

- (void)revisionSummaryPopupDidTapMenuButton:(PCRevisionSummaryPopup *)popup {
    if (!self.summaryPopup.isShown) {
        [self.summaryPopup show];
    } else {
        [self.summaryPopup hide];
    }
}

- (void)revisionSummaryPopup:(PCRevisionSummaryPopup *)popup didSelectIndex:(NSInteger)index {
    [self hudView:nil didSelectIndex:index];
}

@end
