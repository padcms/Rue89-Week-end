//
//  PCRevisionSummaryPopup.h
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskPopupView.h"
#import "EasyTableView.h"

@class PCRevisionSummaryPopup;

@protocol PCRevisionSummaryPopupDelegate <NSObject, PCKioskPopupViewDelegate>

- (void)revisionSummaryPopupDidTapHomeButton:(PCRevisionSummaryPopup *)popup;
- (void)revisionSummaryPopupDidTapMenuButton:(PCRevisionSummaryPopup *)popup;

@end

@interface PCRevisionSummaryPopup : PCKioskPopupView

@property (nonatomic, strong) EasyTableView * tableView;
@property (nonatomic, weak) id<PCRevisionSummaryPopupDelegate> delegate;

@end
