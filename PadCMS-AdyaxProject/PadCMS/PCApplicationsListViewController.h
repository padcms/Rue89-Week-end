//
//  PCApplicationsListViewController.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCAccount.h"

@class PCIssuesListViewController;
@class PCMSMainSplitViewController;

/**
 @class PCApplicationsListViewController
 @brief View controller with list of applications available
 */
@interface PCApplicationsListViewController : UITableViewController

/**
 @brief PCIssuesListViewController instance to display currently selected application
 */
@property (retain, nonatomic) PCIssuesListViewController *issuesListViewController;

/**
 @brief Main split view controller that contains current instance of PCApplicationsListViewController
 */
@property (retain, nonatomic) PCMSMainSplitViewController *mainSplitViewController;

@end
