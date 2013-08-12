//
//  PCPopupView.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 6/12/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @class PCPopupView
 @brief Semi-transparent view with rounded corners and title and message. 
 */
@interface PCPopupView : UIView

/**
 @brief Sets title of the PCPopupView instance to title.
 @param title - title to be set
 */
- (void)setPopupTitle:(NSString *)title;

/**
 @brief Sets message of the PCPopupView instance to message.
 @param message - message to be set
 */
- (void)setPopupMessage:(NSString *)message;

/**
 @brief Semi-transparent view with rounded corners and title and message. 
 @param view - view to show popup view in
 @param title - popup view title
 @param message - popup view message
 */
+ (void)showPopupViewInView:(UIView *)view title:(NSString *)title message:(NSString *)message;

@end
