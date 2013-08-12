//
//  PCMSMainSplitViewController.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCMSMainSplitViewController.h"

#import "PCAccountViewController.h"
#import "PCPrivacyPolicyViewController.h"
#import "PCMSTopBarView.h"
#import "PCTopBarButtonView.h"

const NSUInteger ViewAutoresizingAllFlexible = UIViewAutoresizingFlexibleLeftMargin | 
UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | 
UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | 
UIViewAutoresizingFlexibleBottomMargin;

#define TopBarBackgroundImage @"top-bar-background.png"
#define TopBarTitleImage @"top-bar-title.png"
#define ApplicationsButtonImage @"top-bar-button-myapps-image.png"
#define AccountButtonImage @"top-bar-button-account-image.png"
#define ContactUsButtonImage @"top-bar-button-mail-image.png"
#define InformationButtonImage @"top-bar-button-info-image.png"

@interface PCMSMainSplitViewController ()
{
    PCMSTopBarView *_topBarView;
    
    UIView *_topBarTitleView;
    UILabel *_topBarTitleLabel;
    
    PCTopBarButtonView *_applicationsButtonView;
    PCTopBarButtonView *_accountButtonView;
    PCTopBarButtonView *_displayModeButtonView;
    PCTopBarButtonView *_contactUsButtonView;
    PCTopBarButtonView *_informationButtonView;
    
    UIPopoverController *_accountPopoverController;
    PCMSEmailController *_emailController;
}

- (void)createTopBar;
- (void)deleteTopBar;
- (void)createTopBarButtons;
- (void)deleteTopBarButtons;
- (void)createAccountPopover;
- (void)deleteAccountPopover;

- (void)accountButtonTapped:(UIButton *)sender;
- (void)contactUsButtonTapped:(UIButton *)sender;
- (void)informationButtonTapped:(UIButton *)sender;

@end


@implementation PCMSMainSplitViewController

#pragma mark - private

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createTopBar];
    [self createTopBarButtons];
    [self createAccountPopover];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self deleteAccountPopover];
    [self deleteTopBarButtons];
    [self deleteTopBar];
}

- (void)createTopBar
{
    _topBarView = [[PCMSTopBarView alloc] init];
    [self.view addSubview:_topBarTitleView];
    [self setTopBarView:_topBarView];
}

- (void)deleteTopBar
{
    [_topBarTitleLabel release], _topBarTitleLabel = nil;
    [_topBarTitleView release], _topBarTitleView = nil;
    [_topBarView release], _topBarView = nil;
}


- (void)createTopBarButtons
{
    // applications button
    _applicationsButtonView = [[PCSplitViewController topBarButtonViewWithImage:[UIImage imageNamed:ApplicationsButtonImage]
                                                                          title:NSLocalizedString(@"My Apps", nil) 
                                                                           size:CGSizeMake(93, 36)] retain];
    [self setPopoverButtonView:_applicationsButtonView];
    
    // account button
    _accountButtonView = [[PCSplitViewController topBarButtonViewWithImage:[UIImage imageNamed:AccountButtonImage] 
                                                                     title:NSLocalizedString(@"Account", nil) 
                                                                      size:CGSizeMake(93, 36)] retain];
    [_accountButtonView.button addTarget:self action:@selector(accountButtonTapped:) 
                        forControlEvents:UIControlEventTouchUpInside];
    [self addLeftBarButton:_accountButtonView];
    
    // contact us button   
    _contactUsButtonView = [[PCSplitViewController topBarButtonViewWithImage:[UIImage imageNamed:ContactUsButtonImage] 
                                                                       title:nil 
                                                                        size:CGSizeMake(36, 36)] retain];
    _contactUsButtonView.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_contactUsButtonView.button addTarget:self action:@selector(contactUsButtonTapped:) 
                          forControlEvents:UIControlEventTouchUpInside];
    [self addRightBarButton:_contactUsButtonView];
    
    // information button
    _informationButtonView = [[PCSplitViewController topBarButtonViewWithImage:[UIImage imageNamed:InformationButtonImage] 
                                                                         title:nil 
                                                                          size:CGSizeMake(36, 36)] retain];
    _informationButtonView.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_informationButtonView.button addTarget:self action:@selector(informationButtonTapped:) 
                            forControlEvents:UIControlEventTouchUpInside];
    [self addRightBarButton:_informationButtonView];
}

- (void)deleteTopBarButtons
{
    [_applicationsButtonView release], _applicationsButtonView = nil;
    [_accountButtonView release], _accountButtonView = nil;
    [_contactUsButtonView release], _contactUsButtonView = nil;
    [_informationButtonView release], _informationButtonView = nil;
}

- (void)createAccountPopover
{
    PCAccountViewController *accountController = [[PCAccountViewController alloc] init];
    UINavigationController *containerController = [[UINavigationController alloc] initWithRootViewController:accountController];
    [accountController release];
    _accountPopoverController = [[UIPopoverController alloc] initWithContentViewController:containerController];
    [containerController release];
    accountController.containerPopoverController = _accountPopoverController;
    CGSize contentSize = accountController.view.frame.size;
    [_accountPopoverController setPopoverContentSize:CGSizeMake(contentSize.width, 
                                                                contentSize.height + containerController.navigationBar.frame.size.height)];
}

- (void)deleteAccountPopover
{
    [_accountPopoverController dismissPopoverAnimated:NO];
    [_accountPopoverController release], _accountPopoverController = nil;
}

#pragma mark - public

- (void)setTopBarTitle:(NSString *)title
{
    [_topBarView setTitle:title];
}

- (void)setTopBarAccountName:(NSString *)accountName
{
    [_topBarView setAccountName:accountName];
}

#pragma mark - bar button items

- (void)accountButtonTapped:(UIButton *)sender
{
    if (_accountPopoverController.isPopoverVisible) {
        [_accountPopoverController dismissPopoverAnimated:YES];
    } else {
        UIButton *button = (UIButton *)sender;
        
        if (button.superview != nil) {
            [_accountPopoverController presentPopoverFromRect:button.frame inView:button.superview
                                     permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        } else {
            [_accountPopoverController presentPopoverFromRect:button.frame inView:self.view
                                     permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    }
}

- (void)contactUsButtonTapped:(UIButton *)sender
{
    //Email Controller show
    if (_emailController == nil)
    {
        _emailController = [[PCMSEmailController alloc] init];
    }
    _emailController.delegate = self;
    [_emailController emailShow];
}

- (void)informationButtonTapped:(UIButton *)sender
{
    PCPrivacyPolicyViewController *privacyPolicyViewController = [[PCPrivacyPolicyViewController alloc] init];
    privacyPolicyViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    UINavigationController *navigationController = [[UINavigationController alloc] 
                                                    initWithRootViewController:privacyPolicyViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:navigationController
                            animated:YES];
    
    [privacyPolicyViewController release];
    [navigationController release];
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
