//
//  RueKioskShelfView.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskShelfView.h"

#import "PCKioskPageControl.h"
#import "PCKioskHeaderView.h"

@class PCRevision;

@interface RueKioskShelfView : PCKioskShelfView <PCKioskPageControlDelegate, PCKioskHeaderViewDelegate>


@property (nonatomic) NSInteger numberOfRevisionsPerPage;

@property (nonatomic, readonly) NSInteger totalNumberOfRevisions;
@property (nonatomic) BOOL shouldScrollToTopAfterReload;
@property (nonatomic, strong) PCKioskPageControl * pageControl;

- (void)reload;
- (void)reloadWithScrollingToTop;
- (void) updateElementsButtons;

- (void)showSubHeader:(BOOL)show withTitle:(NSString*)title;

- (void) downloadingContentStartedWithRevisionIndex:(NSInteger)index;
- (void) downloadingContentFinishedWithRevisionIndex:(NSInteger)index;

- (void) subscribeButtonTaped:(UIButton*)button fromRevision:(PCRevision*)revision;

- (void) unloadView;

@end
