//
//  ScrollingArticleViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/7/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "ScrollingArticleViewController.h"
#import "PCScrollView.h"
#import "PCPageElementViewController.h"
#import "PCPage.h"
#import "Helper.h"
#import "RueLongPageElementViewController.h"

@interface ScrollingArticleViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) PCScrollView* mainScrollView;
@property (nonatomic, strong) PCPageElement* pageElement;
@property (nonatomic, strong) PCPageElementViewController* pageElementViewController;

@end

@implementation ScrollingArticleViewController

- (id) initWithElement:(PCPageElement *)element
{
    self = [super init];
    if(self)
    {
        self.pageElement = element;
    }
    return self;
}

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
    
    NSString *fullResource = [self.pageElement.page.revision.contentDirectory stringByAppendingPathComponent:self.pageElement.resource];
    
    PCPageElementViewController* articleContentViewController = nil;
    
    CGSize imageSize = [Helper getSizeForImage:fullResource];
    if(imageSize.height > 1024 * 3)
    {
        articleContentViewController = [[RueLongPageElementViewController alloc] initWithResource:fullResource];
        self.mainScrollView.delegate = self;
    }
    else
    {
        articleContentViewController = [[PCPageElementViewController alloc] initWithResource:fullResource];
    }
    
    [articleContentViewController setTargetWidth:self.mainScrollView.bounds.size.width];
    CGFloat backgroundWidth = articleContentViewController.view.frame.size.width;
    CGFloat backgroundHeight = articleContentViewController.view.frame.size.height;
    articleContentViewController.view.frame = CGRectMake(0, 0, backgroundWidth, backgroundHeight);
    self.pageElementViewController = articleContentViewController;
    [self.pageElementViewController loadFullViewImmediate];
    self.mainScrollView.contentSize = self.pageElementViewController.view.frame.size;
    [self.mainScrollView addSubview:self.pageElementViewController.view];
}

- (void) loadFullView
{
    [self.pageElementViewController loadFullViewImmediate];
    self.mainScrollView.contentSize = self.pageElementViewController.view.frame.size;
}

- (void) unloadFullView
{
    [self.pageElementViewController unloadView];
}

- (CGRect) activeZoneRectForType:(NSString*)zoneType
{
    CGRect rect = [self.pageElement rectForElementType:zoneType];
    if (!CGRectEqualToRect(rect, CGRectZero))
    {
        CGSize pageSize = self.mainScrollView.frame.size;
        float scale = pageSize.width/self.pageElement.size.width;
        rect.size.width *= scale;
        rect.size.height *= scale;
        rect.origin.x *= scale;
        rect.origin.y *= scale;
        rect.origin.y = self.pageElement.size.height*scale - rect.origin.y - rect.size.height;
        
        return rect;
    }
    return CGRectZero;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([self.pageElementViewController isKindOfClass:[RueLongPageElementViewController class]])
    {
        [(RueLongPageElementViewController*)self.pageElementViewController setYOffset:scrollView.contentOffset.y];
    }
}

@end
