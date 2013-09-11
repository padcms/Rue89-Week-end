//
//  PCKioskShelfView.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//


#import "PCKioskBaseShelfView.h"
#import "PCKioskPageControl.h"
#import "PCKioskHeaderView.h"

/**
 @class PCKioskShelfView
 @brief Class for kiosk book shelf subview
 */
@interface PCKioskShelfView : PCKioskBaseShelfView <PCKioskPageControlDelegate, PCKioskHeaderViewDelegate>


@property (nonatomic) NSInteger numberOfRevisionsPerPage;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic, readonly) NSInteger totalPages;
@property (nonatomic, readonly) NSInteger totalNumberOfRevisions;
@property (nonatomic) BOOL shouldScrollToTopAfterReload;

- (void)reload;
- (void)reloadWithScrollingToTop;
- (void)showSubHeader:(BOOL)show;

@end
