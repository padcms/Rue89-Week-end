//
//  FixedIllustrationTouchableColumnViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/1/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "FixedIllustrationTouchableColumnViewController.h"
#import "PCScrollView.h"
#import "PCMagazineViewControllersFactory.h"
#import "PCFixedIllustrationArticleViewController.h"
#import "RueFixedIllustrationArticleTouchablePageViewController.h"

@interface FixedIllustrationTouchableColumnViewController ()

@end

@implementation FixedIllustrationTouchableColumnViewController

-(void)createColumnsView
{
    mainScrollView.contentSize =  CGSizeMake(pageSize.width, pageSize.height * [column.pages count]);
    for (unsigned i = 0; i < [column.pages count]; i++)
    {
        PCPage* page = [column.pages objectAtIndex:i];
        
        PCPageViewController* pageViewController = nil;
        
        if(page.pageTemplate.identifier == PCFixedIllustrationArticleTouchablePageTemplate)
        {
            pageViewController = [[RueFixedIllustrationArticleTouchablePageViewController alloc] initWithPage:page];
        }
        else
        {
            pageViewController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:page];
        }
        
        
        if (pageViewController == nil) continue;
        
        [pageViewController setMagazineViewController:self.magazineViewController];
        [pageViewController setColumnViewController:self];
        [pageViewControllers addObject:pageViewController];
        [pageViewController.view setFrame:CGRectMake(0, pageSize.height * i, pageSize.width, pageSize.height)];
        [mainScrollView addSubview:pageViewController.view];
        
    }
}

@end
