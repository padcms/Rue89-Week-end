//
//  PCKioskNotificationPopup.m
//  Pad CMS
//
//  Created by tar on 23.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskNotificationPopup.h"
#import "MTLabel.h"

@interface PCKioskNotificationPopup()

@end

@implementation PCKioskNotificationPopup

- (id)initWithSize:(CGSize)size viewToShowIn:(UIView *)view
{
    self = [super initWithSize:size viewToShowIn:view];
    if (self) {
        self.presentationStyle = PCKioskPopupPresentationStyleFromBottom;
    }
    return self;
}

- (void)loadContent {
    [super loadContent];
}

@end
