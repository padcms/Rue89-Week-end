//
//  PCLogInViewController.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCAccount;

/**
 @brief Authorization view controller class. Provides interaction between PCAccount instance and UI
 */
@interface PCAuthorizationViewController : UIViewController

/**
 @brief PCAccount class instance 
 */
@property (retain, nonatomic) PCAccount *account;

@end
