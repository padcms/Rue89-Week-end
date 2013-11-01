//
//  SubscriptionMenuActionSheet.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/1/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "SubscriptionMenuActionSheet.h"
#import "SubscriptionScheme.h"

@interface SubscriptionMenuActionSheet ()

@end

@implementation SubscriptionMenuActionSheet

- (id) initWithTitle:(NSString*)title subscriptions:(NSArray*)subscriptions
{
    self = [super init];
    if(self)
    {
        self.title = title;
        self.subscriptions = subscriptions;
    }
    return self;
}

- (void) setSubscriptions:(NSArray *)subscriptions
{
    _subscriptions = subscriptions;
    
    for (int i = 0; i < subscriptions.count; ++i)
    {
        SubscriptionScheme* scheme = subscriptions[i];
        [self addButtonWithTitle:scheme.identifier];
    }
    
    if(subscriptions == nil || subscriptions.count == 0)
    {
        self.title = @"Sorry no proposals for now.";
    }
    
}

@end
