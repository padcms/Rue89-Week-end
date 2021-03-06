//
//  PCGooglePlusController.m
//  Pad CMS
//
//  Created by Martyniuk.M on 9/23/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCGooglePlusController.h"
#import "NSURL+Fragments.h"

@interface PCGooglePlusController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, copy) void(^comleteShareBlock)(UIView* dialogView);
@property (nonatomic, copy) void(^comleteAuthorizationBlock)(UIView* dialogView);

@property (nonatomic, strong) NSString* postMessage;
@property (nonatomic, strong) NSString* postUrl;

@end



@implementation PCGooglePlusController

static NSString* google_client_id = @"585237059531-t6jvb2j14nnkm7k32viafrmciocjgk29.apps.googleusercontent.com";
//static NSString* google_client_secret = @"es7pY7efaLpNFm2QD9CK-g_j";
//static NSString* api_end_point = @"https://www.googleapis.com/plus/v1/";
static NSString* authorization_end_point = @"https://accounts.google.com/o/oauth2/auth";
static NSString* authorization_redirect_uri = @"https://complete.com/login_complete";
static NSString* share_redirect_uri = @"https://complete.com/share_complete";

//static NSString* post_text = @"Good app.";
//static NSString* post_url = @"http://facebook.com";

- (id) initWithMessage:(NSString*)postMessage postUrl:(NSString*)urlPath
{
    self = [super init];
    if(self)
    {
        self.postMessage = @"";
        if(postMessage && [postMessage isKindOfClass:[NSString class]] && postMessage.length)
        {
            self.postMessage = postMessage;
        }
        self.postUrl = @"http://google.com";
        if(urlPath && [urlPath isKindOfClass:[NSString class]] && urlPath.length)
        {
            self.postUrl = urlPath;
        }
    }
    return self;
}

- (void) shareWithDialog:(void(^)(UIView* dialogView))dialogBlock authorizationComplete:(void(^)(UIView* dialogView))authComplBlock complete:(void(^)(UIView* dialogView))completionBlock
{
    self.webView = [[UIWebView alloc]init];
    self.webView.clipsToBounds = YES;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.comleteShareBlock = completionBlock;
    self.comleteAuthorizationBlock = authComplBlock;
    
    [self cleareCookie];
    
    
    NSMutableString* urlString = [NSMutableString stringWithString:authorization_end_point];
    
    NSString* scope = @"https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fplus.me"; //https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile";
    //login_hint
    
    NSString* params = [NSString stringWithFormat:@"redirect_uri=%@&response_type=token&client_id=%@&state=authorization&scope=%@", authorization_redirect_uri, google_client_id, scope];
    
    [urlString appendFormat:@"?%@", params];
    NSURL* requestUrl = [[NSURL alloc]initWithString:urlString];
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    
    [self.webView loadRequest:request];
    
    dialogBlock(self.webView);
    
    
}

- (void) authorizationTokenTaken:(NSString*)token
{
    if(token)
    {
        NSMutableString* urlString = [NSMutableString stringWithString:@"https://plus.google.com/share"];
        
        NSString* params = [NSString stringWithFormat:@"continue=%@&client_id=%@&text=%@&url=%@&access_token=%@", share_redirect_uri, google_client_id, [self.postMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self.postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], token];
        
        [urlString appendFormat:@"?%@", params];
        NSURL* requestUrl = [[NSURL alloc]initWithString:urlString];
        NSURLRequest* request = [[NSURLRequest alloc]initWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
        
        [self.webView loadRequest:request];
        
        if(self.comleteAuthorizationBlock)
        {
            self.comleteAuthorizationBlock(self.webView);
        }
    }
    else
    {
        if(self.comleteShareBlock)
        {
            self.comleteShareBlock(self.webView);
        }
    }
}

- (void) getUserInfoWithToken:(NSString*)token
{
    /*NSMutableString* urlString = [NSMutableString stringWithString:@"https://plus.google.com/share"];
    
    
    NSString* params = [NSString stringWithFormat:@"continue=%@&client_id=%@&text=gg&access_token=%@", share_redirect_uri, google_client_id, token];
    
    [urlString appendFormat:@"?%@", params];
    NSURL* requestUrl = [[NSURL alloc]initWithString:urlString];
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    
    [self.webView loadRequest:request];*/
}

- (void) cleareCookie
{
    static NSString* googleAccountsDomain = @"accounts.google.com";
    static NSString* googleMainDomain = @".google.fr";
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
    //NSLog(@"%@", request.URL.absoluteString);
    //NSLog(@"params : %@", request.URL.queryFragments);
    
    if([request.URL.path isEqualToString:@"/login_complete"])
    {
        NSDictionary* redirectParams = request.URL.queryFragments;
        //NSLog(@"params : %@", redirectParams.debugDescription);
        NSString* token = redirectParams[@"access_token"];
        [self authorizationTokenTaken:token];
        return NO;
    }
    else if([request.URL.path isEqualToString:@"/share_complete"])
    {
        if(self.comleteShareBlock) self.comleteShareBlock(webView);
        return NO;
    }
    else if([request.URL.path isEqualToString:@"/accounts/SetSID"])
    {
        if(self.comleteAuthorizationBlock)
        {
            self.comleteAuthorizationBlock(self.webView);
            self.comleteAuthorizationBlock = nil;
        }
    }
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"google Web View error : %@", error.debugDescription);
}

@end
