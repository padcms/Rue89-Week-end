//
//  PCPrivacyPolicyViewController.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 19.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPrivacyPolicyViewController.h"

@implementation PCPrivacyPolicyViewController
@synthesize contactUsButton = _contactUsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Privacy Policy", nil);
    
    UIBarButtonItem *_closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                         style:UIBarButtonItemStyleBordered 
                                                                        target:self 
                                                                        action:@selector(closeButtonTapped:)];
    
    self.navigationItem.rightBarButtonItem = _closeButtonItem;
    [_closeButtonItem release];
    
    [self.contactUsButton setTitle:NSLocalizedString(@"Contact Us", nil)
                          forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)closeButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)contactUsButtonTapped:(id)sender
{
    //Email Controller show
    if (!emailController)
    {
        emailController = [[PCMSEmailController alloc] init];
    }
    emailController.delegate = self;
    [emailController emailShow];
}

#pragma mark - PCMSEmailControllerDelegate


- (void)emailControllerShow:(MFMailComposeViewController *)emailControllerToShow;
{
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) 
    {
        [self presentViewController:emailControllerToShow animated:YES completion:nil];
    } 
    else 
    {
        [self presentModalViewController:emailControllerToShow animated:YES];   
    }
}

- (void)emailControllerDismiss:(MFMailComposeViewController *)currentPCEmailController;
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    } 
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

@end
