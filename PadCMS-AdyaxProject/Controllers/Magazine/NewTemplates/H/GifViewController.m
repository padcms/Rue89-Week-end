//
//  GifViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "GifViewController.h"
#import "PCPageElement.h"

@interface GifViewController ()

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, strong) PCPageElement* pageElement;

@end

@implementation GifViewController

+ (id) controllerForElement:(PCPageElement*)element
{
    GifViewController* controller = [[self alloc]initWithElement:element];
    return controller;
}

- (id) initWithElement:(PCPageElement*)element
{
    self = [super init];
    if(self)
    {
        self.pageElement = element;
    }
    return self;
}

- (void) startShowing
{
    NSURL* resourceUrl = [NSURL URLWithString:self.pageElement.resource];
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
    
    self.view.frame = [self rectFromPageElement:self.pageElement];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = NO;
    
    self.webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor clearColor];
}

- (CGRect) rectFromPageElement:(PCPageElement*)element
{
#warning TODO
    return CGRectMake(20, 20, 100, 100);
}

@end
