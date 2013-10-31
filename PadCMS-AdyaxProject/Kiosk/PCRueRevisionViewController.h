//
//  PCRueRevisionViewController.h
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevisionViewController.h"

@class PCRevisionSummaryPopup;

@interface PCRueRevisionViewController : PCRevisionViewController

@property (nonatomic, strong) PCRevisionSummaryPopup * summaryPopup;

- (void) fadeInViewWithDuration:(NSTimeInterval)duration completion:(void(^)())complBlock;
- (void) fadeOutViewWithDuration:(NSTimeInterval)duration completion:(void(^)())complBlock;

- (void) showSummaryMenuAnimated:(BOOL)animated;
- (void) showSummaryMenuAnimated:(BOOL)animated withRevisionsList:(NSArray*)revisionsList;
- (void) showSummaryMenuAnimated:(BOOL)animated withRevisionsList:(NSArray*)revisionsList menuOffset:(float)offset;

- (void) hideSummaryMenuAnimated:(BOOL)animated;

@end
