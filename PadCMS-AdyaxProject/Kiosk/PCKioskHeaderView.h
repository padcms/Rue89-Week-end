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
@optional
- (void)contactUsButtonTapped;
- (void)restorePurchasesButtonTapped:(BOOL) needRenewIssues;
- (void)shareButtonTapped;
- (void)logoButtonTapped;

@end

@interface PCKioskHeaderView : UIView

@property (nonatomic, weak) id<PCKioskHeaderViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet PCKioskSubscribeButton *subscribeButton;

@end
