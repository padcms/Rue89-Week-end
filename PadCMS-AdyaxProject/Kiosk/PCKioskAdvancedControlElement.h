//
//  PCKioskAdvancedControlElement.h
//  Pad CMS
//
//  Created by tar on 14.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//


@protocol PCKioskAdvancedControlElementHeightDelegate;


#import "PCKioskBaseControlElement.h"

/**
 @class PCKioskAdvancedControlElement
 @brief Class for kiosk homepage cell. Will represent a cell-like preview of issue with title, illustration, date, author, description etc.
 */

@interface PCKioskAdvancedControlElement : PCKioskBaseControlElement {
    UIButton                *payButton;
}

@property (nonatomic, assign) id<PCKioskAdvancedControlElementHeightDelegate> heightDelegate;

@end


@protocol PCKioskAdvancedControlElementHeightDelegate <NSObject>

- (void)setHeight:(CGFloat)height forCell:(PCKioskAdvancedControlElement *)cell;

@end
