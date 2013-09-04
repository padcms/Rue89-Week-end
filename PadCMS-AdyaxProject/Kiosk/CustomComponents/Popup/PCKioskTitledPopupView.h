//
//  PCKioskTitledPopupView.h
//  Pad CMS
//
//  Created by tar on 04.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskPopupView.h"

@interface PCKioskTitledPopupView : PCKioskPopupView

/**
 @brief Title label
 */
@property (nonatomic, strong) MTLabel * titleLabel;

/**
 @brief Description label
 */
@property (nonatomic, strong) MTLabel * descriptionLabel;


/**
 @brief Override if you want your own labels.
 If you want completely custom content in you popup,
 please look at loadContent method of PCKioskPopupView.
 */
- (void)initTitle;
- (void)initDescription;

@end
