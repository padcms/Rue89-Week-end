//
//  PCSplitViewController.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCTopBarButtonView;

/**
 @class PCSplitViewController
 @brief Custom analog of UISplitViewController class. Single top bar. Shows master view in popover 
    in portrait orientations 
 */
@interface PCSplitViewController : UIViewController <UIPopoverControllerDelegate>

/**
 @brief Master view controller. Provides master view. PCSplitViewController shows master view 
    aligned to the left side in landscape orientations and in the popover in portrait orientations.
 */
@property (retain, nonatomic) UIViewController *masterViewController;

/**
 @brief Detail view controller. Provides detail view.
 */
@property (retain, nonatomic) UIViewController *detailViewController;

/**
 @brief Creates buttons for PCSplitViewController top bar
 @param image - button icon image
 @param title - button title string
 @param size - button size
 */
+ (PCTopBarButtonView *)topBarButtonViewWithImage:(UIImage *)image title:(NSString *)title size:(CGSize)size;

/**
 @brief Sets top bar view
 @param view - view to replace current top bar
 */
- (void)setTopBarView:(UIView *)view;

/**
 @brief Sets popover button (button that manages popover in portrait orientations). 
    PCSplitViewController binds all necessary actions automatically
 @param button - button to replace current popover button
 */
- (void)setPopoverButtonView:(PCTopBarButtonView *)buttonView;

/**
 @brief Adds button to the left half of the top bar.
 @param button - button to append
 */
- (void)addLeftBarButton:(PCTopBarButtonView *)buttonView;

/**
 @brief Inserts button into the left half of the top bar at a given index.
 @param button - button to insert
 @param index - index at which to insert button
 */
- (void)insertLeftBarButton:(PCTopBarButtonView *)buttonView atIndex:(NSUInteger)index;

/**
 @brief Removes button from the left half of the top bar.
 @param button - button to remove
 */
- (void)removeLeftBarButton:(PCTopBarButtonView *)buttonView;

/**
 @brief Adds button to the right half of the top bar.
 @param button - button to append
 */
- (void)addRightBarButton:(PCTopBarButtonView *)buttonView;

/**
 @brief Inserts button into the right half of the top bar at a given index.
 @param button - button to insert
 @param index - index at which to insert button
 */
- (void)insertRightBarButton:(PCTopBarButtonView *)buttonView atIndex:(NSUInteger)index;

/**
 @brief Removes button from the right half of the top bar.
 @param button - button to remove
 */
- (void)removeRightBarButton:(PCTopBarButtonView *)buttonView;

/**
 @brief Hides popover.
 */
- (void)dismissPopoverViewControllerAnimated:(BOOL)animated;

@end
