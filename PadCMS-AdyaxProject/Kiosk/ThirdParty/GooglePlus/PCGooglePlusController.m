//
//  PCGooglePlusController.m
//  Pad CMS
//
//  Created by Martyniuk.M on 9/23/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCGooglePlusController.h"
#import "NSURL+Fragments.h"
#import "UIView+EasyFrame.h"
//API key:
//AIzaSyA43Kfcq6uke0fTNz3tSUwtcqpo2ZOvEzo
//Referers:
//Any referer allowed
//Activated on: 	Sep 23, 2013 6:48 AM
//Activated by: 	iostest4@gmail.com – you

//Client ID:
//1061550701781.apps.googleusercontent.com
//Client secret:
//es7pY7efaLpNFm2QD9CK-g_j


@interface PCGooglePlusController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, copy) void(^comleteShareBlock)(UIView* dialogView);

@end



@implementation PCGooglePlusController

static PCGooglePlusController* controller;

static NSString* google_client_id = @"1061550701781-ms4glu29lh2kgqv3q6gfg44t2a84bi2r.apps.googleusercontent.com";
static NSString* google_client_secret = @"es7pY7efaLpNFm2QD9CK-g_j";
static NSString* google_sharing_url = @"http://gfgdjk.com";

static NSString* api_end_point = @"https://www.googleapis.com/plus/v1/";
static NSString* authorization_end_point = @"https://accounts.google.com/o/oauth2/auth";
static NSString* authorization_redirect_uri = @"https://complete.com/login_complete";
static NSString* share_redirect_uri = @"https://complete.com/share_complete";



- (void) shareWithDialog:(void(^)(UIView* dialogView))dialogBlock complete:(void(^)(UIView* dialogView))completionBlock
{
    self.webView = [[UIWebView alloc]init];
    self.webView.delegate = self;
    
    self.comleteShareBlock = completionBlock;
    
    [self cleareCookie];
    
    
    NSMutableString* urlString = [NSMutableString stringWithString:authorization_end_point];
    
    NSString* scope = @"https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile";
    //login_hint
    //page, popup, touch, and wap.
    
    NSString* params = [NSString stringWithFormat:@"redirect_uri=%@&response_type=token&client_id=%@&state=authorization&scope=%@&display=touch", authorization_redirect_uri, google_client_id, scope];
    
    [urlString appendFormat:@"?%@", params];
    NSURL* requestUrl = [[NSURL alloc]initWithString:urlString];
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    
    [self.webView loadRequest:request];
    
    dialogBlock(self.webView);
    
    
}

- (void) authorizationTokenTaken:(NSString*)token
{
    NSLog(@"Token is : %@", token);
    
    NSMutableString* urlString = [NSMutableString stringWithString:@"https://plus.google.com/share"];
    
    //NSString* url = @"m.facebook.com";
    
    NSString* params = [NSString stringWithFormat:@"continue=%@&client_id=%@&text=gg&access_token=%@&display=wap", share_redirect_uri, google_client_id, token];
    
    [urlString appendFormat:@"?%@", params];
    NSURL* requestUrl = [[NSURL alloc]initWithString:urlString];
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    
    [self.webView loadRequest:request];
    
    
    
}

- (void) getUserInfoWithToken:(NSString*)token
{
    NSMutableString* urlString = [NSMutableString stringWithString:@"https://plus.google.com/share"];
    
    
    NSString* params = [NSString stringWithFormat:@"continue=%@&client_id=%@&text=gg&access_token=%@", share_redirect_uri, google_client_id, token];
    
    [urlString appendFormat:@"?%@", params];
    NSURL* requestUrl = [[NSURL alloc]initWithString:urlString];
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    
    [self.webView loadRequest:request];
}

- (void) cleareCookie
{
    static NSString* googleAccountsDomain = @"accounts.google.com";
    static NSString* googleMainDomain = @".google.com.ua";
    static NSString* googleDomain = @".google.com";
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie  in [cookieJar cookies])
    {
        NSLog(@"coockie : %@", cookie.domain);
        if([cookie.domain isEqualToString:googleAccountsDomain] || [cookie.domain isEqualToString:googleMainDomain] || [cookie.domain isEqualToString:googleDomain])
        {
            [cookieJar deleteCookie:cookie];
        }
    }
}

#pragma mark - WebViewDelegate Protocol

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", request.URL.absoluteString);
    
    if([request.URL.path isEqualToString:@"/login_complete"])
    {
        NSDictionary* redirectParams = request.URL.queryFragments;
        NSLog(@"params : %@", redirectParams.debugDescription);
        NSString* token = redirectParams[@"access_token"];
        [self authorizationTokenTaken:token];
        return NO;
    }
    else if([request.URL.path isEqualToString:@"/share_complete"])
    {
        if(self.comleteShareBlock) self.comleteShareBlock(webView);
        return NO;
    }
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //webView.frameWidth = webView.scrollView.contentSize.width;
    
    /*if(webView == self.sendMessageWebView)
    {
        if(self.sendMessageDialogBlock)
        {
            self.sendMessageDialogBlock(webView, nil);
            self.sendMessageDialogBlock = nil;
        }
    }
    else
    {
        if(self.getAccountDialogBlock)
        {
            self.getAccountDialogBlock(webView);
            self.getAccountDialogBlock = nil;
        }
    }*/
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"google Web View error : %@", error.debugDescription);
}

@end