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

@class PCKioskPopupView;

@protocol PCKioskPopupViewDelegate <NSObject>

@optional
- (void)popupViewDidHide:(PCKioskPopupView *)popupView;

@end

enum  {
    PCKioskPopupPresentationStyleCenter = 1,
    PCKioskPopupPresentationStyleFromBottom = 2,
    PCKioskPopupPresentationStyleFromTop = 3,
};

typedef int PCKioskPopupPresentationStyle;

@interface PCKioskPopupView : UIView

/**
 @brief Semi transparent view that blocks other UI from touches.
 */
@property (nonatomic, strong) UIView * blockingView;

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
 @brief Popup presentation style
 */
@property (nonatomic) PCKioskPopupPresentationStyle presentationStyle;

/**
 @brief Width of the popup shadow
 */
@property (nonatomic, readonly) CGFloat shadowWidth;

/**
 @brief Delegate object
 */
@property (nonatomic, weak) id<PCKioskPopupViewDelegate> delegate;

@property (nonatomic) BOOL isShown;

/**
 @brief Designated initializer
 */
- (id)initWithSize:(CGSize)size viewToShowIn:(UIView *)view;

/**
 @brief Override this method if you want your own labels. Call super to keep predefined stuff.
 */
- (void)loadContent;

/**
 @brief Shows popup animated in viewToShowIn.
 */
- (void)show;

/**
 @brief Hides popup animated.
 */
- (void)hide;


- (CGRect)bottomHiddenFrame:(BOOL)hidden;
- (void)prepareForPresentation;

/**
 @brief Override if you want your own show/hide animation actions
 */
- (void)showAnimationActions;
- (void)hideAnimationActions;

- (void)hideAnimationCompletionActions;

- (void)showAnimated:(BOOL)animated completion:(void(^)())completion;
- (void)hideAnimated:(BOOL)animated completion:(void(^)())completion;

@end
