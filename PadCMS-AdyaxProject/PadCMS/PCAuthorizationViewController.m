//
//  PCLogInViewController.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCAuthorizationViewController.h"

#import "PCAccount.h"
#import "PCAppDelegate.h"
#import "PCApplicationsListViewController.h"
#import "PCConfig.h"
#import "PCIssuesListViewController.h"

#define PadCMSDemoAccountRequestAddress @"http://padcms.net/"
#define PadCMSContactUsAddress @"http://padcms.net/support"
#define CheckBoxCheckedImage @"checkbox-checked.png"
#define CheckBoxUncheckedImage @"checkbox-unchecked.png"

@interface PCAuthorizationViewController ()
{
    BOOL _ownBackEnd;
}

@property (retain, nonatomic) IBOutlet UIImageView *backEndUrlImageView;
@property (retain, nonatomic) IBOutlet UIImageView *serverAddressBackground;
@property (retain, nonatomic) IBOutlet UITextField *serverAddressTextField;
@property (retain, nonatomic) IBOutlet UITextField *loginTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UILabel *loginStatusLabel;
@property (retain, nonatomic) IBOutlet UIButton *ownBackEndButton;
@property (retain, nonatomic) IBOutlet UILabel *loginLabel;
@property (retain, nonatomic) IBOutlet UILabel *passwordLabel;
@property (retain, nonatomic) IBOutlet UILabel *backEndUrlLabel;
@property (retain, nonatomic) IBOutlet UIImageView *backEndUrlArrowImageView;
@property (retain, nonatomic) IBOutlet UIButton *askDemoAccountButton;
@property (retain, nonatomic) IBOutlet UIButton *signInButton;

- (IBAction)signInButtonTapped:(UIButton *)sender;
- (IBAction)askDemoAccountButtonTapped:(UIButton *)sender;
- (IBAction)contactUsButtonTapped:(UIButton *)sender;
- (IBAction)ownBackEndButtonTapped:(UIButton *)sender;

- (void)updateUI;
- (void)logInSucceed;
- (void)logInFailed;
- (void)connectAccountKVO;
- (void)disconnectAccountKVO;

@end

@implementation PCAuthorizationViewController

@synthesize backEndUrlImageView = _backEndUrlImageView;
@synthesize serverAddressBackground = _serverAddressBackground;
@synthesize serverAddressTextField = _serverAddressTextField;
@synthesize loginTextField = _loginTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize loginStatusLabel = _loginStatusLabel;
@synthesize ownBackEndButton = _ownBackEndButton;
@synthesize loginLabel = _loginLabel;
@synthesize passwordLabel = _passwordLabel;
@synthesize backEndUrlLabel = _backEndUrlLabel;
@synthesize backEndUrlArrowImageView = _backEndUrlArrowImageView;
@synthesize account = _account;
@synthesize askDemoAccountButton = _askDemoAccountButton;
@synthesize signInButton = _signInButton;

- (void)dealloc
{
    [_serverAddressTextField release];
    [_loginTextField release];
    [_passwordTextField release];
    [_loginStatusLabel release];
    [_account release];
    
    [_serverAddressBackground release];
    [_backEndUrlImageView release];
    [_ownBackEndButton release];
    [_loginLabel release];
    [_passwordLabel release];
    [_backEndUrlLabel release];
    [_backEndUrlArrowImageView release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"PCAuthorizationViewController" bundle:[NSBundle mainBundle]];
        
    if (self)
    {
        _ownBackEnd = NO;
        _serverAddressTextField = nil;
        _loginTextField = nil;
        _passwordTextField = nil;
        _loginStatusLabel = nil;
        _account = nil;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIFont *marydaleFont = [UIFont fontWithName:@"Marydale" size:26];
    
    self.loginStatusLabel.font = marydaleFont;
    self.loginStatusLabel.alpha = 0.5f;

    self.loginLabel.font = marydaleFont;
    self.loginLabel.text = NSLocalizedString(@"login", nil);
    self.loginLabel.alpha = 0.5f;
    
    self.passwordLabel.font = marydaleFont;
    self.passwordLabel.text = NSLocalizedString(@"password", nil);
    self.passwordLabel.alpha = 0.5f;
    
    self.backEndUrlLabel.font = marydaleFont;
    self.backEndUrlLabel.text = NSLocalizedString(@"Back End url", nil);
    self.backEndUrlLabel.alpha = 0.5f;
    
    [self.askDemoAccountButton setTitle:NSLocalizedString(@"Ask a demo account", nil)
                               forState:UIControlStateNormal];

    [self.signInButton setTitle:NSLocalizedString(@"Sign In", nil)
                       forState:UIControlStateNormal];
    
    [self.ownBackEndButton setTitle:NSLocalizedString(@"You have your own Back End?", nil)
                           forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [self setServerAddressTextField:nil];
    [self setLoginTextField:nil];
    [self setPasswordTextField:nil];
    [self setLoginStatusLabel:nil];
    
    [self setServerAddressBackground:nil];
    [self setBackEndUrlImageView:nil];
    [self setOwnBackEndButton:nil];
    [self setLoginLabel:nil];
    [self setPasswordLabel:nil];
    [self setBackEndUrlLabel:nil];
    [self setBackEndUrlArrowImageView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.loginStatusLabel.text = @"";
    
    self.serverAddressTextField.text = 
    _ownBackEnd ? self.account.serverAddress : [PCConfig serverURLString];
    self.loginTextField.text = self.account.userName;
    self.passwordTextField.text = self.account.password;

    [super viewWillAppear:animated];
    
    [self updateUI];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)updateUI
{
    if (_ownBackEnd)
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.backEndUrlImageView.alpha = 1;
            self.serverAddressTextField.alpha = 1;
            self.serverAddressBackground.alpha = 1;
            self.backEndUrlLabel.alpha = 0.5f;
            self.backEndUrlArrowImageView.alpha = 0.8f;
        }];
        
        [self.ownBackEndButton setImage:[UIImage imageNamed:CheckBoxCheckedImage] 
                               forState:UIControlStateNormal];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.backEndUrlImageView.alpha = 0;
            self.serverAddressTextField.alpha = 0;
            self.serverAddressBackground.alpha = 0;
            self.backEndUrlLabel.alpha = 0;
            self.backEndUrlArrowImageView.alpha = 0;
        }];

        [self.ownBackEndButton setImage:[UIImage imageNamed:CheckBoxUncheckedImage] 
                               forState:UIControlStateNormal];
    }
}

- (IBAction)signInButtonTapped:(UIButton *)sender
{
    [_account logInWithUserName:self.loginTextField.text 
                       password:self.passwordTextField.text 
                  serverAddress:self.serverAddressTextField.text];
}

- (IBAction)askDemoAccountButtonTapped:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PadCMSDemoAccountRequestAddress]];
}

- (IBAction)contactUsButtonTapped:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PadCMSContactUsAddress]];
}

- (IBAction)ownBackEndButtonTapped:(UIButton *)sender
{
    if (_ownBackEnd)
    {
        _ownBackEnd = NO;
    } 
    else
    {
        _ownBackEnd = YES;
    }

    [self updateUI];
}

- (void)logInSucceed
{
    self.loginStatusLabel.text = @"";
}

- (void)logInFailed
{
    self.loginStatusLabel.text = NSLocalizedString(@"Login failure", nil);
}

- (void)setAccount:(PCAccount *)account
{
    if (_account != account)
    {
        [self disconnectAccountKVO];
        [_account release];
        _account = [account retain];
        [self connectAccountKVO];
    }
}

#pragma mark KVO

- (void)connectAccountKVO
{
    if (_account == nil) return;
    
    [_account addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew 
                  context:NULL];
}

- (void)disconnectAccountKVO
{
    if (_account == nil) return;
    
    [_account removeObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                        change:(NSDictionary *)change context:(void *)context
{
    if (object == _account && [keyPath isEqualToString:@"state"])
    {
        PCAccountState accountState = [[change objectForKey:@"new"] intValue];
        
        switch (accountState) {
            case PCAccountStateInvalid:
                NSLog(@"ERROR. PCAuthorizationViewController. Recieved PCAccountStateInvalid");
                break;

            case PCAccountStateNotConnected:
                // nothing
                break;
            
            case PCAccountStateConnected:
                [self logInSucceed];
                break;
            
            case PCAccountStateError:
                [self logInFailed];
                break;
            
            default:
                NSLog(@"ERROR. PCAuthorizationViewController. Recieved wrong PCAccountState");
                break;
        }
    }
}

@end
