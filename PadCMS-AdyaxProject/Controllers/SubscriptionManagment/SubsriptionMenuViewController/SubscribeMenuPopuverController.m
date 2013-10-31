//
//  SubscribeMenuPopuverController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "SubscribeMenuPopuverController.h"
#import "SubscriptionMenuViewController.h"

@implementation SubscribeMenuPopuverController

+ (SubscribeMenuPopuverController*) showMenuPopoverWithSubscriptions:(NSArray*)subscriptions fromRect:(CGRect)rect inView:(UIView*)view
{
    SubscriptionMenuViewController* contentController = [SubscriptionMenuViewController subscriptionMenuControllerWithSubscriptions:subscriptions title:@"Select subscription."];
    
    CGSize contentSize = contentController.view.frame.size;
    
    SubscribeMenuPopuverController* subscribePopoverController = [[SubscribeMenuPopuverController alloc]initWithContentViewController:contentController];
    
    [subscribePopoverController setPopoverContentSize:CGSizeMake(contentSize.width, 0) animated:NO];
    
    
    [subscribePopoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    subscribePopoverController.popoverContentSize = contentSize;
    
    return subscribePopoverController;
}

@end
