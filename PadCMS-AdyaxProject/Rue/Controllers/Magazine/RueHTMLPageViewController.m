//
//  RueHTMLPageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/18/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueHTMLPageViewController.h"
#import "PCPageControllersManager.h"
#import "PCPageTemplatesPool.h"
#import "ZipArchive.h"
#import "PCPageElemetTypes.h"
#import "PCPageViewController+IsPresented.h"

@interface PCPageViewController ()

- (void) hideSubviews;

@end

@interface PCHTMLPageViewController ()
{
    //    BOOL _webViewVisible;
    @public
    PCLandscapeViewController* _webViewController;
}

- (void) showBrowser;
//- (void)hideBrowser;

@end

@interface RueHTMLPageViewController ()
{
    UIWebView* _webView;
    NSURL* _URL;
}

@end

@implementation RueHTMLPageViewController

+ (void) load
{
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCHTMLPageTemplate]];
}

- (void)loadFullView
{
    [super loadFullView];
    
    if (_webViewController == nil)
    {
        PCPageElementHtml *pageElement =(PCPageElementHtml *)[self.page firstElementForType:PCPageElementTypeHtml];
        
        NSURL *url = nil;
        if (pageElement.htmlUrl != nil) {
            url = [NSURL URLWithString:pageElement.htmlUrl];
        } else {
            
            NSString *archivePath = [[page.revision contentDirectory] stringByAppendingPathComponent:pageElement.resource];
            
            ZipArchive *zipArchive = [[ZipArchive alloc] init];
            BOOL openFileResult = [zipArchive UnzipOpenFile:archivePath];
            
            if (openFileResult)
            {
                NSString *outputDirectory = [[archivePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"resource"];
                
                [zipArchive UnzipFileTo:outputDirectory overWrite:YES];
                url = [NSURL fileURLWithPath:[outputDirectory stringByAppendingPathComponent:@"index.html"]];
                
                [zipArchive UnzipCloseFile];
            }
        }
        
        _URL = url;
        
        _webViewController = [[PCLandscapeViewController alloc] init];
        
        CGRect      webViewRect;
        
        if (self.columnViewController.horizontalOrientation) {
            webViewRect = CGRectMake(0, 0, 768, 1024);
        } else {
            webViewRect = CGRectMake(0, 0, 1024, 786);
        }
        
        UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView setFrame:CGRectMake((webViewRect.size.width-activityView.frame.size.width)/2, (webViewRect.size.height-activityView.frame.size.height)/2, activityView.frame.size.width, activityView.frame.size.height)];
        [activityView setTag:100];
        [activityView startAnimating];
        [_webViewController.view addSubview:activityView];
        
        
        [self loadWebView];
    }
    if(_webView == nil)
    {
        [self loadWebView];
    }
}

- (void) loadWebView
{
    CGRect      webViewRect;
    
    if (self.columnViewController.horizontalOrientation) {
        webViewRect = CGRectMake(0, 0, 768, 1024);
    } else {
        webViewRect = CGRectMake(0, 0, 1024, 786);
    }
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:webViewRect];
    webView.backgroundColor = [UIColor blackColor];
    [webView setDelegate:self];
    _webView = webView;
    
    [_webViewController.view addSubview:webView];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2147483647];

    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    request.HTTPShouldHandleCookies = NO;
    
    [webView loadRequest:request];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"loading request : %@", request.debugDescription);
    return YES;
}

- (void) showBrowser
{
    if([self isPresentedPage])
    {
        [super showBrowser];
    }
}

- (void) hideSubviews
{
    [super hideSubviews];
    
    if(_webView)
    {
        [_webView loadHTMLString:@"about:blank" baseURL:nil];
        [_webView stopLoading];
        _webView.delegate = nil;
        [_webView removeFromSuperview];
        _webView = nil;
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end

@implementation PCHTMLPageViewController (MemoryOptimization)

- (void)loadFullView
{
    [super loadFullView];
}

@end