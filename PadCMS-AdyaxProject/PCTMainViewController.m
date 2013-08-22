//
//  PCTMainViewController.m
//  the_reader
//
//  Created by Mac OS on 7/23/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PCTMainViewController.h"
#import "ZipArchive.h"
#import "PCRevisionViewController.h"
#import "Helper.h"
#import "PCSQLLiteModelBuilder.h"
#import "PCPathHelper.h"
#import "PCMacros.h"
#import "PCDownloadManager.h"
#import "PCKioskSubviewsFactory.h"
#import "PCKioskShelfView.h"
#import "PCKioskGalleryView.h"
#import "InAppPurchases.h"
#import "PCDownloadApiClient.h"
#import "VersionManager.h"
#import "PCLocalizationManager.h"
#import "PCConfig.h"
#import "PCSubscriptionsMenuView.h"
#import "PCKioskPopupView.h"

@interface PCTMainViewController() <PCKioskHeaderViewDelegate>

- (void) initManager;
- (void) showMagManagerView;
- (void) bindNotifications;
- (void) SearchResultSelectedNotification:(NSNotification *) notification;
- (void) updateApplicationData;

- (void) initKiosk;
- (PCRevision*) revisionWithIndex:(NSInteger)index;
- (PCRevision*) revisionWithIdentifier:(NSInteger)identifier;
- (void)doDownloadRevisionWithIndex:(NSNumber*)index;
- (void)downloadRevisionFinishedWithIndex:(NSNumber*)index;
- (void)downloadRevisionFailedWithIndex:(NSNumber*)index;
- (void)downloadRevisionCanceledWithIndex:(NSNumber*)index;
- (void)downloadingRevisionProgressUpdate:(NSDictionary*)info;

- (void)rotateToPortraitOrientation;
- (void)rotateToLandscapeOrientation;
- (void)rotateInterfaceIfNeedWithRevision:(PCRevision*)revision;

@end

@implementation PCTMainViewController

@synthesize revisionViewController = _revisionViewController;
@synthesize airTopMenu;
@synthesize airTopSummary;
@synthesize mainView;
@synthesize firstOrientLandscape;
@synthesize barTimer;
@synthesize issueLabel_h;
@synthesize issueLabel_v;
@synthesize magManagerExist;
@synthesize kiosk_req_v;
@synthesize kiosk_req_h;
//@synthesize navigator = _navigator;
@synthesize currentTemplateLandscapeEnable;
@synthesize alreadyInit;
@synthesize subscriptionsMenu;
@synthesize kioskViewController = _kioskViewController;
@synthesize kioskNavigationBar = _kioskNavigationBar;
@synthesize padcmsCoder = _padcmsCoder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _revisionViewController = nil;
        currentApplication = nil;
        mainView = nil;
        airTopMenu = nil;
        airTopSummary = nil;
        barTimer = nil;
        issueLabel_h = nil;
        issueLabel_v = nil;
        subscriptionsMenu = nil;
    }
    return nil;
}
/*
- (void) doBackgroundLoad
{
	NSAutoreleasePool   *pool = [[NSAutoreleasePool alloc] init];
    
	NSUserDefaults      *userDefaults = [NSUserDefaults standardUserDefaults];
    int                 revision = [Helper getInternalRevision];
	NSString            *zipFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.zip", revision]];
	NSFileManager       *fileManager = [NSFileManager defaultManager];
	NSDate              *packageModificationDate = nil;
	NSDictionary        *zipFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:zipFilePath
                                                                                  error:nil];
	BOOL                skipUnpacking = NO;

    
	if (zipFileAttributes != nil)
    {
		packageModificationDate = [zipFileAttributes fileModificationDate];
		NSLog(@"FILE MODIFICATION DATE: %@", [packageModificationDate description]);
	}
    
	NSDate              *currentFileModificationDate = [userDefaults objectForKey:@"current_content"];
	NSLog(@"current MODIFICATION DATE: %@", [currentFileModificationDate description]);
    
    
	if ([fileManager fileExistsAtPath:[[Helper getIssueDirectory] stringByAppendingPathComponent:@"manifest.xml"]])
    {
		if ((currentFileModificationDate != nil) && [currentFileModificationDate isEqualToDate:packageModificationDate])
        {
			skipUnpacking = YES;
			NSLog(@"\n\nskipUnpacking\n\n");
		}
	}

	if (!skipUnpacking)
    {
        
        ZipArchive      *zipArchive = [[ZipArchive alloc] init];
        BOOL            zipResult = [zipArchive UnzipOpenFile:zipFilePath];
        
        NSLog(@"%@", zipFilePath);

        if (zipResult)
        {
            [zipArchive UnzipFileTo:[Helper getIssueDirectory]
                     overWrite:YES];				
        }
        
        [zipArchive UnzipCloseFile];
        [zipArchive release];
		
		[userDefaults setObject:packageModificationDate
                         forKey:@"current_content"];
        
		[userDefaults synchronize];
	}	
    
 	//[self performSelectorOnMainThread:@selector(doFinishLoad) withObject:nil waitUntilDone:NO];
    [self viewDidLoadStuff];
    
	[pool release];
}*/

- (IBAction) btnUnloadTap:(id) sender//??!!
{
	/*
	if([[VersionManager sharedManager].items count] == 1)
	{
		NetworkStatus remoteHostStatus = [[VersionManager sharedManager].reachability currentReachabilityStatus];
		if(remoteHostStatus == NotReachable) 
		{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Vous devez être connecté à Internet."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];

			[alert show];
			[alert release];		
			return;		
		}
	}*/
	
	[self.kiosk_req_v startAnimating];
	[self.kiosk_req_h startAnimating];
	
//	[[VersionManager sharedManager] kioskTap];
	
	[self.kiosk_req_v stopAnimating]; 
	[self.kiosk_req_h stopAnimating];
}

#pragma mark Timer Methods

- (void) startBarTimer
{	
	[self stopBarTimer];
	
	self.barTimer = [NSTimer scheduledTimerWithTimeInterval:kHideBarDelay
                                                     target:self
                                                   selector:@selector(hideBars)
                                                   userInfo:nil
                                                    repeats:NO];
}

- (void) stopBarTimer
{
	if (self.barTimer != nil)
	{	
		[self.barTimer invalidate];
		self.barTimer = nil;
	}	
}
/*
- (void) hideBars
{
//	if (mm.baseAppViewType == 1)
//	{
//		[self toggleBottomMenu:NO animated:YES];
//		[self toggleTopMenu:NO animated:YES];
//	}
//	else
//	{
//		[self toggleTopMenu:NO animated:YES];
//	}
}*/

#pragma mark logical 
/*
- (void) removeMainScroll
{
	self.mainView.hidden = YES;
	self.firstOrientLandscape = YES;
	self.view.hidden = NO;
}*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
        
    return NO;
    
    
    if(_revisionViewController != nil && _revisionViewController.revision != nil) {
        
        PCRevision *revision = _revisionViewController.revision;
        
        if (!revision.horizontalOrientation && !revision.horizontalMode) {
            // vertical only revision
            return UIInterfaceOrientationIsPortrait(interfaceOrientation);
            
        } else if (revision.horizontalOrientation && !revision.horizontalMode) {
            // horizontal only revision
            return UIInterfaceOrientationIsLandscape(interfaceOrientation);
            
        } else if (!revision.horizontalOrientation && revision.horizontalMode) {
            // vertical and horizontal revision
            return YES;
        }
    
        return NO;
    }
    
    if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation)) {
        return YES;
    }
    
    return NO;
}

#pragma mark Rotate Methods

/*
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//	[self.navigator willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}*/

//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	if(!self.magManagerExist) return NO;
//	
//	if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
//	{
//		return YES;
//	}
//	else
//	{
//		return currentTemplateLandscapeEnable;
//	}
//	
//	return NO;
//}

#pragma mark ViewController Methods

- (void) viewDidLoad
{
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	UIDeviceOrientation devOrient = [UIDevice currentDevice].orientation;

    self.firstOrientLandscape = NO;
	if ((devOrient == UIDeviceOrientationLandscapeLeft) || (devOrient == UIDeviceOrientationLandscapeRight))
	{
		self.firstOrientLandscape = YES;
	}

	magManagerExist = NO;
	
	alreadyInit = NO;
	
	issueLabel_h.text = [Helper getIssueText];
	issueLabel_v.text = [Helper getIssueText];
    
  
    
    //TODO !!!!!!!!!!!!!!!!!!!!!NOT FOR KIOSQUE
    //[self performSelectorInBackground:@selector(doBackgroundLoad) withObject:nil];
    
    [self bindNotifications];
    
    
}

- (void) viewDidAppear:(BOOL)animated
{
    //TODO !!!!!!!!!!!!!!!!!!!!!NOT FOR KIOSQUE
	static BOOL notFirstRun;
	if(notFirstRun) return;
	
	[VersionManager sharedManager];	
//	[[VersionManager sharedManager] performSelectorInBackground:@selector(navigatorShouldAppear)
//                                                     withObject:nil];		
	notFirstRun = YES;
    
    [self initManager];
    [self initKiosk];
}

/*
- (void) viewDidLoadStuff//??
{
	[self performSelectorOnMainThread:@selector(doFinishLoad)
                           withObject:nil
                        waitUntilDone:NO];
	alreadyInit = YES;
}

- (void) doFinishLoad//??
{
	[self initManager];
	
	
	[[VersionManager sharedManager] appLoaded];
	
  
	[self showMagManagerView];
}

- (void) showMagManagerView//?
{
    NSInteger revisionID = [Helper getInternalRevision];
    if (revisionID < 0) return;
//    [self updateApplicationData];
//    PCIssue* currentMagazine = [currentApplication issueForRevisionWithId:revisionID];
//    

    PCIssue *currentIssue = [currentApplication.issues objectAtIndex:0];
    
    if (currentIssue == nil) return;
    
    PCRevision *currentRevision = [[currentIssue revisions] objectAtIndex:0];
    
    if (currentRevision)
    {
        [self rotateInterfaceIfNeedWithRevision:currentRevision];
        
        [PCDownloadManager sharedManager].revision = currentRevision;
        [[PCDownloadManager sharedManager] startDownloading];
      
        if (_revisionViewController == nil)
        {
            _revisionViewController = [[PCRevisionViewController alloc] 
                                      initWithNibName:@"PCRevisionViewController"
                                      bundle:nil];
            [_revisionViewController setRevision:currentRevision];
            _revisionViewController.mainViewController = self;
            _revisionViewController.initialPageIndex = [Helper getInternalPageIndex];
            [self.view addSubview:_revisionViewController.view];
            self.mainView = _revisionViewController.view;
            self.mainView.tag = 100;
        }
    }
}*/

- (void) switchToKiosk
{
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[PCDownloadManager sharedManager] cancelAllOperations];
    if(_revisionViewController)
    {
        [self btnUnloadTap:self];
        mainView = nil;
        
        [_revisionViewController.view removeFromSuperview];
        [_revisionViewController release];
        _revisionViewController = nil;
        //[self restart];
    }
}

- (void) viewDidUnload
{
    [super viewDidUnload];
}

- (void) dealloc
{
    [currentApplication release];
    [_revisionViewController release];
	[_padcmsCoder release], _padcmsCoder = nil;
    [super dealloc];
}

- (PCApplication*) getApplication
{
    return currentApplication;
}


- (void)initManager
{
    NSString        *alertTitle = [PCLocalizationManager localizedStringForKey:@"ALERT_TITLE_CANT_LOAD_MAGAZINES_LIST"
                                                                         value:@"The list of available magazines could not be downloaded"];
    
    NSString        *alertCancelButtonTitle = [PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                     value:@"OK"];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    
    if (currentApplication == nil)
    {
		AFNetworkReachabilityStatus remoteHostStatus = [PCDownloadApiClient sharedClient].networkReachabilityStatus;
	//	NetworkStatus remoteHostStatus = [[VersionManager sharedManager].reachability currentReachabilityStatus];
		if(remoteHostStatus == AFNetworkReachabilityStatusNotReachable) 
		{
	/*		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Vous devez être connecté à Internet." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];*/
		
		}
		else {
			PadCMSCoder *padCMSCoder = [[PadCMSCoder alloc] initWithDelegate:self];
			self.padcmsCoder = padCMSCoder;
			[padCMSCoder release];
			if (![self.padcmsCoder syncServerPlistDownload])
			{
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:alertCancelButtonTitle
                                                      otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		}

		        
        NSString *plistPath = [[PCPathHelper pathForPrivateDocuments] stringByAppendingPathComponent:@"server.plist"];
        NSDictionary *plistContent = [NSDictionary dictionaryWithContentsOfFile:plistPath];
		if(plistContent == nil)
		{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:alertCancelButtonTitle
                                                  otherButtonTitles:nil];
			[alert show];
			[alert release];

		}
		else if([plistContent count]==0)
		{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:alertCancelButtonTitle
                                                  otherButtonTitles:nil];
			[alert show];	
			[alert release];
		}
		else
		{
			NSDictionary *applicationsList = [plistContent objectForKey:PCJSONApplicationsKey];
			NSArray *keys = [applicationsList allKeys];
			
			if ([keys count] > 0)
			{
				NSDictionary *applicationParameters = [applicationsList objectForKey:[keys objectAtIndex:0]];
				currentApplication = [[PCApplication alloc] initWithParameters:applicationParameters 
																 rootDirectory:[PCPathHelper pathForPrivateDocuments]];
			}
			else {
				
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:alertCancelButtonTitle
                                                      otherButtonTitles:nil];
				[alert show];		
				[alert release];
			}

		}
	}
}

-(void)restartApplication
{
	[currentApplication release], currentApplication = nil;
	self.padcmsCoder = nil;
	[self initManager];
	[self initKiosk];
	
}

- (void) restart
{
	self.magManagerExist = NO;
	
	if(alreadyInit)
	{
		[self stopBarTimer];
        if (self.mainView)
        {
            self.mainView.hidden = YES;
            [self.mainView removeFromSuperview];
        }
	}
	
	alreadyInit = YES;
//	[self doFinishLoad];
}
/*
- (void) afterHorizontalDone
{
	[self performSelectorOnMainThread:@selector(viewDidLoadStuff)
                           withObject:nil
                        waitUntilDone:NO];	
}*/
- (void) bindNotifications
{
    if(IsNotificationsBinded) return;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateApplicationData)
                                                 name:PCApplicationDataWillUpdate
                                               object:nil];
    IsNotificationsBinded = YES;
}

- (void) updateApplicationData//??
{
    NSLog(@"updateApplicationData");
    
    NSString *plistPath = [[PCPathHelper pathForPrivateDocuments] stringByAppendingPathComponent:@"server.plist"];
    NSDictionary *applicationParameters = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    [currentApplication initWithParameters:applicationParameters 
                             rootDirectory:[PCPathHelper pathForPrivateDocuments]];
    
////    NSString* path = [[PCPathHelper issuesFolder] stringByAppendingPathComponent:@"server.plist"];
//    NSString* path = [[PCPathHelper pathForIssueWithId:magazineViewController.magazine.identifier 
//                                         applicationId:magazineViewController.magazine.application.identifier] 
//                      stringByAppendingPathComponent:@"server.plist"];
//
//    NSLog(@"path: %@", path);
//    
//    NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
//    [PCSQLLiteModelBuilder updateApplication:currentApplication withDictionary:dictionary];
//    //    [[NSNotificationCenter defaultCenter] postNotificationName:PCApplicationDataWillUpdate object:nil];
}

#pragma mark - New kiosk implementation

- (void) initKiosk
{
	if (!currentApplication) return;
    NSInteger           kioskBarHeight = 34.0;
    
    self.kioskNavigationBar = [[PCKioskNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kioskBarHeight)];
    self.kioskNavigationBar.delegate = self;
    
    
    //header
    self.kioskHeaderView = (PCKioskHeaderView *)[[[NSBundle mainBundle] loadNibNamed:@"PCKioskHeaderView" owner:nil options:nil] objectAtIndex:0];
    self.kioskHeaderView.delegate = self;
    [self.view addSubview:self.kioskHeaderView];
    

    //footer
    self.kioskFooterView = [PCKioskFooterView footerViewForView:self.view];
    [self.view addSubview:self.kioskFooterView];
    
    NSInteger footerHeight = self.kioskFooterView.frame.size.height - 3;
    
    NSInteger headerHeight = 136;
    
    //gallery
    PCKioskSubviewsFactory      *factory = [[[PCKioskSubviewsFactory alloc] init] autorelease];

    self.kioskViewController = [[PCKioskViewController alloc] initWithKioskSubviewsFactory:factory
                                                                                  andFrame:CGRectMake(0, headerHeight, self.view.bounds.size.width, self.view.bounds.size.height-headerHeight - footerHeight)
                                                                             andDataSource:self];
    
    self.kioskViewController.delegate = self;
    
    [self.view addSubview:self.kioskViewController.view];
    
    //[self.view addSubview:self.kioskNavigationBar];
    //[self.kioskNavigationBar initElements];
    //[self.view bringSubviewToFront:self.kioskNavigationBar];
    
    [self.view bringSubviewToFront:self.kioskViewController.view];
    
    [self.view bringSubviewToFront:self.kioskHeaderView];
    [self.view bringSubviewToFront:self.kioskFooterView];
    
    self.view.backgroundColor = [UIColor greenColor];
}

- (PCRevision*) revisionWithIndex:(NSInteger)index
{
    NSMutableArray *allRevisions = [[[NSMutableArray alloc] init] autorelease];
    
    NSArray *issues = [self getApplication].issues;
    for (PCIssue *issue in issues)
    {
        [allRevisions addObjectsFromArray:issue.revisions];
    }
    
    if (index>=0 && index<[allRevisions count])
    {
        PCRevision *revision = [allRevisions objectAtIndex:index];
        return revision;
    }
    
    return nil;
}

- (PCRevision*) revisionWithIdentifier:(NSInteger)identifier
{
    NSMutableArray *allRevisions = [[[NSMutableArray alloc] init] autorelease];
    
    NSArray *issues = [self getApplication].issues;
    for (PCIssue *issue in issues)
    {
        [allRevisions addObjectsFromArray:issue.revisions];
    }
    
    for(PCRevision *currentRevision in allRevisions)
    {
        if(currentRevision.identifier == identifier) return currentRevision;
    }
    
    return nil;
}

#pragma mark - PCKioskDataSourceProtocol

- (NSInteger)numberOfRevisions
{
    NSInteger revisionsCount = 0;
    
    NSArray *issues = [self getApplication].issues;
    for (PCIssue *issue in issues)
    {
        revisionsCount += [issue.revisions count];
    }
    
    return revisionsCount;
}

- (NSString *)issueTitleWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if(revision)
    {
        if(revision.issue)
        {
            return revision.issue.title;
        }
    }
    
    return @"";
}

- (NSString *)revisionTitleWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if(revision)
    {
        return revision.title;
    }
    
    return @"";
}

-(NSString*) revisionStateWithIndex:(NSInteger) index
{
    return @"";
}

- (BOOL)isRevisionDownloadedWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if (revision)
    {
        return  [revision isDownloaded];
    }
    
    return NO;
}

 -(BOOL)isRevisionPaidWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
    
    if (revision.issue)
    {
        return  revision.issue.paid;
    }
    
    return NO;
}

- (UIImage *)revisionCoverImageWithIndex:(NSInteger)index andDelegate:(id<PCKioskCoverImageProcessingProtocol>)delegate
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if (revision)
    {
        return  revision.coverImage;
    }
    
    return nil;
}

-(NSString *)priceWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
    return revision.issue.price;					
}

-(NSString *)productIdentifierWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
    return revision.issue.productIdentifier;
}

#pragma mark - PCKioskViewControllerDelegateProtocol

- (void) tapInKiosk
{
    subscriptionsMenu.hidden = YES;
}

- (void) readRevisionWithIndex:(NSInteger)index
{
    PCRevision *currentRevision = [self revisionWithIndex:index];

    if (currentRevision)
    {
        [self checkInterfaceOrientationForRevision:currentRevision];

        [PCDownloadManager sharedManager].revision = currentRevision;
        [[PCDownloadManager sharedManager] startDownloading];
        
        if (_revisionViewController == nil)
        {
            NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources" withExtension:@"bundle"]];
            _revisionViewController = [[PCRevisionViewController alloc] 
                                       initWithNibName:@"PCRevisionViewController"
                                       bundle:bundle];
        
            [_revisionViewController setRevision:currentRevision];
            _revisionViewController.mainViewController = (PCMainViewController *)self;
            _revisionViewController.initialPageIndex = 0;
            [self.view addSubview:_revisionViewController.view];
            self.mainView = _revisionViewController.view;
            self.mainView.tag = 100;
            
            
        }
    }
}

- (void) deleteRevisionDataWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    NSString    *messageLocalized = [PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_REMOVAL_CONFIRMATION_MESSAGE"
                                                                           value:@"Are you sure you want to remove this issue?"];
    
    NSString    *message = [NSString stringWithFormat:@"%@ (%@)", messageLocalized, revision.issue.title];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_REMOVAL_CONFIRMATION_BUTTON_TITLE_CANCEL"
                                                                                                   value:@"Cancel"]
                                          otherButtonTitles:[PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_REMOVAL_CONFIRMATION_BUTTON_TITLE_YES"
                                                                                                   value:@"Yes"],
                          nil];
	alert.delegate = self;
    alert.tag = index;
	[alert show];
	[alert release];
}

- (void) downloadRevisionWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if(revision)
    {
		
		AFNetworkReachabilityStatus remoteHostStatus = [PCDownloadApiClient sharedClient].networkReachabilityStatus;
	//	NetworkStatus remoteHostStatus = [[VersionManager sharedManager].reachability currentReachabilityStatus];
		if(remoteHostStatus == AFNetworkReachabilityStatusNotReachable) 
		{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"MSG_NO_NETWORK_CONNECTION"
                                                                                                           value:@"You must be connected to the Internet."]
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                                           value:@"OK"]
                                                  otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
			
		}
        [self.kioskViewController downloadStartedWithRevisionIndex:index];
        [self performSelectorInBackground:@selector(doDownloadRevisionWithIndex:) withObject:[NSNumber numberWithInteger:index]];
    }
}

- (void) cancelDownloadingRevisionWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if(revision)
    {
        [revision cancelDownloading];
    }
}

-(void) purchaseRevisionWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
	if (revision)
	{
		NSLog(@"doPay");
		
		NSLog(@"productId: %@", revision.issue.productIdentifier);

		if([[InAppPurchases sharedInstance] canMakePurchases])
		{
			
			[[InAppPurchases sharedInstance] purchaseForProductId:revision.issue.productIdentifier];
			
		}
		else
		{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"ALERT_TITLE_CANT_MAKE_PURCHASE"
                                                                                                           value:@"You can't make the purchase"]
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                                           value:@"OK"]
                                                  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}

	}
	
}

- (void) updateRevisionWithIndex:(NSInteger) index
{
}

#pragma mark - Download flow

- (void)doDownloadRevisionWithIndex:(NSNumber *)index
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    PCRevision          *revision = [self revisionWithIndex:[index integerValue]];
    
    if(revision)
    {
        [revision download:^{
            [self performSelectorOnMainThread:@selector(downloadRevisionFinishedWithIndex:)
                                   withObject:index
                                waitUntilDone:NO];
        } failed:^(NSError *error) {
            [self performSelectorOnMainThread:@selector(downloadRevisionFailedWithIndex:)
                                   withObject:index
                                waitUntilDone:NO];
        } canceled:^{
            [self performSelectorOnMainThread:@selector(downloadRevisionCanceledWithIndex:)
                                   withObject:index
                                waitUntilDone:NO];
        } progress:^(float progress) {
            NSDictionary        *info = [NSDictionary dictionaryWithObjectsAndKeys:index, @"index", [NSNumber numberWithFloat:progress], @"progress", nil];
            
            [self performSelectorOnMainThread:@selector(downloadingRevisionProgressUpdate:)
                                   withObject:info
                                waitUntilDone:NO];
        }];
    }
    
    
    [pool release];
}

- (void)downloadRevisionCanceledWithIndex:(NSNumber*)index
{
    [self.kioskViewController downloadCanceledWithRevisionIndex:[index integerValue]];

    PCRevision      *revision = [self revisionWithIndex:[index integerValue]];
    if(revision)
    {
        [revision deleteContent];
        [self.kioskViewController updateRevisionWithIndex:[index integerValue]];
    }
}

- (void)downloadRevisionFinishedWithIndex:(NSNumber*)index
{
    [self.kioskViewController downloadFinishedWithRevisionIndex:[index integerValue]];
    
}

- (void)downloadRevisionFailedWithIndex:(NSNumber*)index
{
    [self.kioskViewController downloadFailedWithRevisionIndex:[index integerValue]];
    
    UIAlertView *errorAllert = [[UIAlertView alloc] 
                                initWithTitle:[PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_DOWNLOADING_FAILED_TITLE"
                                                                                     value:@"Error downloading issue!"]
                                message:[PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_DOWNLOADING_FAILED_MESSAGE"
                                                                               value:@"Try again later"] 
                                delegate:nil
                                cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                         value:@"OK"]
                                otherButtonTitles:nil];
    
    [errorAllert show];
    [errorAllert release];
    
    PCRevision      *revision = [self revisionWithIndex:[index integerValue]];
    if(revision)
    {
        [revision deleteContent];
        [self.kioskViewController updateRevisionWithIndex:[index integerValue]];
    }
}

- (void)downloadingRevisionProgressUpdate:(NSDictionary*)info
{
    NSNumber        *index = [info objectForKey:@"index"];
    NSNumber        *progress = [info objectForKey:@"progress"];
    
    [self.kioskViewController downloadingProgressChangedWithRevisionIndex:[index integerValue]
                                                               andProgess:[progress floatValue]];
}

#pragma mark - PCKioskNavigationBarDelegate

- (void) switchToNextKioskView
{
    [self.kioskViewController switchToNextSubview];
}

- (NSInteger) currentSubviewTag
{
    return [self.kioskViewController currentSubviewTag];
}

- (void) searchWithKeyphrase:(NSString*) keyphrase
{
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources"
                                                                       withExtension:@"bundle"]];
    PCSearchViewController* searchViewController = [[PCSearchViewController alloc] initWithNibName:@"PCSearchViewController"
                                                                                            bundle:bundle];
    searchViewController.searchKeyphrase = keyphrase;
    searchViewController.application = [self getApplication];
    searchViewController.delegate = self;
    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) 
    {
        [self presentViewController:searchViewController animated:YES completion:nil];
    } 
    else 
    {
        [self presentModalViewController:searchViewController animated:YES];   
    }
    [searchViewController release];
}

- (void) showSubscriptionsPopupInRect:(CGRect)rect
{
    if (!subscriptionsMenu)
    {
        subscriptionsMenu = [[PCSubscriptionsMenuView alloc] initWithFrame:rect andSubscriptionFlag:[currentApplication hasIssuesProductID]];
        subscriptionsMenu.delegate = [InAppPurchases sharedInstance];
        [self.view addSubview:subscriptionsMenu];
        subscriptionsMenu.hidden = YES;
    }
    [subscriptionsMenu updateFrame:rect];
    subscriptionsMenu.hidden = !subscriptionsMenu.hidden;
    subscriptionsMenu.alpha = subscriptionsMenu.hidden?0.0:1.0;
}

#pragma mark - PCKioskHeaderViewDelegate

- (void)contactUsButtonTapped {
    
}

- (void)restorePurchasesButtonTapped:(BOOL)needRenewIssues {
    [[InAppPurchases sharedInstance] renewSubscription:YES];
}

- (void)subscribeButtonTapped {
    [[InAppPurchases sharedInstance] newSubscription];
}

- (void)shareButtonTapped {
    PCKioskPopupView * sharePopup = [[PCKioskPopupView alloc] initWithSize:CGSizeMake(400, 300) viewToShowIn:self.view];
    [sharePopup show];
}

#pragma mark - PCSearchViewControllerDelegate

- (void) showRevisionWithIdentifier:(NSInteger) revisionIdentifier andPageIndex:(NSInteger) pageIndex
{
    PCRevision *currentRevision = [self revisionWithIdentifier:revisionIdentifier];
    
    if (currentRevision)
    {
        [self checkInterfaceOrientationForRevision:currentRevision];
        
        [PCDownloadManager sharedManager].revision = currentRevision;
        [[PCDownloadManager sharedManager] startDownloading];
        
        if (_revisionViewController == nil)
        {
            NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources" withExtension:@"bundle"]];
            _revisionViewController = [[PCRevisionViewController alloc] 
                                       initWithNibName:@"PCRevisionViewController"
                                       bundle:bundle];
         
            [_revisionViewController setRevision:currentRevision];
            _revisionViewController.mainViewController = self;
            _revisionViewController.initialPageIndex = pageIndex;
            [self.view addSubview:_revisionViewController.view];
            self.mainView = _revisionViewController.view;
            self.mainView.tag = 100;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1)
	{
        NSInteger       index = alertView.tag;
        PCRevision *revision = [self revisionWithIndex:index];
        
        if(revision)
        {
            PCDownloadManager* manager = [PCDownloadManager sharedManager];
            if (manager.revision == revision)
            {
                [manager cancelAllOperations];
            }
            
            if (revision)
            {
                [revision deleteContent];
                [self.kioskViewController updateRevisionWithIndex:index];
            }
        }
	}
}

#pragma mark - interface orientations

- (void)rotateToPortraitOrientation
{
    NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        
        self.view.frame = CGRectMake(0, 0, 1024, 768);
        self.view.center = CGPointMake(512, 384);
        
        CGAffineTransform portraitTransform = CGAffineTransformMakeRotation(M_PI * 2);
        portraitTransform = CGAffineTransformTranslate(portraitTransform, -128.0, 128.0);
        self.view.transform = portraitTransform;
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        
    } completion:^(BOOL finished) {
        
        [self.kioskViewController deviceOrientationDidChange];
        
    }];
}

- (void)rotateToLandscapeOrientation
{
    NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        
        self.view.frame = CGRectMake(0, 0, 1024, 768);
        self.view.center = CGPointMake(512, 384);
        
        CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation( 90.0 * M_PI / -180.0 );
        landscapeTransform = CGAffineTransformTranslate( landscapeTransform, -128.0, -128.0 );
        self.view.transform = landscapeTransform;
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
        
    } completion:^(BOOL finished) {
        
        [self.kioskViewController deviceOrientationDidChange];
        
    }];
}

- (void)checkInterfaceOrientationForRevision:(PCRevision*)revision
{
    if (revision != nil) {
        UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        BOOL currentInterfaceAvailable = [revision supportsInterfaceOrientation:currentInterfaceOrientation];
        
        if (!currentInterfaceAvailable) {
            if (UIDeviceOrientationIsLandscape(currentInterfaceOrientation)) {
                [self rotateToPortraitOrientation];
            } else {
                [self rotateToLandscapeOrientation];
            }
        }
    }
}

@end