//
//  PCAccountViewController.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCAccountViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction)disconnectButtonTapped:(UIButton *)sender;

@property (nonatomic, retain) UIPopoverController *containerPopoverController;

@end
