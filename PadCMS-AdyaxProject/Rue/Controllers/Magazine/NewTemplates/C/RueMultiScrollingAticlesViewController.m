//
//  RueMultiScrollingAticlesViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueMultiScrollingAticlesViewController.h"
#import "ScrollingArticleViewController.h"

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
            ScrollingArticleViewController* previousController = nil;
            if(_currentArticleIndex >= 0)
            {
                previousController = [self.contentViewControllers objectAtIndex:_currentArticleIndex];
            }
            
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

- (void) loadFullView
{
    
}

- (void) unloadFullView
{
    
}

@end
