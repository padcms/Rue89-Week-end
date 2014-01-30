//
//  RueLongPageElementViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/4/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "PCPageElementViewController.h"

/**
 @brief Subclass of PCPageElementViewController that shows only part of long (by height) page element which is currently on screen for memory optimization.
 */
@interface RueLongPageElementViewController : PCPageElementViewController

/**
 @brief offset determines which part of resource is  currently on screen. (For example, offset of scroll view on which self view located).
 */
@property (nonatomic, assign) float yOffset;

@end
