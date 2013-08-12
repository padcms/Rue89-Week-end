//
//  PCIssuesViewController.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCKioskViewController.h"
#import "PCKioskViewControllerDelegateProtocol.h"
#import "PCMSEmailController.h"

@class PCApplication;
@class PCMSMainSplitViewController;

/**
 @class PCIssuesListViewController
 @brief View controller class that shows revisions list for a given application 
 */
@interface PCIssuesListViewController : UIViewController <PCKioskDataSourceProtocol, 
PCKioskViewControllerDelegateProtocol>

/**
 @brief PCMSMainSplitViewController instance that contains current view controller
 */
@property (retain, nonatomic) PCMSMainSplitViewController *mainSplitViewController;

/**
 @brief application with revisions to be shown
 */
@property (retain, nonatomic) PCApplication *application;  

@end
