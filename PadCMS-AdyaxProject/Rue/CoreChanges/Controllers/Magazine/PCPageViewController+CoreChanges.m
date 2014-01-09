//
//  PCPageViewController+CoreChanges.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/13/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCPageViewController.h"
#import "PCScrollView.h"
#import "MBProgressHUD.h"
#import "Helper.h"
#import "RueLongPageElementViewController.h"

@interface PCPageViewController (CoreChanges) <UIScrollViewDelegate>

@end

@implementation PCPageViewController (CoreChanges)

- (void) tapAction:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.mainScrollView];
    NSArray* actions = [self activeZonesAtPoint:point];
    
    [UIView transitionWithView: mainScrollView
                      duration: 0.35f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         
         for (PCPageActiveZone* action in actions)
             if ([self pdfActiveZoneAction:action])
                 break;
         if (actions.count == 0)
         {
             [self.magazineViewController tapGesture:gestureRecognizer];
         }
     } completion:^(BOOL finished) {
         //
     }];
}

- (void)endDownloadingPCPageOperation:(NSNotification*)notif
{
    if (!isLoaded) return;
    if (notif.object == self.page)
    {
        
        [UIView transitionWithView: self.view
                          duration: 0.35f
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^(void)
         {
             [self unloadFullView];
             [self loadFullView];
         } completion:^(BOOL finished) {
             //
         }];
        
        
        
        if (self.page.pageTemplate == [[PCPageTemplatesPool templatesPool] templateForId:PCBasicArticlePageTemplate])
        {
            /*   if (self.bodyViewController.view.frame.size.height - self.mainScrollView.bounds.size.height > 3)//3 is a magic number!
             self.mainScrollView.scrollEnabled = YES;  */
        }
        [HUD hide:YES];
    }
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //TODO need setting size only of biggest source to contentSize
    PCPageElement* backgroundElement = [page firstElementForType:PCPageElementTypeBackground];
    if (backgroundElement != nil)
    {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:backgroundElement.resource];
        
        self.backgroundViewController = [[PCPageElementViewController alloc] initWithResource:fullResource];
        //    self.backgroundViewController.element = backgroundElement;
        [self.backgroundViewController setTargetWidth:self.mainScrollView.bounds.size.width];
        [self.mainScrollView addSubview:self.backgroundViewController.view];
        [self.mainScrollView setContentSize:[self.backgroundViewController.view frame].size];
        
        CGFloat backgroundWidth = self.backgroundViewController.view.frame.size.width;
        CGFloat backgroundHeight = self.backgroundViewController.view.frame.size.height;
        self.backgroundViewController.view.frame = CGRectMake(0, 0, backgroundWidth, backgroundHeight);
    }
    
    PCPageElementBody* bodyElement = (PCPageElementBody*)[page firstElementForType:PCPageElementTypeBody];
    if (bodyElement != nil)
    {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:bodyElement.resource];
        
        CGSize imageSize = [Helper getSizeForImage:fullResource];
        if(imageSize.height > 1024 * 3)
        {
            self.bodyViewController = [[RueLongPageElementViewController alloc] initWithResource:fullResource];
        }
        else
        {
            self.bodyViewController = [[PCPageElementViewController alloc] initWithResource:fullResource];
        }
        
        self.mainScrollView.delegate = self;
        
        // self.bodyViewController.element = bodyElement;
        [self.bodyViewController setTargetWidth:self.mainScrollView.bounds.size.width];
        
        //        if (self.page.pageTemplate == [[PCPageTemplatesPool templatesPool] templateForId:PCBasicArticlePageTemplate])
        //        {
        //            /* if (self.bodyViewController.view.frame.size.height - self.mainScrollView.bounds.size.height < 3)//3 is a magic number!
        //                 self.mainScrollView.scrollEnabled = NO;  */
        //        }
        
        [self.mainScrollView addSubview:self.bodyViewController.view];
        [self.mainScrollView setContentSize:[self.bodyViewController.view frame].size];
        
        CGFloat bodyWidth = self.bodyViewController.view.frame.size.width;
        CGFloat bodyHeight = self.bodyViewController.view.frame.size.height;
        self.bodyViewController.view.frame = CGRectMake(0, 0, bodyWidth, bodyHeight);
    }
	
	[self.page addObserver:self forKeyPath:@"isComplete" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([self.bodyViewController isKindOfClass:[RueLongPageElementViewController class]])
    {
        [(RueLongPageElementViewController*)self.bodyViewController setYOffset:scrollView.contentOffset.y];
    }
}

@end
