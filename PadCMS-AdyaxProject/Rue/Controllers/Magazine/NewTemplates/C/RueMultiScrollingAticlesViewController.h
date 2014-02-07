//
//  RueMultiScrollingAticlesViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RueMultiScrollingAticlesViewController : UIViewController

@property (nonatomic, strong, readonly) NSArray* contentViewControllers;

- (id) initWithElements:(NSArray*)elements;

- (BOOL) isChangingArticles;

- (int) currentArticleIndex;

- (void) setCurrentArticleIndexTo:(int)index animated:(BOOL)animaten withCompletion:(void(^)())completion;

- (void) loadFullView;

- (void) unloadFullView;

@end
