//
//  PCRueRevisionViewController.h
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevisionViewController.h"

@interface PCRueRevisionViewController : PCRevisionViewController

- (void) fadeInViewWithDuration:(NSTimeInterval)duration completion:(void(^)())complBlock;
- (void) fadeOutViewWithDuration:(NSTimeInterval)duration completion:(void(^)())complBlock;

- (void) showSummaryMenuAnimated:(BOOL)animated;
- (void) hideSummaryMenuAnimated:(BOOL)animated;

@end
