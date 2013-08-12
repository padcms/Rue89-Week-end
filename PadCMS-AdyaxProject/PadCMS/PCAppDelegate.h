//
//  PCAppDelegate.h
//  PadCMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCAccount;

@interface PCAppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly) PCAccount *account;

@property (strong, nonatomic) UIWindow *window;

@end
