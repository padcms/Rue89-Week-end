//
//  RueMainViewController.h
//  the_reader
//
//  Created by Mac OS on 7/23/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PCTMainViewController.h"

#import "PCKioskHeaderView.h"
#import "PCKioskFooterView.h"

@class MagManager, PCRevisionViewController, PadCMSCoder, PCSubscriptionsMenuView, PCRueApplication;

@interface RueMainViewController : PCTMainViewController

@property (nonatomic, strong) PCKioskHeaderView * kioskHeaderView;
@property (nonatomic, strong) PCKioskFooterView * kioskFooterView;

- (PCRueApplication*) getApplication;

- (void) switchToKiosk;

- (void) switchToRevision:(PCRevision*)revision;

- (NSArray*) allDownloadedRevisions;

- (NSUInteger) indexForRevision:(PCRevision*)revision;

- (void) subscribeButtonTaped:(UIButton*)button fromRevision:(PCRevision*)revision;

@end
