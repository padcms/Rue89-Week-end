//
//  SubscriptionMenuViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubscriptionScheme;

@protocol SubscriptionMenuViewControllerDelegate <NSObject>

- (void) subscriptionSelected:(SubscriptionScheme*)subscrScheme;

@end

@interface SubscriptionMenuViewController : UIViewController

+ (SubscriptionMenuViewController*) subscriptionMenuControllerWithSubscriptions:(NSArray*)subscriptions title:(NSString*)title;

@property (nonatomic, weak) id<SubscriptionMenuViewControllerDelegate> delegate;

@end
