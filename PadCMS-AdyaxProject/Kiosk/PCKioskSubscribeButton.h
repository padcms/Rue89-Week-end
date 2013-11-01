//
//  PCKioskSubscribeButton.h
//  Pad CMS
//
//  Created by tar on 19.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCKioskSubscribeButton;

@protocol PCKioskSubscribeButtonDelegate <NSObject>

@required
- (void)subscribeButtonTapped:(PCKioskSubscribeButton*)button;

@end

@interface PCKioskSubscribeButton : UIView

@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;
@property (retain, nonatomic) IBOutlet UILabel *subscribedLabel;

@property (nonatomic) BOOL isSubscribedState;

@end
