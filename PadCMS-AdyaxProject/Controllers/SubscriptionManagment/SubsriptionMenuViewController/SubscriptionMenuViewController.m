//
//  SubscriptionMenuViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "SubscriptionMenuViewController.h"

@interface SubscriptionMenuViewController ()

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray* buttons;

@end

@implementation SubscriptionMenuViewController

+ (SubscriptionMenuViewController*) subscriptionMenuControllerWithSubscriptions:(NSArray*)subscriptions title:(NSString*)title
{
    SubscriptionMenuViewController* controller = [[SubscriptionMenuViewController alloc]initWithNibName:@"SubscriptionMenuViewController" bundle:nil];
    
    controller.view.userInteractionEnabled = YES;
    
    controller.titleLabel.text = title;
    
    for (int i = 0; i < subscriptions.count; ++i)
    {
        UIButton* btn = controller.buttons[i];
        
        [btn setTitle:subscriptions[i] forState:UIControlStateNormal];
    }
    
    return controller;
}


@end
