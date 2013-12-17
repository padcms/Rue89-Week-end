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

@end
