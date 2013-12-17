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

@end

@implementation RueScrollingAticleViewController

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
    
    [self.view addSubview:self.mainScrollView];
}

- (void) setContentViewController:(PCPageElementViewController *)contentViewController
{
    if(_contentViewController != contentViewController)
    {
        if(_contentViewController)
        {
            [_contentViewController.view removeFromSuperview];
            [_contentViewController unloadView];
        }
        
        _contentViewController = contentViewController;
        
        if(contentViewController)
        {
            [contentViewController loadFullView];
            CGSize contentSize = contentViewController.view.frame.size;
            
            //[self.mainScrollView setContentOffset:CGPointZero animated:YES];
            [self.mainScrollView addSubview:contentViewController.view];
            
            [self.mainScrollView setContentSize:contentSize];
        }
    }
}

@end
