//
//  RuePageWithMenuViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RuePageWithMenuViewController.h"
#import "PCScrollView.h"
#import "RueScrollingAticleViewController.h"

@interface RuePageWithMenuViewController ()

@property (nonatomic, strong) RueScrollingAticleViewController* articleController;

@property (nonatomic, strong) NSArray* articleContentControllers;

@end

@implementation RuePageWithMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mainScrollView.scrollEnabled = NO;
    
    self.articleController = [[RueScrollingAticleViewController alloc]init];
    
    [self.mainScrollView insertSubview:self.articleController.view belowSubview:self.bodyViewController.view];
    
    [self createArticleContentViewControllers];
    
}

- (void) createArticleContentViewControllers
{
    NSArray* minArticleElements = [self.page elementsForType:PCPageElementTypeMiniArticle];
    
    NSMutableArray* articleViewControllers = [[NSMutableArray alloc]initWithCapacity:minArticleElements.count];
    
    if (minArticleElements && minArticleElements.count > 0)
    {
        minArticleElements = [minArticleElements sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES],nil]];
        
        for (PCPageElement* element in minArticleElements)
        {
            NSString *fullResource = [self.page.revision.contentDirectory stringByAppendingPathComponent:element.resource];
            PCPageElementViewController* articleContentViewController = [[PCPageElementViewController alloc] initWithResource:fullResource];
            [articleContentViewController setTargetWidth:self.mainScrollView.bounds.size.width];
            CGFloat backgroundWidth = articleContentViewController.view.frame.size.width;
            CGFloat backgroundHeight = articleContentViewController.view.frame.size.height;
            articleContentViewController.view.frame = CGRectMake(0, 0, backgroundWidth, backgroundHeight);
            
            
            [articleViewControllers addObject:articleContentViewController];
        }
    }
    
    self.articleContentControllers = [NSArray arrayWithArray:articleViewControllers];
}

- (void) setCurrentArticleIndex:(int)index
{
    static BOOL transiting = NO;
    
    if(index >= 0 && index < self.articleContentControllers.count && transiting == NO)
    {
        PCPageElementViewController* articleContentController = [self.articleContentControllers objectAtIndex:index];
        if(self.articleController.contentViewController != articleContentController)
        {
            transiting = YES;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
                self.articleController.contentViewController = articleContentController;
                
            } completion:^(BOOL finished) {
                
                transiting = NO;
            }];
        }
    }
}

-(BOOL) pdfActiveZoneAction:(PCPageActiveZone*)activeZone
{
    [super pdfActiveZoneAction:activeZone];
    
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionButton])
    {
        NSString* additional = [activeZone.URL lastPathComponent];
        {
            [self setCurrentArticleIndex:[additional integerValue] - 1];
            return YES;
        }
    }
    return NO;
}

@end
