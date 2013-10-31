//
//  PCRevisionSummaryPopup.h
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskPopupView.h"
#import "EasyTableView.h"

@class PCRevision;
@class PCRevisionSummaryPopup;

@protocol PCRevisionSummaryPopupDelegate <NSObject, PCKioskPopupViewDelegate>

- (void)revisionSummaryPopupDidTapHomeButton:(PCRevisionSummaryPopup *)popup;
- (void)revisionSummaryPopupDidTapMenuButton:(PCRevisionSummaryPopup *)popup;
- (void)revisionSummaryPopup:(PCRevisionSummaryPopup *)popup didSelectIndex:(NSInteger)index;

@optional
- (void)revisionSummaryPopup:(PCRevisionSummaryPopup *)popup didSelectRevision:(PCRevision*)revision;

@end

@interface PCRevisionSummaryPopup : PCKioskPopupView

- (id)initWithSize:(CGSize)size viewToShowIn:(UIView *)view tocItems:(NSArray *)aTocItems;

@property (nonatomic, strong) EasyTableView * tableView;
@property (nonatomic, weak) id<PCRevisionSummaryPopupDelegate> delegate;

- (NSArray*) revisionsList;
- (void) setRevisionsList:(NSArray*)revisions;

@end
