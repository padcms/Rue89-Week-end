//
//  RuePopupViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCPageElement;

@interface RuePopupViewController : UIViewController

//+ (id) popupControllerWithIndex:(int)index forElement:(PCPageElement*)element;

+ (id) popupControllerWithIndex:(int)index forElement:(PCPageElement*)element withFrame:(CGRect)frame onScrollView:(UIScrollView*)scroll;

- (BOOL) isPresented;

- (void) load;
- (void) unload;

@end
