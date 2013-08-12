//
//  PCApplicationCell.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/17/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCApplication;

/**
 @brief Table view cell to display PCApplication instance properties
 */
@interface PCApplicationCell : UITableViewCell

/** 
 @brief application to display
 */
@property (retain, nonatomic) PCApplication *application;

/** 
 @brief Determining default cell height
 @return height for current PCApplicationCell type
 */
+ (CGFloat)cellHeight;

@end
