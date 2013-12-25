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

@interface PCPageViewController ()

- (void) hideSubviews;

@end

@interface PCHTMLPageViewController ()
{
    //    BOOL _webViewVisible;
    @public
    PCLandscapeViewController* _webViewController;
}

//- (void)showBrowser;
//- (void)hideBrowser;

@end

@interface RueHTMLPageViewController ()
{
    UIWebView* _webView;
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
    
    //[NSURLCache setSharedURLCache:[[NSURLCache alloc]initWithMemoryCapacity:15 diskCapacity:30 diskPath:@"customCache"]];
    
    [[NSURLCache sharedURLCache]setMemoryCapacity:5000];
    
    if (_webViewController == nil) {
        PCPageElementHtml *pageElement =(PCPageElementHtml *)[self.page firstElementForType:PCPageElementTypeHtml];
        
//        NSString* str = nil;
        
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
                
//                str = [NSString stringWithContentsOfFile:[outputDirectory stringByAppendingPathComponent:@"index.html"] encoding:NSUTF8StringEncoding error:nil];
            }
            
            //[zipArchive release];
        }
        
        _webViewController = [[PCLandscapeViewController alloc] init];
        
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
        
        UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView setFrame:CGRectMake((webView.frame.size.width-activityView.frame.size.width)/2, (webView.frame.size.height-activityView.frame.size.height)/2, activityView.frame.size.width, activityView.frame.size.height)];
        [activityView setTag:100];
        [activityView startAnimating];
        [_webViewController.view addSubview:activityView];
        //[activityView release];
        
        //url = [NSURL fileURLWithPath:@"URL: file:///Users/maks/Library/Application%20Support/iPhone%20Simulator/7.0/Applications/B9B0D571-C2A7-4F53-A665-CB1F90D02A15/Library/PrivateDocuments/application-104/issue-506/revision-623/element/00/01/02/60/resource/diapo.html?v=0.03"];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2147483647];
        //        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        
        
//        [webView loadHTMLString:str baseURL:nil];
        
        [webView loadRequest:request];
        
        //[webView release];
        
//        double delayInSeconds = 6.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            
//            [self removeContentFromDisk];
//            [[NSURLCache sharedURLCache] removeAllCachedResponses];
//            [webView reload];
//        });
        
        
    }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"loading request : %@", request.debugDescription);
    
//    static NSURLRequest* currentRequest = nil;
//    
//    if(currentRequest)
//    {
//        if([currentRequest.URL.absoluteString isEqualToString:request.URL.absoluteString])
//        {
//            return YES;
//        }
//        else
//        {
//            [webView stopLoading];
//            NSMutableURLRequest* newRequest = [NSMutableURLRequest requestWithURL:request.URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
//            
//            currentRequest = newRequest;
//            [webView loadRequest:newRequest];
//            return NO;
//        }
//    }
//    else
//    {
//        currentRequest = request;
//        return YES;
//    }
//    
//    
//    
//    
    return YES;
}

- (void) hideSubviews
{
    [super hideSubviews];
    
    if(_webView)
    {
        //[self removeContentFromDisk];
        
        //[_webView goBack];
        //[_webView goBack];
        [_webView loadHTMLString:@"about:blank" baseURL:nil];
        [_webView stopLoading];
        _webView.delegate = nil;
//        [_webView reload];
        [_webView removeFromSuperview];
//        [_webView stopLoading];
        _webView = nil;
    }
//    NSLog(@"cache : %i", [[NSURLCache sharedURLCache] currentMemoryUsage]);
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


- (void) removeContentFromDisk
{
    PCPageElementHtml *pageElement =(PCPageElementHtml *)[self.page firstElementForType:PCPageElementTypeHtml];
    
    NSURL *url = nil;
    
    if (pageElement.htmlUrl != nil)
    {
        url = [NSURL URLWithString:pageElement.htmlUrl];
    }
    else
    {
        NSString *archivePath = [[page.revision contentDirectory] stringByAppendingPathComponent:pageElement.resource];
        
//        ZipArchive *zipArchive = [[ZipArchive alloc] init];
//        BOOL openFileResult = [zipArchive UnzipOpenFile:archivePath];
        
//        if (openFileResult)
//        {
            NSString *outputDirectory = [[archivePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"resource"];
            
            
            
//            [zipArchive UnzipFileTo:outputDirectory overWrite:YES];
//            url = [NSURL fileURLWithPath:[outputDirectory stringByAppendingPathComponent:@"index.html"]];
        
//            [zipArchive UnzipCloseFile];
        
        NSError* err = nil;
        [[NSFileManager defaultManager] removeItemAtPath:outputDirectory error:&err];
        NSLog(@"%@", err.localizedDescription);
//        }
        
        //[zipArchive release];
    }
    
    
    
}

@end

@implementation PCHTMLPageViewController (MemoryOptimization)

- (void)loadFullView
{
    [super loadFullView];
}

@end