//
//  SubscribeMenuPopuverController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscribeMenuPopuverController : UIPopoverController

+ (SubscribeMenuPopuverController*) showMenuPopoverWithSubscriptions:(NSArray*)subscriptions fromRect:(CGRect)rect inView:(UIView*)view;

@end
