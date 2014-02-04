//
//  RueBrowserViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCBrowserViewController.h"

@class PCPage, PCPageElementVideo, RuePageElementSound;

@interface RueBrowserViewController : PCBrowserViewController

/**
 @brief Stops playing and loading and removes its player view.
 */
- (void) stop;

- (BOOL) containsPoint:(CGPoint)point;

@property (nonatomic, weak) UIView* pageView;
@property (nonatomic, weak) UIScrollView* mainScrollView;

/**
 @brief If set to YES video in not full screen mode will be presenting with 90 degrees rotation.
 */
@property (nonatomic, assign) BOOL isHorizontal;

/**
 @brief Whent sets to YES and sound element is presenting with allowing pause, touch on active zone will stops playing (not pause).
 */
@property (nonatomic, assign) BOOL stopOnTouch;

/**
 @brief Creates player and starts playing downloaded video file defined by PCPageElementVideo object.
 */
- (void) presentElement:(PCPageElementVideo*)element ofPage:(PCPage*)page;

/**
 @brief Creates player and starts playing downloaded resource file defined by RuePageElementSound object. Not showing player view.
 @param allowPause If YES, touch in active zone will pause/resume playing, if NO, touch will starts playing from the begining.
 */
- (void) presentSoundElement:(RuePageElementSound*)element ofPage:(PCPage*)page allowPause:(BOOL)allowPause;

@end
