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
    
    self.view.frame = [self rectFromPageElement:self.pageElement];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = NO;
    
    self.webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;

    [self.view addSubview:self.webView];
}

- (CGRect) rectFromPageElement:(PCPageElement*)element
{
    NSString* rectString = [element.dataRects valueForKey:@"gif"];
    return CGRectFromString(rectString);
}

@end
