//
//  RueHorizontalScrollingBrowserViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/31/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "RueHorizontalScrollingBrowserViewController.h"
#import "UIView+EasyFrame.h"

@interface RueBrowserViewController ()
{
//    UIDeviceOrientation _currentWebViewOrientation;
//    WebViewPresentationState _currentWebViewPresentationState;
//    
//    CustomAnimation* _webViewAnimation;
    @public
    UIView* _currentPlayerView;
}

- (CGRect) defaultVideoRect;
- (void) makeWebViewFullScreenCompletion:(void(^)())completion;
- (void) unmakeWebViewFullScreenCompletion:(void(^)())completion;

@end

@interface RueHorizontalScrollingBrowserViewController ()

@end

@implementation RueHorizontalScrollingBrowserViewController

- (void) setVideoRect:(CGRect)videoRect
{
    [super setVideoRect:videoRect];
    float newViewX = videoRect.origin.x + videoRect.size.width / 2 - self.view.frame.size.width / 2;
    self.view.frameX = newViewX;
}

- (CGRect) defaultVideoRect
{
    CGRect frame = [super defaultVideoRect];
    frame.origin.x -= self.view.frameX;
    return frame;
}

- (void) makeWebViewFullScreenCompletion:(void(^)())completion
{
    self.view.frameX = 0;
    
    [super makeWebViewFullScreenCompletion:completion];
//    
//    _currentWebViewPresentationState = WebViewPresentationStateChanging;
//    
//    self.view.frameY = 0;
//    
//    CGRect newWebRect = [self defaultVideoRect];
//    
//    _currentPlayerView.frame = newWebRect;
//    
//    [self.pageView addSubview:self.view];
//    
//    [self changeWebViewFrame:self.view.bounds animatedWithDuration:0.3 completion:^{
//        
//        _currentWebViewPresentationState = WebViewPresentationStateFullscreen;
//        self.view.backgroundColor = [UIColor blackColor];
//        if(completion)
//        {
//            completion();
//        }
//    }];
}

- (void) unmakeWebViewFullScreenCompletion:(void(^)())completion
{
    self.view.frameX = self.mainScrollView.contentOffset.x - self.mainScrollView.frameX;
    
    [super unmakeWebViewFullScreenCompletion:completion];
//    _currentWebViewPresentationState = WebViewPresentationStateChanging;
//    self.view.backgroundColor = [UIColor clearColor];
//    
//    self.view.frameY = self.mainScrollView.contentOffset.y;
//    [self.mainScrollView addSubview:self.view];
//    
//    CGRect newWebRect = [self defaultVideoRect];
//    
//    [self changeWebViewFrame:newWebRect animatedWithDuration:0.3 completion:^{
//        
//        _currentWebViewPresentationState = WebViewPresentationStateWindow;
//        if(completion)
//        {
//            completion();
//        }
//    }];
}

@end
