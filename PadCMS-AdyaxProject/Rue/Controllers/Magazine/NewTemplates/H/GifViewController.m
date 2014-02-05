//
//  GifViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "GifViewController.h"
#import "PCPageElement.h"
#import "PCPage.h"
#import "PCPageViewController.h"

@interface GifViewController ()

@property (nonatomic, strong) UIWebView* webView;

@property (nonatomic, strong) PCPageElement* pageElement;
@property (nonatomic, assign) CGRect gifRect;
@property (nonatomic, weak) PCPageViewController* pageController;

@end

@implementation GifViewController

+ (id) controllerForElement:(PCPageElement*)element withFrame:(CGRect)frame inPageViewController:(PCPageViewController*)pageController
{
    GifViewController* controller = [[self alloc]init];
    controller.pageElement = element;
    controller.gifRect = frame;
    controller.pageController = pageController;
    return controller;
}

- (void) startShowing
{
    NSString* fullResource = [self.pageElement.page.revision.contentDirectory stringByAppendingPathComponent:self.pageElement.resource];
    NSURL* resourceUrl = [NSURL fileURLWithPath:fullResource];
    NSURLRequest* request = [NSURLRequest requestWithURL:resourceUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:0];
    [self.webView loadRequest:request];
}

- (void) stopShowing
{
    [self.webView stopLoading];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = self.gifRect;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = NO;
    
    self.webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;

    [self.view addSubview:self.webView];
}


@end
