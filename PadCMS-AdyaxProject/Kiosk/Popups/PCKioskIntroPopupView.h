//
//  PCKioskIntroPopupView.h
//  Pad CMS
//
//  Created by tar on 22.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskTitledPopupView.h"
#import "PCKioskSubscribeButton.h"

@interface PCKioskIntroPopupView : PCKioskTitledPopupView

@property (nonatomic, weak) id<PCKioskSubscribeButtonDelegate> purchaseDelegate;

@property (nonatomic, strong) NSString* titleText;
@property (nonatomic, strong) NSString* descriptionText;
@property (nonatomic, strong) NSString* infoText;

@property (nonatomic, strong) PCKioskSubscribeButton * subscribeButton;

@end
