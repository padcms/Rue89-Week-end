//
//  SubscriptionMenuViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "SubscriptionMenuViewController.h"
#import "SubscriptionScheme.h"
#import "UIView+EasyFrame.h"
#import <QuartzCore/QuartzCore.h>

@interface SubscriptionMenuViewController ()

@property (nonatomic, strong) NSArray* subscriptions;

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray* buttons;

@end

@implementation SubscriptionMenuViewController

+ (SubscriptionMenuViewController*) subscriptionMenuControllerWithSubscriptions:(NSArray*)subscriptions title:(NSString*)title
{
    SubscriptionMenuViewController* controller = [[SubscriptionMenuViewController alloc]initWithNibName:@"SubscriptionMenuViewController" bundle:nil];
    
    controller.view.userInteractionEnabled = YES;
    
    controller.titleLabel.text = title;
    
    controller.subscriptions = subscriptions;
    
    return controller;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    for (UIButton* btn in self.buttons)
    {
        btn.layer.cornerRadius = 5;
    }
}

- (void) setSubscriptions:(NSArray *)subscriptions
{
    if(subscriptions && subscriptions.count)
    {
        _subscriptions = subscriptions;
        
        for (int i = 0; i < self.buttons.count; ++i)
        {
            UIButton* btn = self.buttons[i];
            
            SubscriptionScheme* scheme = nil;
            
            if(i < subscriptions.count)
            {
                scheme = subscriptions[i];
            }
            
            if(scheme)
            {
                [btn setTitle:scheme.identifier forState:UIControlStateNormal];
                btn.hidden = NO;
                btn.tag = i;
            }
            else
            {
                btn.hidden = YES;
            }
        }
        
        if(subscriptions.count < self.buttons.count)
        {
            //UIButton* lastVisibleButton = self.buttons[subscriptions.count - 1];
            UIButton* nextHiddenButton = self.buttons[subscriptions.count];
            //float lastVisibleButtonBottomY = lastVisibleButton.frameY + lastVisibleButton.frameHeight;
            float nextHiddenButtonTopY = nextHiddenButton.frameY;
            
            self.view.frameHeight = nextHiddenButtonTopY;
        }
        
    }
    else
    {
        self.titleLabel.text = @"Sorry no proposals for now.";
        self.view.frameHeight = self.titleLabel.frameY * 2 + self.titleLabel.frameHeight;
        for (UIButton*  btn in self.buttons)
        {
            btn.hidden = YES;
        }
    }
}

- (IBAction)buttonPresed:(UIButton*)sender
{
    int selectedIndex = sender.tag;
    
    SubscriptionScheme* selectedScheme = nil;
    
    if(selectedIndex < self.subscriptions.count)
    {
        selectedScheme = self.subscriptions[selectedIndex];
    }
    if(selectedScheme && self.delegate)
    {
        [self.delegate subscriptionSelected:selectedScheme];
    }
}

@end
