//
//  PCKioskSharePopupView.h
//  Pad CMS
//
//  Created by tar on 22.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskTitledPopupView.h"
#import "PCEmailController.h"
#import "PCTwitterNewController.h"

@protocol PCKioskSharePopupViewDelegate <NSObject, PCEmailControllerDelegate, PCTwitterNewControllerDelegate, PCKioskPopupViewDelegate>

@end

@interface PCKioskSharePopupView : PCKioskTitledPopupView

//@property (nonatomic, copy) NSDictionary * emailMessage;
@property (nonatomic, strong) NSString *emailShareMessage;
@property (nonatomic, strong) NSString *emailShareTittle;
@property (nonatomic, copy) NSString * twitterMessage;
@property (nonatomic, copy) NSString * facebookMessage;
@property (nonatomic, copy) NSString * googleMessage;
@property (nonatomic, copy) NSString * postUrl;
@property (nonatomic, weak) id<PCKioskSharePopupViewDelegate> delegate;

@end
