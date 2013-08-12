//
//  PCPrivacyPolicyViewController.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 19.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCMSEmailController.h"

@interface PCPrivacyPolicyViewController : UIViewController <PCMSEmailControllerDelegate>
{
    PCMSEmailController* emailController;
}

@property (retain, nonatomic) IBOutlet UIButton *contactUsButton;

- (IBAction)contactUsButtonTapped:(id)sender;

@end
