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
#import "UIView+EasyFrame.h"
#import "RuePageElementVideo.h"
#import "RuePageElementSound.h"
#import "PCPage.h"
#import <MediaPlayer/MediaPlayer.h>

typedef enum{
    WebViewPresentationStateWindow,
    WebViewPresentationStateFullscreen,
    WebViewPresentationStateChanging
}WebViewPresentationState;

@interface PCBrowserViewController ()

- (void) showHUD;

@end

@interface RueBrowserViewController ()
{
    UIDeviceOrientation _currentWebViewOrientation;
    WebViewPresentationState _currentWebViewPresentationState;
    
    CustomAnimation* _webViewAnimation;
    
    UIView* _currentPlayerView;
}

@property (nonatomic, strong) MPMoviePlayerController* player;

@property (nonatomic, strong) UIButton* pauseSoundButton;

@end

@implementation RueBrowserViewController

- (void) setMainScrollView:(UIScrollView *)mainScrollView
{
    _mainScrollView = mainScrollView;
}

- (void) setVideoRect:(CGRect)videoRect
{
    _videoRect = videoRect;
    
    float newViewY = videoRect.origin.y + videoRect.size.height / 2 - self.view.frame.size.height / 2;
    
    self.view.frameY = newViewY;
    
    if(_currentPlayerView)
    {
        _currentPlayerView.frame = [self defaultVideoRect];
    }
}

- (void) setIsHorizontal:(BOOL)isHorizontal
{
    if(_isHorizontal != isHorizontal)
    {
        _isHorizontal = isHorizontal;
    
        if(isHorizontal && _currentPlayerView)
        {
            _currentPlayerView.transform = CGAffineTransformMakeRotation([self defaultRotationAngle]);
            _currentPlayerView.frame = [self defaultVideoRect];
        }
    }
}

- (float) defaultRotationAngle
{
    if(self.isHorizontal)
    {
        return M_PI_2;
    }
    else
    {
        return 0;
    }
}

- (CGRect) defaultVideoRect
{
    CGRect frame = self.videoRect;
    frame.origin.y -= self.view.frameY;
    return frame;
}

- (UIDeviceOrientation) defaultOrientation
{
    UIDeviceOrientation appOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(self.isHorizontal)
    {
        if (appOrientation == UIDeviceOrientationPortrait)
        {
            return UIDeviceOrientationLandscapeLeft;
        }
        else if (appOrientation == UIDeviceOrientationPortraitUpsideDown)
        {
            return UIDeviceOrientationLandscapeRight;
        }
        else
        {
            return appOrientation;
        }
    }
    else
    {
        return appOrientation;
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3];
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
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    _currentPlayerView = [self createWebView];
    [self createFullScreenButton];
    
    self.videoURL = [NSURL URLWithString:url];
    
    [self showHUD];
    
    _currentPlayerView.transform = CGAffineTransformMakeRotation([self defaultRotationAngle]);
    _currentPlayerView.frame = [self defaultVideoRect];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.videoURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:240.0]];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self subscribeForDeviceNitifications];
}

- (void) presentElement:(RuePageElementVideo*)element ofPage:(PCPage*)page
{
    _currentPlayerView = [self createPlayerForElement:element];
    if(element.userInteractionEnabled)
    {
        [self createFullScreenButton];
    }
    
    _currentPlayerView.transform = CGAffineTransformMakeRotation([self defaultRotationAngle]);
    _currentPlayerView.frame = [self defaultVideoRect];
    
    if(element.stream)
    {
        self.videoURL = [NSURL URLWithString:element.stream];
    }
    else
    {
        NSString* fullPath = [page.revision.contentDirectory stringByAppendingPathComponent:element.resource];
        self.videoURL = [NSURL fileURLWithPath:fullPath];
    }
    
    self.player.contentURL = self.videoURL;
    [self.player play];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self subscribeForDeviceNitifications];
}

- (void) presentSoundElement:(RuePageElementSound*)element ofPage:(PCPage*)page allowPause:(BOOL)allowPause
{
    self.player = [[MPMoviePlayerController alloc]init];
    if(element.loopSound)
    {
        self.player.repeatMode = MPMovieRepeatModeOne;
    }
    
    if (allowPause)
    {
        [self createPauseSoundButton];
    }
    
    NSString* fullPath = [page.revision.contentDirectory stringByAppendingPathComponent:element.resource];
    self.videoURL = [NSURL fileURLWithPath:fullPath];
    
    self.player.contentURL = self.videoURL;
    [self.player play];
}

- (void) createPauseSoundButton
{
    if(self.pauseSoundButton)
    {
        [self.pauseSoundButton removeFromSuperview];
        self.pauseSoundButton = nil;
    }
    
    UIButton* pauseSoundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pauseSoundButton addTarget:self action:@selector(pauseSoundButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [pauseSoundButton setFrame:[self defaultVideoRect]];
    //pauseSoundButton.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.4];
    
    self.pauseSoundButton = pauseSoundButton;
    [self.view addSubview:pauseSoundButton];
}

- (void) pauseSoundButtonTap:(UIButton*)sender
{
    if(self.player.playbackState == MPMoviePlaybackStatePlaying)
    {
        [self.player pause];
    }
    else if(self.player.playbackState == MPMoviePlaybackStatePaused || self.player.playbackState == MPMoviePlaybackStateStopped)
    {
        [self.player play];
    }
    if(self.stopOnTouch)
    {
        [sender removeFromSuperview];
    }
}

- (void) stop
{
    [self unsubscribeForDeviceNitifications];
    
    if(self.webView)
    {
        [self.webView loadHTMLString:@"about:blank" baseURL:nil];
        [self.webView stopLoading];
        self.webView.delegate = nil;
        self.webView = nil;
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
    if(self.player)
    {
        [self.player stop];
        self.player = nil;
    }
    
    if(_currentPlayerView)
    {
        [_currentPlayerView removeFromSuperview];
        _currentPlayerView = nil;
    }
}

- (UIView*) createWebView
{
    _webView = [[UIWebView alloc] initWithFrame: self.videoRect]; //[self defaultVideoRect]];
    _webView.frameY -= self.view.frameY;
    _webView.delegate = self;
    _webView.userInteractionEnabled = YES;
    _webView.scrollView.scrollEnabled = NO;
    _webView.scrollView.bounces = NO;
    
    [self.view addSubview:_webView]; 
    
    _webView.backgroundColor = [UIColor blackColor];
    
    return _webView;
}

- (UIView*) createPlayerForElement:(RuePageElementVideo*)element
{
    self.player = [[MPMoviePlayerController alloc]init];
    if(element.loopVideo)
    {
        self.player.repeatMode = MPMovieRepeatModeOne;
    }
    if(element.userInteractionEnabled)
    {
        self.player.controlStyle = MPMovieControlStyleEmbedded;
    }
    else
    {
        self.player.controlStyle = MPMovieControlStyleNone;
    }
    
    self.player.view.frame = [self defaultVideoRect];
    
    [self.view addSubview:self.player.view];
    
    return self.player.view;
}

- (BOOL) containsPoint:(CGPoint)point
{
    if(_currentWebViewPresentationState == WebViewPresentationStateFullscreen)
    {
        return CGRectContainsPoint(self.view.frame, point);
    }
    else
    {
        return CGRectContainsPoint(_currentPlayerView.frame, point);
    }
}

- (void) createFullScreenButton
{
    float btnWidth = 100;
    float btnHeight = 50;
    
    UIButton *fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullScreenButton addTarget:self action:@selector(fullScreenButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    fullScreenButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [fullScreenButton setFrame:CGRectMake(_currentPlayerView.frame.size.width - btnWidth, _currentPlayerView.frame.size.height - btnHeight, btnWidth, btnHeight)];
    
    [_currentPlayerView addSubview:fullScreenButton];
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
            
            _currentWebViewOrientation = [self defaultOrientation];
            [self checkForOrientation];
            sender.enabled = YES;
        }];
    }
}

- (void) makeWebViewFullScreenCompletion:(void(^)())completion
{
    _currentWebViewPresentationState = WebViewPresentationStateChanging;
    
    self.view.frameY = 0;
    
    CGRect newWebRect = [self defaultVideoRect];
    
    _currentPlayerView.frame = newWebRect;
    
    [self.pageView addSubview:self.view];
    
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
    
    self.view.frameY = self.mainScrollView.contentOffset.y;
    [self.mainScrollView addSubview:self.view];
    
    CGRect newWebRect = [self defaultVideoRect];
    
    [self changeWebViewFrame:newWebRect animatedWithDuration:0.3 completion:^{
        
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
    
    if(UIDeviceOrientationIsPortrait(currentDeviceOrientation) || UIDeviceOrientationIsLandscape(currentDeviceOrientation))
    {
        if(_currentWebViewPresentationState == WebViewPresentationStateFullscreen && currentDeviceOrientation != _currentWebViewOrientation)
        {
            [self rotateWebViewToOrientation:currentDeviceOrientation animatedWithDuration:0.5 completion:^{
                
                [self checkForOrientation];
            }];
        }
    }
}

#pragma mark - UIWebView Protocol

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"loading : %@", request.debugDescription);
    //if ([[request.URL absoluteURL] isEqual:[self.videoURL absoluteURL]]) {
        return YES;
    //}
    
    //return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [super webViewDidFinishLoad:webView];
    NSLog(@"web loaded : %@", webView.request.debugDescription);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
}

#pragma mark - Notifications

- (void) subscribeForDeviceNitifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) unsubscribeForDeviceNitifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

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
    if(_webViewAnimation)
    {
        [_webViewAnimation invalidate];
    }
    
    _webViewAnimation = [[CustomAnimation alloc]initForView:_currentPlayerView duration:duration finalFrame:newFrame finalTransform:_currentPlayerView.transform];
    
    [_webViewAnimation performWithCompletion:completion];
    
    CGRect newWebRect = [self defaultVideoRect];
    
    if(CGRectEqualToRect(newWebRect, newFrame))
    {
        [UIView animateWithDuration:duration animations:^{
            
            _currentPlayerView.transform = CGAffineTransformMakeRotation([self defaultRotationAngle]);
            
        }];
    }
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
        
        _currentPlayerView.transform = CGAffineTransformMakeRotation(angle);
        _currentPlayerView.frame = newWebViewRect;
        
        
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
