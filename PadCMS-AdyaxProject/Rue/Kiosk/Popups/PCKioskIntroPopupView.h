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

@property (nonatomic) NSString* titleText;
@property (nonatomic) NSString* descriptionText;
@property (nonatomic) NSString* infoText;

@property (nonatomic, strong) PCKioskSubscribeButton * subscribeButton;

@end
