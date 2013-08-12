//
//  PCMSEmailController.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 07.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@protocol PCMSEmailControllerDelegate <NSObject>

@required

- (void)emailControllerDismiss:(MFMailComposeViewController *)currentPCEmailController;
- (void)emailControllerShow:(MFMailComposeViewController *)emailControllerToShow;

@end

@interface PCMSEmailController : NSObject <MFMailComposeViewControllerDelegate>
{
    MFMailComposeViewController *_emailViewController;
}

@property (nonatomic, assign, readwrite) id <PCMSEmailControllerDelegate> delegate;
@property (nonatomic, retain) MFMailComposeViewController *emailViewController;

- (id) init;
- (void) emailShow;

@end
