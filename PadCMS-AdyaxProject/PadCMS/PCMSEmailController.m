//
//  PCMSEmailController.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 07.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCMSEmailController.h"
#import "PCLocalizationManager.h"

@implementation PCMSEmailController

#pragma mark Properties

@synthesize delegate = _delegate;
@synthesize emailViewController = _emailViewController;

#pragma mark PCEmailController instance methods

- (id) init
{
	self = [super init];
    
    if (self) 
    {
        _delegate = nil;
        _emailViewController = nil;
    }
    
	return self;
}

- (void) dealloc
{   
    [_emailViewController release], _emailViewController = nil;
    _delegate = nil;
    
    [super dealloc];
}

- (void) emailShow
{
	if (![MFMailComposeViewController canSendMail])
	{
		UIAlertView *errorAllert = [[UIAlertView alloc] 
									initWithTitle:[PCLocalizationManager localizedStringForKey:@"TITLE_ERROR_SENDING_EMAIL"
                                                                                         value:@"Error sending email!"]
									message:[PCLocalizationManager localizedStringForKey:@"MSG_EMAIL_CLIENT_IS_NOT_CONFIGURED"
                                                                                   value:@"Email client is not configured."]
									delegate:nil
									cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                             value:@"OK"]
									otherButtonTitles:nil];
        
        [errorAllert show];
		[errorAllert release];
		
		return;
	}
    
    if (_emailViewController == nil)
    {
        _emailViewController = [[MFMailComposeViewController alloc] init];
    }
    
	self.emailViewController.mailComposeDelegate = self;
    
    [self.emailViewController setToRecipients:[NSArray arrayWithObject:@"support@padcms.net"]];
    [self.emailViewController setSubject:NSLocalizedString(@"PadCMS application", nil)];
	
    if (self.delegate)
    {
        [self.delegate emailControllerShow:self.emailViewController];
    }
    else
    {
        NSLog(@"PCMSEmailController.delegate is not defined");
    }
}

- (void) mailComposeController: (MFMailComposeViewController *)controller didFinishWithResult: (MFMailComposeResult)result error: (NSError *)error
{
    [self.delegate emailControllerDismiss:controller];
}

@end
