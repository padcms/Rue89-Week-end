//
//  RueScrollingPaneViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/29/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueScrollingPaneViewController.h"
#import "PCPageElement.h"
#import "PCPage.h"

@interface RueScrollingPaneViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIImageView* imageView;

@property (nonatomic, copy) NSString* resource;
@property (nonatomic, assign) CGRect zone;

@end

@implementation RueScrollingPaneViewController

+ (id) controllerForElement:(PCPageElement*)element atZone:(CGRect)zone
{
    RueScrollingPaneViewController* controller = [[self alloc]init];
    controller.resource = [element.page.revision.contentDirectory stringByAppendingPathComponent:element.resource];
    controller.zone = zone;
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = self.zone;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.clipsToBounds = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.delaysContentTouches = YES;
    self.scrollView.autoresizesSubviews = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingNone;
    
    [self.view addSubview:self.scrollView];
}

- (void) loadFullView
{
    if(self.imageView == nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:self.resource];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.imageView = [[UIImageView alloc] initWithImage:image];
                self.imageView.backgroundColor = [UIColor clearColor];
                [self.scrollView addSubview:self.imageView];
                self.scrollView.contentSize = self.imageView.frame.size;
                
            });
        });
    }
}

- (void) unloadFullView
{
    if(self.imageView)
    {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
}

- (CGPoint) contentOffset
{
    return self.scrollView.contentOffset;
}

@end
