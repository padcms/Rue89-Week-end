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
    _subscriptions = [subscriptions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title != nil"]];
    
    for (int i = 0; i < _subscriptions.count; ++i)
    {
        SubscriptionScheme* scheme = _subscriptions[i];
        [self addButtonWithTitle:scheme.title];
    }
    
    if(_subscriptions == nil || _subscriptions.count == 0)
    {
        self.title = @"Sorry no proposals for now.";
    }
    
}

@end
