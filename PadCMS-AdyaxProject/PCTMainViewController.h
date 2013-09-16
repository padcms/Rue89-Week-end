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
#import "PCApplication.h"
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
    PCApplication* currentApplication;
    
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

@property (nonatomic, retain) PCRevisionViewController *revisionViewController;
@property (nonatomic, assign) BOOL currentTemplateLandscapeEnable;
@property (nonatomic, assign) BOOL magManagerExist;
@property (nonatomic, retain) NSTimer* barTimer;
@property (nonatomic, retain) IBOutlet UIView* airTopMenu;
@property (nonatomic, retain) IBOutlet UIView* airTopSummary;
@property (nonatomic, retain) UIView* mainView;
@property (nonatomic, assign) BOOL firstOrientLandscape;
@property (nonatomic, assign) BOOL alreadyInit;

@property (nonatomic, retain) UILabel* issueLabel_h;
@property (nonatomic, retain) IBOutlet UILabel* issueLabel_v;

@property (nonatomic, retain) PCKioskViewController *kioskViewController;
@property (nonatomic, retain) PCKioskNavigationBar *kioskNavigationBar;
@property (nonatomic, retain) PadCMSCoder* padcmsCoder;
@property (nonatomic, retain) PCSubscriptionsMenuView *subscriptionsMenu;
@property (nonatomic, retain) PCKioskHeaderView * kioskHeaderView;
@property (nonatomic, retain) PCKioskFooterView * kioskFooterView;

- (void) startBarTimer;
- (void) stopBarTimer;

- (void) restart;
- (PCApplication*) getApplication;
- (void) switchToKiosk;

@end
