//
//  PCTMainViewController.h
//  the_reader
//
//  Created by Mac OS on 7/23/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#define DEBUG_VERSION 1
#define kHideBarDelay 5

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
//#import "WiredNavigator.h"

#import "PCRevisionViewController.h"
#import "PCRueApplication.h"
#import "PCKioskViewController.h"
#import "PCKioskNavigationBar.h"
#import "PCSearchViewController.h"
#import "PadCMSCoder.h"
#import "PCKioskHeaderView.h"
#import "PCKioskFooterView.h"

@class MagManager, PCRevisionViewController, PadCMSCoder, PCSubscriptionsMenuView;

@interface PCTMainViewController : UIViewController
<UIScrollViewDelegate, UIAlertViewDelegate,
PCKioskViewControllerDelegateProtocol, PCKioskDataSourceProtocol,
PCKioskNavigationBarDelegate,
PCSearchViewControllerDelegate, PadCMSCodeDelegate>
{
    PCRueApplication* currentApplication;
    
	UIView                      *mainView;
	
	IBOutlet UIView             *airTopMenu;
	IBOutlet UIView             *airTopSummary;
		
	BOOL                        firstOrientLandscape;
	
	NSTimer                     *barTimer;

	UILabel                     *issueLabel_h;
	IBOutlet UILabel            *issueLabel_v;
	
	BOOL                        alreadyInit;
	
	BOOL                        currentTemplateLandscapeEnable;
    
	BOOL                         IsNotificationsBinded;
}

@property (nonatomic, strong) PCRevisionViewController *revisionViewController;
@property (nonatomic, assign) BOOL currentTemplateLandscapeEnable;
@property (nonatomic, assign) BOOL magManagerExist;
@property (nonatomic, strong) NSTimer* barTimer;
@property (nonatomic, strong) IBOutlet UIView* airTopMenu;
@property (nonatomic, strong) IBOutlet UIView* airTopSummary;
@property (nonatomic, strong) UIView* mainView;
@property (nonatomic, assign) BOOL firstOrientLandscape;
@property (nonatomic, assign) BOOL alreadyInit;

@property (nonatomic, strong) UILabel* issueLabel_h;
@property (nonatomic, strong) IBOutlet UILabel* issueLabel_v;

@property (nonatomic, strong) PCKioskViewController *kioskViewController;
@property (nonatomic, strong) PCKioskNavigationBar *kioskNavigationBar;
@property (nonatomic, strong) PadCMSCoder* padcmsCoder;
@property (nonatomic, strong) PCSubscriptionsMenuView *subscriptionsMenu;
@property (nonatomic, strong) PCKioskHeaderView * kioskHeaderView;
@property (nonatomic, strong) PCKioskFooterView * kioskFooterView;

- (void) startBarTimer;
- (void) stopBarTimer;

- (void) restart;
- (PCApplication*) getApplication;
- (void) switchToKiosk;

@end
