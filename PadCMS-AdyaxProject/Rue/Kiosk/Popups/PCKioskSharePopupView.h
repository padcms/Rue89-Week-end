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
@property (nonatomic, strong) NSString *twitterMessage;
@property (nonatomic, strong) NSString *facebookMessage;
@property (nonatomic, strong) NSString *googleMessage;
@property (nonatomic, strong) NSString *postUrl;
@property (nonatomic, weak) id<PCKioskSharePopupViewDelegate> delegate;

@end
