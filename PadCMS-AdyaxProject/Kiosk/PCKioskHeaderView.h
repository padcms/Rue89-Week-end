//
//  PCKioskHeaderView.h
//  Pad CMS
//
//  Created by tar on 16.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PCKioskSubscribeButton.h"

@protocol PCKioskHeaderViewDelegate <NSObject, PCKioskSubscribeButtonDelegate>

@required

- (void)contactUsButtonTapped;
- (void)restorePurchasesButtonTapped:(BOOL) needRenewIssues;
- (void)shareButtonTapped;

@end

@interface PCKioskHeaderView : UIView

@property (nonatomic, weak) id<PCKioskHeaderViewDelegate> delegate;

@end
