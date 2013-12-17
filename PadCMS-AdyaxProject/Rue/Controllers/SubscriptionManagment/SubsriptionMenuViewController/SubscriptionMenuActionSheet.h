//
//  SubscriptionMenuActionSheet.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/1/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCKioskSubscribeButton;

@interface SubscriptionMenuActionSheet : UIActionSheet

@property (nonatomic, readonly) NSArray* subscriptions;
@property (nonatomic, strong) PCKioskSubscribeButton* initiatorButton;

- (id) initWithTitle:(NSString*)title subscriptions:(NSArray*)subscriptions;

@end
