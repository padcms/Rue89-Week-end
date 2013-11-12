//
//  RueBrowserViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueBrowserViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PCBrowserViewController ()

- (void) showHUD;
- (void) createWebView;

@end

@interface RueBrowserViewController ()

@end

@implementation RueBrowserViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)presentURL:(NSString *)url
{
    [self createWebView];
    self.videoURL = [NSURL URLWithString:url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.videoURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:240.0]];
    [self showHUD];
}

- (void) stop
{
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    self.webView = nil;
}


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

@end
