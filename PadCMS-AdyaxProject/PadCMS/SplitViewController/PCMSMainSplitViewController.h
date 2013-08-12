//
//  PCMSMainSplitViewController.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCSplitViewController.h"
#import "PCMSEmailController.h"

/**
 @class PCMSMainSplitViewController
 @brief Main view controller class for PadCMS app. Specifies top bar and set of top bar buttons. 
 */
@interface PCMSMainSplitViewController : PCSplitViewController <PCMSEmailControllerDelegate>

/**
 @brief Sets title bar label text to title. 
 @param title - new title string
 */
- (void)setTopBarTitle:(NSString *)title;

/**
 @brief Sets title bar account name label text to accountName. 
 @param accountName - account name string
 */
- (void)setTopBarAccountName:(NSString *)accountName;

@end
