//
//  ScrollingArticleViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/7/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCPageElement, PCScrollView;

@interface ScrollingArticleViewController : UIViewController

@property (nonatomic, strong, readonly) PCPageElement* pageElement;
@property (nonatomic, strong, readonly) PCScrollView* mainScrollView;

- (id) initWithElement:(PCPageElement*)element;

- (void) loadFullView;

- (void) unloadFullView;

- (CGRect) activeZoneRectForType:(NSString*)zoneType;

@end
