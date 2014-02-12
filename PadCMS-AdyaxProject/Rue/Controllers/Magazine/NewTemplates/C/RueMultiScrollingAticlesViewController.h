//
//  RueMultiScrollingAticlesViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCPageViewController, PCPageElement, ScrollingArticleViewController;

@interface RueMultiScrollingAticlesViewController : UIViewController

@property (nonatomic, strong, readonly) NSArray* contentViewControllers;
@property (nonatomic, assign) BOOL hasVideoBrowserOn;

- (id) initWithElements:(NSArray*)elements;

- (BOOL) isChangingArticles;

- (int) currentArticleIndex;

- (ScrollingArticleViewController*) currentArticleController;

- (void) setCurrentArticleIndexTo:(int)index animated:(BOOL)animaten withCompletion:(void(^)())completion;

- (void) loadFullView;

- (void) unloadFullView;

- (NSArray*) activeZonesForGalleryElement:(PCPageElement*)galleryElement atPoint:(CGPoint)point inPageController:(PCPageViewController*)pageViewController;

@end
