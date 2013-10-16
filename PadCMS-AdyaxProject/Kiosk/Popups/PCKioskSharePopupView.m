//
//  PCKioskSharePopupView.m
//  Pad CMS
//
//  Created by tar on 22.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskSharePopupView.h"
#import "MTLabel.h"
#import "PCApplication.h"
#import "PCEmailController.h"
#import "PCFacebookViewController.h"
#import "PCRueTwitterController.h"

#import "PCGooglePlusController.h"

@interface PCKioskSharePopupView()

@property (nonatomic, strong) PCEmailController * emailController;
@property (nonatomic, strong) PCFacebookViewController * facebookViewController;

@property (nonatomic, strong) PCGooglePlusController* googleController;

@end

@implementation PCKioskSharePopupView

- (void)loadContent {
    [super loadContent];
    
    CGRect contentFrame = self.frame;
    self.titleLabel.frame = CGRectMake( 0, 20, contentFrame.size.width, 50);
    self.descriptionLabel.frame = CGRectMake(0, 90, contentFrame.size.width, 60);
    
    self.titleLabel.text = @"Partagez Rue89 Week-end";
    //self.descriptionLabel.text = @"Il n’y a pas d’amour, il n’y a que des preuves d’amour. Alors faites\ndécouvrir votre magazine tablettes préféré à tout votre réseau !";
    
    [self.descriptionLabel setTextAlignment:RTTextAlignmentCenter];
    
    [self initShareButtonsAndLabels];
}

- (MTLabel *)shareTitleLabel {
    MTLabel * label = [[MTLabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:PCFontQuicksandBold size:16.5];
    label.characterSpacing = -0.4f;
    label.textAlignment = MTLabelTextAlignmentCenter;
    return label;
}

- (void)initShareButtonsAndLabels {
    
    //setup variables
    CGFloat padding = 7;
    CGPoint center = CGPointMake(roundf(self.frame.size.width/2), roundf(self.frame.size.height/2) + 50);
    CGSize buttonSize = CGSizeMake(75, 75);
    
    //facebook button
    UIButton * facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookButton setImage:[UIImage imageNamed:@"share_facebook"] forState:UIControlStateNormal];
    [facebookButton setFrame:CGRectMake(center.x - buttonSize.width - padding, center.y - buttonSize.height - padding, buttonSize.width, buttonSize.height)];
    [facebookButton addTarget:self action:@selector(facebookShow) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:facebookButton];
    
    //twitter button
    UIButton * twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [twitterButton setImage:[UIImage imageNamed:@"share_twitter"] forState:UIControlStateNormal];
    [twitterButton setFrame:CGRectMake(center.x + padding, center.y - buttonSize.height - padding, buttonSize.width, buttonSize.height)];
    [twitterButton addTarget:self action:@selector(twitterShow) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:twitterButton];
    
    //google button
    UIButton * googlePlusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [googlePlusButton setImage:[UIImage imageNamed:@"share_google_plus"] forState:UIControlStateNormal];
    [googlePlusButton setFrame:CGRectMake(center.x - buttonSize.width - padding, center.y + padding, buttonSize.width, buttonSize.height)];
    [googlePlusButton addTarget:self action:@selector(googlePlusShareButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:googlePlusButton];
    
    //google button
    UIButton * mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mailButton setImage:[UIImage imageNamed:@"share_mail"] forState:UIControlStateNormal];
    [mailButton setFrame:CGRectMake(center.x + padding, center.y + padding, buttonSize.width, buttonSize.height)];
    [mailButton addTarget:self action:@selector(emailShow) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mailButton];
    
    
    
    //LABELS
    
    CGFloat labelWidth = 140;
    CGFloat labelHeight = 40;
    CGFloat labelTopPadding = 20;
    
    MTLabel * facebookLabel = [self shareTitleLabel];
    facebookLabel.text = @"SUR\nFACEBOOK";
    facebookLabel.frame = CGRectMake(facebookButton.frame.origin.x - labelWidth, facebookButton.frame.origin.y + labelTopPadding, labelWidth, labelHeight);
    facebookLabel.fontColor = UIColorFromRGB(0x3160bf);
    [self addSubview:facebookLabel];
    //facebookLabel.backgroundColor = [UIColor orangeColor];
    
    MTLabel * googlePlusLabel = [self shareTitleLabel];
    googlePlusLabel.text = @"SUR\nGOOGLE+";
    googlePlusLabel.frame = CGRectMake(googlePlusButton.frame.origin.x - labelWidth, googlePlusButton.frame.origin.y + labelTopPadding, labelWidth, labelHeight);
    googlePlusLabel.fontColor = UIColorFromRGB(0xbf4031);
    [self addSubview:googlePlusLabel];
    
    MTLabel * twitterLabel = [self shareTitleLabel];
    twitterLabel.text = @"SUR\nTWITTER";
    twitterLabel.frame = CGRectMake(CGRectGetMaxX(twitterButton.frame), twitterButton.frame.origin.y + labelTopPadding, labelWidth, labelHeight);
    twitterLabel.fontColor = UIColorFromRGB(0x32bde6);
    [self addSubview:twitterLabel];
    
    MTLabel * emailLabel = [self shareTitleLabel];
    emailLabel.text = @"PAR\nE-MAIL";
    emailLabel.frame = CGRectMake(CGRectGetMaxX(mailButton.frame), mailButton.frame.origin.y + labelTopPadding, labelWidth, labelHeight);
    emailLabel.fontColor = UIColorFromRGB(0xabadbe);
    [self addSubview:emailLabel];
}

- (void)emailShow
{

    //[shareMenu removeFromSuperview];
    if (!self.emailController)
    {
        //NSDictionary *emailMessage = [self.revision.issue.application.notifications objectForKey:PCEmailNotificationType];
        self.emailController = [[PCEmailController alloc] initWithMessage:self.emailMessage];
    }
    self.emailController.delegate = self.delegate;
    [self.emailController emailShow];
}

- (void)facebookShow
{
    if (!_facebookViewController)
    {
        //NSString *facebookMessage = [[self.revision.issue.application.notifications objectForKey:PCFacebookNotificationType]objectForKey:PCApplicationNotificationMessageKey];
        _facebookViewController = [[PCFacebookViewController alloc] initWithMessage:self.facebookMessage];
    }
    [_facebookViewController initFacebookSharer];
}

- (void)twitterShow
{
    //Twitter Controller show
    //[self hideMenus];
    //[shareMenu removeFromSuperview];
   // NSString *twitterMessage = [[self.revision.issue.application.notifications objectForKey:PCTwitterNotificationType]objectForKey:PCApplicationNotificationMessageKey];
    if (isOS5())
    {
        PCRueTwitterController *twitterController = [[PCRueTwitterController alloc] initWithMessage:self.twitterMessage];
        twitterController.postUrl = [NSURL URLWithString:self.postUrl];
        twitterController.delegate = self.delegate;
        [twitterController showTwitterController];
    }
}

- (void) googlePlusShareButtonPresed:(UIButton*)sender
{
    self.googleController = [[PCGooglePlusController alloc]initWithMessage:self.googleMessage postUrl:self.postUrl];
    
    CGRect oldFrame = self.frame;
    
    [self.googleController shareWithDialog:^(UIView *dialogView) {
        
        //UIWindow* window = [[UIApplication sharedApplication].windows lastObject];
        
        CGRect startRect = [self convertRect:sender.frame fromView:sender.superview];
        
        dialogView.frame = startRect;
        [self addSubview:dialogView];
        
        CGRect finalFrame = self.bounds;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            dialogView.frame = finalFrame;
        }];
        
    } authorizationComplete:^(UIView *dialogView) {
        
        float screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGRect newFrameForPopup = self.frame;
        newFrameForPopup.origin.x = 0;
        newFrameForPopup.size.width = screenWidth;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.frame = newFrameForPopup;
            dialogView.frame = self.bounds;
        }];
        
    } complete:^(UIView *dialogView) {
        
        self.frame = oldFrame;
        
        [dialogView removeFromSuperview];
    }];
    
    
}

@end
