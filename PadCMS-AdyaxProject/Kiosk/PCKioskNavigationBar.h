//
//  PCKioskNavigationBar.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 14.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCKioskNavigationBarDelegate <NSObject>

- (void) switchToNextKioskView;
- (void) searchWithKeyphrase:(NSString*) keyphrase;
- (void) subscribe;
- (void) showSubscriptionsPopupInRect:(CGRect) rect;
- (NSInteger) currentSubviewTag;

@end

/**
 @class PCKioskNavigationBar
 @brief This class implements kiosk navigation bar
 */
@interface PCKioskNavigationBar : UIView <UITextFieldDelegate>
{

	UIButton			*subscribeBtn;
    UIButton            *switchKioskViewButton; ///< button for switching kiosk to next subview
    UIImageView         *kioskTitleImageView; ///< kiosk title image
    UILabel             *kioskTitleLabel; ///< kiosk title label
}


/**
 @brief Delegate for processing navigation bar events
 */
@property (nonatomic, assign) id<PCKioskNavigationBarDelegate> delegate;

/**
 @brief Input field for search in revisions
 */
@property (nonatomic, retain) UITextField *searchTextField;

/**
 @brief Init navigation bar elements
 */
- (void) initElements;

@end
