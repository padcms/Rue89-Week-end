//
//  PCKioskSharePopupView.h
//  Pad CMS
//
//  Created by tar on 22.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskPopupView.h"
#import "PCEmailController.h"
#import "PCTwitterNewController.h"

@protocol PCKioskSharePopupViewDelegate <NSObject, PCEmailControllerDelegate, PCTwitterNewControllerDelegate, PCKioskPopupViewDelegate>

@end

@interface PCKioskSharePopupView : PCKioskPopupView

@property (nonatomic, copy) NSDictionary * emailMessage;
@property (nonatomic, copy) NSString * twitterMessage;
@property (nonatomic, copy) NSString * facebookMessage;
@property (nonatomic, weak) id<PCKioskSharePopupViewDelegate> delegate;

@end
