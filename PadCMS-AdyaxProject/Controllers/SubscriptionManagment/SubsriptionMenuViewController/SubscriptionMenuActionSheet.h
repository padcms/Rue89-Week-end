//
//  SubscriptionMenuActionSheet.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/1/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscriptionMenuActionSheet : UIActionSheet

@property (nonatomic, readonly) NSArray* subscriptions;

- (id) initWithTitle:(NSString*)title subscriptions:(NSArray*)subscriptions;

@end
