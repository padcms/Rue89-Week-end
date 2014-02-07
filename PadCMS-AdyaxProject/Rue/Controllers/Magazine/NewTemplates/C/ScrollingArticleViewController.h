//
//  ScrollingArticleViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/7/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCPageElement;

@interface ScrollingArticleViewController : UIViewController

- (id) initWithElement:(PCPageElement*)element;

- (void) loadFullView;

- (void) unloadFullView;

@end
