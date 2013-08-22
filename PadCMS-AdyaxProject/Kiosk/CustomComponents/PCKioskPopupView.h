//
//  PCKioskPopupView.h
//  Pad CMS
//
//  Created by tar on 22.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCFonts.h"
#import "PCKioskShelfSettings.h"

@interface PCKioskPopupView : UIView

/**
 @brief Semi transparent view that blocks other UI from touches.
 */
@property (nonatomic, strong) UIView * blockingView;

/**
 @brief View to add content such as labels, imageViews etc.
 */
@property (nonatomic, strong) UIView * contentView;

/**
 @brief Button that hides popup.
 */
@property (nonatomic, strong) UIButton * closeButton;

/**
 @brief Gesture that added on blocking view for hiding popup when it tapped.
 */
@property (nonatomic, strong) UITapGestureRecognizer * tapGesture;

/**
 @brief View, on which blocking view will be added.
 */
@property (nonatomic, strong) UIView * viewToShowIn;

/**
 @brief Shadow for content view
 */
@property (nonatomic, strong) UIImageView * shadowImageView;

/**
 @brief Designated initializer
 */
- (id)initWithSize:(CGSize)size viewToShowIn:(UIView *)view;

/**
 @brief Shows popup animated in viewToShowIn.
 */
- (void)show;

/**
 @brief Hides popup animated in viewToShowIn.
 */
- (void)hide;

@end
