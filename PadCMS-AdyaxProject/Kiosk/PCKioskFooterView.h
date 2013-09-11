//
//  PCKioskFooterView.h
//  Pad CMS
//
//  Created by tar on 16.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAG_ID_MAIN     -1000
#define TAG_ID_ARCHIVES -1001
#define TAG_ID_FREE     -1002

@class PCKioskFooterView;
@class PCTag;


/**
 @class PCKioskFooterViewDelegate
 */
@protocol PCKioskFooterViewDelegate <NSObject>

- (void)kioskFooterView:(PCKioskFooterView *)footerView didSelectTag:(PCTag *)tag;

@end


/**
 @class PCKioskFooterView 
 @brief Looks like horizontally scrollable list of tags
 in the bottom of the main kios page.
 */
@interface PCKioskFooterView : UIView

@property (nonatomic, assign) id<PCKioskFooterViewDelegate> delegate;

@property (nonatomic, retain) NSArray * tags;
@property (nonatomic, strong) NSArray * staticTags;

+ (PCKioskFooterView *)footerViewForView:(UIView *)view;

@end
