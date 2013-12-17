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

@property (nonatomic, weak) PCPageViewController* pageController;

@end

@implementation GifViewController

+ (id) controllerForElement:(PCPageElement*)element inPageViewController:(PCPageViewController*)pageController
{
    GifViewController* controller = [[self alloc]initWithElement:element];
    controller.pageController = pageController;
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
    CGRect rect = [element rectForElementType:@"gif"];
    
    if (!CGRectEqualToRect(rect, CGRectZero))
    {
        CGSize pageSize = [self.pageController.columnViewController pageSizeForViewController:self.pageController];
        float scale = pageSize.width/element.size.width;
        rect.size.width *= scale;
        rect.size.height *= scale;
        rect.origin.x *= scale;
        rect.origin.y *= scale;
        rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
        
    }
    return rect;
}

@end
