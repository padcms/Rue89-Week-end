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
#import "PCPageControllersManager.h"

@interface RuePageWithMenuViewController ()

@property (nonatomic, strong) RueScrollingAticleViewController* articleController;

@property (nonatomic, strong) NSArray* articleContentControllers;

@end

@implementation RuePageWithMenuViewController

+ (void) load
{
    PCPageTemplate* newTemplate = [PCPageTemplate templateWithIdentifier:24
                                                                   title:@"Scrolling Gallery with Fixed Menu"
                                                             description:@""
                                                              connectors:PCTemplateAllConnectors
                                                           engineVersion:1];
    [[PCPageTemplatesPool templatesPool] registerPageTemplate:newTemplate];
    
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:newTemplate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.articleController = [[RueScrollingAticleViewController alloc]init];
    
    [self.mainScrollView insertSubview:self.articleController.view belowSubview:self.bodyViewController.view];
    
    [self createGalleryContentViewControllers];
    
    self.bodyViewController.view.userInteractionEnabled = NO;
    
    PCPageElementBody* bodyElement = (PCPageElementBody*)[self.page firstElementForType:PCPageElementTypeBody];
    if(bodyElement.showTopLayer)
    {
        [self setCurrentArticleIndex:0];
    }
}

- (void) createGalleryContentViewControllers
{
    NSArray* galleryElements = [self.page elementsForType:PCPageElementTypeGallery];
    
    NSMutableArray* articleViewControllers = [[NSMutableArray alloc]initWithCapacity:galleryElements.count];
    
    if (galleryElements && galleryElements.count > 0)
    {
        galleryElements = [galleryElements sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES],nil]];
        
        for (PCPageElement* element in galleryElements)
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

- (BOOL) pdfActiveZoneAction:(PCPageActiveZone*)activeZone
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

- (NSArray*) activeZonesAtPoint:(CGPoint)point
{
    NSMutableArray* activeZones = [[NSMutableArray alloc] init];
    
    for (PCPageElement* element in self.page.elements)
    {
        for (PCPageActiveZone* pdfActiveZone in element.activeZones)
        {
            CGRect rect = pdfActiveZone.rect;
            if (!CGRectEqualToRect(rect, CGRectZero))
            {
                if (CGRectContainsPoint(rect, point))
                {
                    [activeZones addObject:pdfActiveZone];
                }
            }
        }
    }
    return activeZones;
}

@end
