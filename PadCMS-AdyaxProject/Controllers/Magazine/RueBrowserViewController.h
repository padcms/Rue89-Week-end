//
//  RueBrowserViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCBrowserViewController.h"

@interface RueBrowserViewController : PCBrowserViewController

- (void) stop;

- (BOOL) containsPoint:(CGPoint)point;

@property (nonatomic, weak) UIView* pageView;
@property (nonatomic, weak) UIScrollView* mainScrollView;

@end
