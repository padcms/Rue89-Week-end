//
//  RueBrowserViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueBrowserViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomAnimation.h"
//#import <MediaPlayer/MediaPlayer.h>
#import "AnimatableWebView.h"

typedef enum{
    WebViewPresentationStateWindow,
    WebViewPresentationStateFullscreen,
    WebViewPresentationStateChanging
}WebViewPresentationState;

@interface PCBrowserViewController ()

- (void) showHUD;
- (void) createWebView;

@end

@interface RueBrowserViewController ()
{
    UIDeviceOrientation _currentWebViewOrientation;
    WebViewPresentationState _currentWebViewPresentationState;
    //BOOL _isFullScreen;
    CustomAnimation* _webViewAnimation;
}
//@property (nonatomic, strong) MPMoviePlayerController* player;

@end

@implementation RueBrowserViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //self.view.frame = self.videoRect;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self createWebView];
//    [self createReturnButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [self hideHUD];
//    [self backButtonTap];
    
    [super viewDidDisappear:animated];
}

- (void)presentURL:(NSString *)url
{
    [self createWebView];
    self.videoURL = [NSURL URLWithString:url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.videoURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:240.0]];
//    [self showHUD];
    
//    self.player = [[MPMoviePlayerController alloc] initWithContentURL:self.videoURL];
    
//    self.player.view.frame = self.videoRect;
    
//    [self.view addSubview:self.player.view];

//    [self subscribeForPlayerNotification];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self subscribeForDeviceNitifications];
    
//    [self.player play];
    
}

- (void) stop
{
//    [self.player stop];
//    [self.player.view removeFromSuperview];
    [self unsubscribeForDeviceNitifications];
//    [self unsubscribeForPlayerNotification];
//    self.player = nil;
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    self.webView = nil;
}

- (void)createWebView
{
    _webView = [[AnimatableWebView alloc] initWithFrame:self.videoRect];
    _webView.delegate = self;
    
    _webView.scrollView.scrollEnabled = NO;
    _webView.scrollView.bounces = NO;
    [self.view addSubview:_webView];
    
    _webView.backgroundColor = [UIColor yellowColor];
    
    [self createFullScreenButton];
}

- (void) createFullScreenButton
{
    float btnWidth = 100;
    float btnHeight = 50;
    
    UIButton *fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullScreenButton addTarget:self action:@selector(fullScreenButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    fullScreenButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [fullScreenButton setFrame:CGRectMake(_webView.frame.size.width - btnWidth, _webView.frame.size.height - btnHeight, btnWidth, btnHeight)];
    
    [_webView addSubview:fullScreenButton];
    
    fullScreenButton.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:0.5];
}

- (void) fullScreenButtonTap:(UIButton*)sender
{
    sender.enabled = NO;
    
    if(_currentWebViewPresentationState == WebViewPresentationStateFullscreen)
    {
        [self unmakeWebViewFullScreenCompletion:^{
            
            sender.enabled = YES;
        }];
    }
    else if(_currentWebViewPresentationState == WebViewPresentationStateWindow)
    {
        [self makeWebViewFullScreenCompletion:^{
            
            _currentWebViewOrientation = [UIApplication sharedApplication].statusBarOrientation;
            [self checkForOrientation];
            sender.enabled = YES;
        }];
    }
}

- (void) makeWebViewFullScreenCompletion:(void(^)())completion
{
    _currentWebViewPresentationState = WebViewPresentationStateChanging;
    [self changeWebViewFrame:self.view.bounds animatedWithDuration:0.3 completion:^{
        
        _currentWebViewPresentationState = WebViewPresentationStateFullscreen;
        self.view.backgroundColor = [UIColor blackColor];
        if(completion)
        {
            completion();
        }
    }];
}

- (void) unmakeWebViewFullScreenCompletion:(void(^)())completion
{
    _currentWebViewPresentationState = WebViewPresentationStateChanging;
    self.view.backgroundColor = [UIColor clearColor];
    [self changeWebViewFrame:self.videoRect animatedWithDuration:0.3 completion:^{
        
        _currentWebViewPresentationState = WebViewPresentationStateWindow;
        if(completion)
        {
            completion();
        }
    }];
}

- (void) checkForOrientation
{
    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    if(_currentWebViewPresentationState == WebViewPresentationStateFullscreen && currentDeviceOrientation != _currentWebViewOrientation)
    {
        [self rotateWebViewToOrientation:currentDeviceOrientation animatedWithDuration:0.5 completion:^{
            
            [self checkForOrientation];
        }];
    }
}

#pragma mark - UIWebView Protocol

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL absoluteURL] isEqual:[self.videoURL absoluteURL]]) {
        return YES;
    }
    
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [super webViewDidFinishLoad:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
}

#pragma mark - Notifications

//- (void) subscribeForPlayerNotification
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidEnterFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:self.player];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidExitFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:self.player];
//}

//- (void) unsubscribeForPlayerNotification
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidEnterFullscreenNotification object:self.player];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:self.player];
//}

- (void) subscribeForDeviceNitifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) unsubscribeForDeviceNitifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

//- (void) playerDidEnterFullscreen:(NSNotification*)notif
//{
//    NSLog(@"%@", notif);
//}
//
//- (void) playerDidExitFullscreen:(NSNotification*)notif
//{
//    NSLog(@"%@", notif);
//}

- (void) deviceOrientationDidChange:(NSNotification*)notif
{
    if(_currentWebViewPresentationState == WebViewPresentationStateFullscreen)
    {
        [self checkForOrientation];
    }
}

#pragma mark - Animations

- (void) changeWebViewFrame:(CGRect)newFrame animatedWithDuration:(NSTimeInterval)duration completion:(void(^)())completion
{
    _webView.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webView.scrollView.backgroundColor = [UIColor blueColor];
    
    [UIView animateWithDuration:duration animations:^{
        
        _webView.frame = newFrame;
        _webView.scrollView.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
        _webView.scrollView.contentSize = CGSizeMake(newFrame.size.width, newFrame.size.height);
        
    } completion:^(BOOL finished) {
        
        if(completion) completion();
    }];
    
    
    return;
    
    if(_webViewAnimation)
    {
        [_webViewAnimation invalidate];
    }
    
    _webViewAnimation = [[CustomAnimation alloc]initForView:_webView duration:duration finalFrame:newFrame finalTransform:_webView.transform];
    
    [_webViewAnimation performWithCompletion:completion];
    
    return;
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:_webView.layer.bounds];
    animation.toValue = [NSValue valueWithCGRect:newFrame];
    animation.duration = duration;
    
    [_webView.layer addAnimation:animation forKey:@"bounds"];
}

- (void) rotateWebViewToOrientation:(UIDeviceOrientation)toOrientation animatedWithDuration:(NSTimeInterval)duration completion:(void(^)())completion
{
    _currentWebViewPresentationState = WebViewPresentationStateChanging;
    
    void(^complete)() = ^{
        _currentWebViewPresentationState = WebViewPresentationStateFullscreen;
        _currentWebViewOrientation = toOrientation;
        if(completion) completion();
    };
    
    float angle = 0;
    setAngleFromOrientationToOrientation(& angle, _currentWebViewOrientation, toOrientation);
    
    CGRect newWebViewRect = CGRectMake(0, 0, 768, 1024);
    
    [UIView animateWithDuration:duration animations:^{
        
        _webView.transform = CGAffineTransformMakeRotation(angle);
        _webView.frame = newWebViewRect;
        
        
    } completion:^(BOOL finished) {
        
        complete();
    }];
}

void setAngleFromOrientationToOrientation(float * angle, UIDeviceOrientation fromOrientation, UIDeviceOrientation toOrientation)
{
    UIDeviceOrientation applicationOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    switch (toOrientation)
    {
        case UIDeviceOrientationPortrait:
        {
            *angle = 0;
            return;
        }
            
        case UIDeviceOrientationPortraitUpsideDown:
        {
            *angle = 0;
            return;
        }
            
        case UIDeviceOrientationLandscapeLeft:
        {
            if(applicationOrientation == UIDeviceOrientationPortrait)
            {
                *angle = M_PI_2;
                return;
            }
            else
            {
                *angle = -M_PI_2;
                return;
            }
        }
            
        case UIDeviceOrientationLandscapeRight:
        {
            if(applicationOrientation == UIDeviceOrientationPortrait)
            {
                *angle = -M_PI_2;
                return;
            }
            else
            {
                *angle = M_PI_2;
                return;
            }
        }
            
        default:
            *angle = 0;
            return;
    }
}

@end
