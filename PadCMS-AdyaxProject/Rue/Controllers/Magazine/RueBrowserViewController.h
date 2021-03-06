//
//  RueBrowserViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCBrowserViewController.h"

@class PCPage, PCPageElementVideo, RuePageElementSound;

@interface RueBrowserViewController : PCBrowserViewController

- (void) stop;

- (BOOL) containsPoint:(CGPoint)point;

@property (nonatomic, weak) UIView* pageView;
@property (nonatomic, weak) UIScrollView* mainScrollView;

@property (nonatomic, assign) BOOL isHorizontal;

@property (nonatomic, assign) BOOL stopOnTouch;

- (void) presentElement:(PCPageElementVideo*)element ofPage:(PCPage*)page;

- (void) presentSoundElement:(RuePageElementSound*)element ofPage:(PCPage*)page allowPause:(BOOL)allowPause;

@end
