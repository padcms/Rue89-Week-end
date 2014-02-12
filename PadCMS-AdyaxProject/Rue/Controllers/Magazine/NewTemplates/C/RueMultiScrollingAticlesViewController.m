//
//  RueMultiScrollingAticlesViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueMultiScrollingAticlesViewController.h"
#import "ScrollingArticleViewController.h"
#import "PCPageActiveZone.h"
#import "PCPageElement.h"
#import "PCPageViewController.h"
#import "PCScrollView.h"

@interface RueMultiScrollingAticlesViewController ()
{
    int _currentArticleIndex;
    BOOL _isTransiting;
}

@end

@implementation RueMultiScrollingAticlesViewController

- (id) initWithElements:(NSArray*)elements
{
    self = [super init];
    if(self)
    {
        _currentArticleIndex = -1;
        
        NSMutableArray* articleViewControllers = [[NSMutableArray alloc]initWithCapacity:elements.count];
        
        for (int i = 0; i < elements.count; ++i)
        {
            PCPageElement* galleryElement = [elements objectAtIndex:i];
            [articleViewControllers addObject:[[ScrollingArticleViewController alloc] initWithElement:galleryElement]];
        }
        
        _contentViewControllers = [NSArray arrayWithArray:articleViewControllers];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    self.view.backgroundColor = [UIColor clearColor];
}

- (BOOL) isChangingArticles
{
    return _isTransiting;
}

- (int) currentArticleIndex
{
    return _currentArticleIndex;
}

- (void) setCurrentArticleIndexTo:(int)index animated:(BOOL)animated withCompletion:(void(^)())completion
{
    if(_currentArticleIndex == index)
    {
        if(completion)
        {
            completion();
        }
    }
    else
    {
        if(index >= 0 && self.contentViewControllers.count > index)
        {
            ScrollingArticleViewController* previousController = [self currentArticleController];
            
            _isTransiting = YES;
            ScrollingArticleViewController* controller = [self.contentViewControllers objectAtIndex:index];
            [controller loadFullView];
            
            void (^change)() = ^{
                [self.view addSubview:controller.view];
            };
            void (^finish)() = ^{
                _isTransiting = NO;
                [previousController.view removeFromSuperview];
                [previousController unloadFullView];
                _currentArticleIndex = index;
                if(completion)
                {
                    completion();
                }
            };
            
            if(animated)
            {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    
                    change();
                    
                } completion:^(BOOL finished) {
                    
                    finish();
                }];
            }
            else
            {
                change();
                finish();
            }
        }
        else if(completion)
        {
            completion();
        }
    }
}

- (ScrollingArticleViewController*) currentArticleController
{
    if(_currentArticleIndex >= 0 && _currentArticleIndex < self.contentViewControllers.count)
    {
        return [self.contentViewControllers objectAtIndex:_currentArticleIndex];
    }
    return nil;
}

- (void) loadFullView
{
    [[self currentArticleController] loadFullView];
}

- (void) unloadFullView
{
    for (ScrollingArticleViewController* contr in self.contentViewControllers)
    {
        [contr unloadFullView];
    }
}

- (NSArray*) activeZonesForGalleryElement:(PCPageElement*)galleryElement atPoint:(CGPoint)point inPageController:(PCPageViewController*)pageViewController
{
    NSMutableArray* activeZones = [[NSMutableArray alloc]init];
    
    if(_isTransiting) return activeZones;
    
    ScrollingArticleViewController* currentArticleController = [self currentArticleController];
    
    if(currentArticleController && currentArticleController.pageElement == galleryElement)
    {
        for (PCPageActiveZone* pdfActiveZone in galleryElement.activeZones)
        {
            CGRect rect = pdfActiveZone.rect;
            if (!CGRectEqualToRect(rect, CGRectZero))
            {
                CGSize pageSize = [pageViewController.columnViewController pageSizeForViewController:pageViewController];
                float scale = pageSize.width/galleryElement.size.width;
                rect.size.width *= scale;
                rect.size.height *= scale;
                rect.origin.x *= scale;
                rect.origin.y *= scale;
                rect.origin.y = galleryElement.size.height*scale - rect.origin.y - rect.size.height;
                
                CGPoint pointInArticle = [currentArticleController.mainScrollView convertPoint:point fromView:pageViewController.mainScrollView];
                
                if (CGRectContainsPoint(rect, pointInArticle))
                {
                    [activeZones addObject:pdfActiveZone];
                }
            }
        }
    }
    
    return activeZones;
}

@end
