//
//  PCKioskAdvancedControlElement.h
//  Pad CMS
//
//  Created by tar on 14.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//


@protocol PCKioskAdvancedControlElementHeightDelegate;


#import "PCKioskBaseControlElement.h"
#import "PCRevision.h"

/**
 @class PCKioskAdvancedControlElement
 @brief Class for kiosk homepage cell. Will represent a cell-like preview of issue with title, illustration, date, author, description etc.
 */

@interface PCKioskAdvancedControlElement : PCKioskBaseControlElement {
    UIButton                *payButton;
    
}


@property (nonatomic, weak) id<PCKioskAdvancedControlElementHeightDelegate> heightDelegate;
@property (nonatomic, strong) PCRevision * revision;
@property (nonatomic, strong) UIButton * archiveButton;
@property (nonatomic, strong) UIButton * restoreButton;

- (void)showDescription:(BOOL)show animated:(BOOL)animated;
- (void)showDescription:(BOOL)show animated:(BOOL)animated notifyDelegate:(BOOL)notify;

- (void) downloadContentStarted;
- (void) downloadContentFinished;

@end


@protocol PCKioskAdvancedControlElementHeightDelegate <NSObject>

- (void)setHeight:(CGFloat)height forCell:(PCKioskAdvancedControlElement *)cell;

@end
