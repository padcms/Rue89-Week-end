//
//  SubscribeMenuPopuverController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "SubscribeMenuPopuverController.h"
#import "SubscriptionMenuViewController.h"

@interface SubscribeMenuPopuverController () <SubscriptionMenuViewControllerDelegate>

@end

@implementation SubscribeMenuPopuverController

+ (SubscribeMenuPopuverController*) showMenuPopoverWithSubscriptions:(NSArray*)subscriptions fromRect:(CGRect)rect inView:(UIView*)view
{
    return [self showMenuPopoverWithSubscriptions:subscriptions fromRect:rect inView:view popoverTitle:@"Select subscription."];
}

+ (SubscribeMenuPopuverController*) showMenuPopoverWithSubscriptions:(NSArray*)subscriptions fromRect:(CGRect)rect inView:(UIView*)view popoverTitle:(NSString*)title
{
    SubscriptionMenuViewController* contentController = [SubscriptionMenuViewController subscriptionMenuControllerWithSubscriptions:subscriptions title:title];
    
    CGSize contentSize = contentController.view.frame.size;
    
    SubscribeMenuPopuverController* subscribePopoverController = [[SubscribeMenuPopuverController alloc]initWithContentViewController:contentController];
    
    contentController.delegate = subscribePopoverController;
    
    if([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        [subscribePopoverController setPopoverContentSize:contentSize animated:NO];
    }
    else
    {
        [subscribePopoverController setPopoverContentSize:CGSizeMake(contentSize.width, 0) animated:NO];
    }
    
    
    [subscribePopoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:(UIPopoverArrowDirectionAny) animated:YES];
    
    subscribePopoverController.popoverContentSize = contentSize;
    
    return subscribePopoverController;
}

- (void) subscriptionSelected:(SubscriptionScheme *)subscrScheme
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(subscribtionScheme:selectedInPopove:)])
    {
        [(id<SubscribeMenuPopuverDelegate>)self.delegate subscribtionScheme:subscrScheme selectedInPopove:self];
    }
}

@end
