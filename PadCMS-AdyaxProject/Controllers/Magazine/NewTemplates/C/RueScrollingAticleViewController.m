//
//  RueScrollingAticleViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueScrollingAticleViewController.h"
#import "PCPage.h"
#import "PCPageElementViewController.h"
#import "PCScrollView.h"

@interface RueScrollingAticleViewController ()

@property (nonatomic, strong) PCScrollView* mainScrollView;
//@property (nonatomic, strong) PCPageElement* pageElement;

@end

@implementation RueScrollingAticleViewController


//- (id) initForContent:(PCPageElementViewController*)contentViewController
//{
//    self = [super init];
//    if(self)
//    {
////        self.pageElement = element;
//        self.contentViewController = contentViewController;
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    self.view.backgroundColor = [UIColor clearColor];
    
    self.mainScrollView  = [[PCScrollView alloc] initWithFrame:self.view.bounds];
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.bounces = YES;
    self.mainScrollView.pagingEnabled = NO;
    self.mainScrollView.alwaysBounceVertical = NO;
    self.mainScrollView.alwaysBounceHorizontal = NO;
    self.mainScrollView.clipsToBounds = YES;
    self.mainScrollView.verticalScrollButtonsEnabled = YES;
    self.mainScrollView.backgroundColor = [UIColor clearColor];
    //self.mainScrollView.contentSize = self.contentViewController.view.frame.size;
    
    [self.view addSubview:self.mainScrollView];
    //[self.mainScrollView addSubview:self.contentViewController.view];
    
//    NSString *fullResource = [self.page.revision.contentDirectory stringByAppendingPathComponent:element.resource];
//    
//    PCPageElementViewController* slideView = [[PCPageElementViewController alloc] initWithResource:fullResource];
//    slideView.element = element;
//    [self.miniArticleViews addObject:slideView];
//    
//    [slideView release];
}

- (void) setContentViewController:(PCPageElementViewController *)contentViewController
{
    if(_contentViewController != contentViewController)
    {
        if(_contentViewController)
        {
            [_contentViewController.view removeFromSuperview];
        }
        
        _contentViewController = contentViewController;
        
        if(contentViewController)
        {
            [self.mainScrollView setContentSize:contentViewController.view.frame.size];
            [self.mainScrollView addSubview:contentViewController.view];
        }
    }
}

@end
