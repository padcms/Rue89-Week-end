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
#import "PCKioskSharePopupView.h"
#import "PCKioskIntroPopupView.h"
#import "PCKioskNotificationPopup.h"
#import "PCRueRevisionViewController.h"
#import "PCKioskSubHeaderView.h"
#import "ArchivingDataSource.h"
#import "PCRueKioskViewController.h"

#import "RueDownloadManager.h"

@interface PCTMainViewController() <PCKioskHeaderViewDelegate, PCKioskPopupViewDelegate, PCKioskSharePopupViewDelegate, PCKioskFooterViewDelegate>

@property (nonatomic, strong) NSMutableArray * allRevisions;
@property (nonatomic, strong) PCTag * selectedTag;
@property (nonatomic, strong) PCEmailController * emailController;

- (void) initManager;
- (void) bindNotifications;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
        
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    
    
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


#pragma mark ViewController Methods

- (void) viewDidLoad
{

#ifdef  NSFoundationVersionNumber_iOS_6_1
    //iOS 7 status bar fix
    if (!(NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
#else
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
#endif
    
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
	
	notFirstRun = YES;
    
    [self initManager];
    [self initKiosk];

#ifdef RUE
    PCKioskIntroPopupView * introPopup = [[PCKioskIntroPopupView alloc] initWithSize:CGSizeMake(640, 500) viewToShowIn:self.view];
    introPopup.purchaseDelegate = self;
    introPopup.delegate = self;
    [introPopup show];
#endif
}


- (void) switchToKiosk
{
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[PCDownloadManager sharedManager] cancelAllOperations];
    if(_revisionViewController)
    {
        mainView = nil;
#ifdef RUE
        [self.navigationController  popViewControllerAnimated:YES];
        _revisionViewController = nil;
#else
        [_revisionViewController.view removeFromSuperview];
        _revisionViewController = nil;
#endif

    }
}


- (void)subscribe {
    //method is not used, just removing a warning
}

- (void) viewDidUnload
{
    [super viewDidUnload];
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

		if(remoteHostStatus == AFNetworkReachabilityStatusNotReachable) 
		{
	/*		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Vous devez être connecté à Internet." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];*/
		
		}
		else {
			PadCMSCoder *padCMSCoder = [[PadCMSCoder alloc] initWithDelegate:self];
			self.padcmsCoder = padCMSCoder;
			if (![self.padcmsCoder syncServerPlistDownload])
			{
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:alertCancelButtonTitle
                                                      otherButtonTitles:nil];
				[alert show];
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

		}
		else if([plistContent count]==0)
		{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:alertCancelButtonTitle
                                                  otherButtonTitles:nil];
			[alert show];	
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
			}

		}
	}
}

-(void)restartApplication
{
	currentApplication = nil;
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
}

#pragma mark - New kiosk implementation

- (PCKioskShelfView *)shelfView {
    return (PCKioskShelfView *)[self.kioskViewController.view viewWithTag:[PCKioskShelfView subviewTag]];
}

- (void)setArchivedRevisionStates {
    
    NSArray * archivedRevisionIds = [ArchivingDataSource allArchivedRevisionIds];
    
    for (PCRevision * revision in self.allRevisions) {
        if ([archivedRevisionIds containsObject:@(revision.identifier)]) {
            revision.state = PCRevisionStateArchived;
        }
    }
}

- (void) initKiosk
{
	if (!currentApplication) return;
    
    
    //load all revisions
    self.allRevisions = [NSMutableArray new];
    
    NSArray *issues = [self getApplication].issues;
    for (PCIssue *issue in issues)
    {
        [self.allRevisions addObjectsFromArray:issue.revisions];
    }
    
    [self setArchivedRevisionStates];
    
    NSInteger           kioskBarHeight = 34.0;
    
    self.kioskNavigationBar = [[PCKioskNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kioskBarHeight)];
    self.kioskNavigationBar.delegate = self;
    
    Class kioskClass;
    
#ifdef RUE
    //header
    self.kioskHeaderView = (PCKioskHeaderView *)[[[NSBundle mainBundle] loadNibNamed:@"PCKioskHeaderView" owner:nil options:nil] objectAtIndex:0];
    self.kioskHeaderView.delegate = self;
    [self.view addSubview:self.kioskHeaderView];

    //footer
    self.kioskFooterView = [PCKioskFooterView footerViewForView:self.view];
    self.kioskFooterView.delegate = self;
    self.kioskFooterView.tags = currentApplication.tags;
    [self.view addSubview:self.kioskFooterView];
    
    if (self.kioskFooterView.staticTags.count) {
        self.selectedTag = self.kioskFooterView.staticTags[0];
    }
    
    
    NSInteger footerHeight = self.kioskFooterView.frame.size.height - 3;
    NSInteger headerHeight = 136;
    
    kioskClass = [PCRueKioskViewController class];
#else
    NSInteger footerHeight = 0;
    NSInteger headerHeight = 34;
    
    kioskClass = [PCKioskViewController class];
#endif
    

    
    //gallery
    PCKioskSubviewsFactory      *factory = [[PCKioskSubviewsFactory alloc] init];
    self.kioskViewController = [[kioskClass alloc] initWithKioskSubviewsFactory:factory
                                                                                  andFrame:CGRectMake(0, headerHeight, self.view.bounds.size.width, self.view.bounds.size.height-headerHeight - footerHeight)
                                                                             andDataSource:self];
    self.kioskViewController.delegate = self;
    [self.view addSubview:self.kioskViewController.view];
    [self.view bringSubviewToFront:self.kioskViewController.view];
    
#ifdef RUE
    //[self.view bringSubviewToFront:self.subHeaderView];
    [self.view bringSubviewToFront:self.kioskHeaderView];
    [self.view bringSubviewToFront:self.kioskFooterView];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
#else
    [self.view addSubview:self.kioskNavigationBar];
    [self.kioskNavigationBar initElements];
    [self.view bringSubviewToFront:self.kioskNavigationBar];
#endif
}

- (PCRevision*) revisionWithIndex:(NSInteger)index
{
    NSArray * sortedRevisions = [self allSortedRevisions];
    
    if (index>=0 && index<[sortedRevisions count])
    {
        PCRevision *revision = [sortedRevisions objectAtIndex:index];
        return revision;
    }
    
    return nil;
}

- (PCRevision*) revisionWithIdentifier:(NSInteger)identifier
{
    for(PCRevision *currentRevision in self.allRevisions)
    {
        if(currentRevision.identifier == identifier) return currentRevision;
    }
    
    return nil;
}

#pragma mark - PCKioskDataSourceProtocol

- (NSInteger)numberOfRevisions
{
    return [self.allRevisions count];
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

- (NSString *)issueAuthorWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return revision.issue.author;
}

- (NSString *)issueExcerptWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return revision.issue.excerpt;
}

- (NSString *)issueImageLargeURLWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return revision.issue.imageLargeURL;
}

- (NSString *)issueImageSmallURLWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return revision.issue.imageSmallURL;
}

- (NSInteger)issueWordsCountWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return revision.issue.wordsCount;
}


- (NSString *)issueCategoryWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return revision.issue.category;
}

- (NSDate *)revisionDateWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return revision.createDate;
}

- (NSArray *)allSortedRevisions {
    
    NSArray * allSortedRevisions = self.allRevisions;
    
    if (self.selectedTag) {
        
        NSArray * staticTagIds = [[self.kioskFooterView staticTags] valueForKey:@"tagId"];
        
        NSPredicate * predicate;
        
        if (![staticTagIds containsObject:@(self.selectedTag.tagId)]) {
            predicate = [NSPredicate predicateWithBlock:^BOOL(PCRevision * revision, NSDictionary *bindings) {
                if (revision.state != PCRevisionStateArchived) {
                    for (PCTag * tag in revision.issue.tags) {
                        if (tag.tagId == self.selectedTag.tagId) {
                            return YES;
                        }
                    }
                }

                return NO;
            }];
        } else if (self.selectedTag.tagId == TAG_ID_ARCHIVES) {
            predicate = [NSPredicate predicateWithBlock:^BOOL(PCRevision * revision, NSDictionary *bindings) {
                if (revision.state == PCRevisionStateArchived) {
                    return YES;
                }
                
                return NO;
            }];
        } else if (self.selectedTag.tagId == TAG_ID_FREE) {
            predicate = [NSPredicate predicateWithBlock:^BOOL(PCRevision * revision, NSDictionary *bindings) {
                if (revision.issue.isPaid && (revision.state != PCRevisionStateArchived)) {
                    return YES;
                }
                
                return NO;
            }];
        } else if (self.selectedTag.tagId == TAG_ID_MAIN) {
            predicate = [NSPredicate predicateWithBlock:^BOOL(PCRevision * revision, NSDictionary *bindings) {
                if (revision.state != PCRevisionStateArchived) {
                    return YES;
                }
                
                return NO;
            }];
        }
        

        
        allSortedRevisions = [self.allRevisions filteredArrayUsingPredicate:predicate];
    }
    
    
    return allSortedRevisions;
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

        //[PCDownloadManager sharedManager].revision = currentRevision;
        //[[PCDownloadManager sharedManager] startDownloading];
        
        if (_revisionViewController == nil)
        {
            NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources" withExtension:@"bundle"]];
#ifdef RUE
            _revisionViewController = [[PCRueRevisionViewController alloc]
                                       initWithNibName:@"PCRevisionViewController"
                                       bundle:bundle];
#else
            _revisionViewController = [[PCRevisionViewController alloc]
                                       initWithNibName:@"PCRevisionViewController"
                                       bundle:bundle];
#endif
        
            [_revisionViewController setRevision:currentRevision];
            _revisionViewController.mainViewController = (PCMainViewController *)self;
            _revisionViewController.initialPageIndex = 0;
            
#ifdef RUE
            [_revisionViewController setModalPresentationStyle:UIModalPresentationFullScreen];
            [_revisionViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            
            [[self navigationController] pushViewController:_revisionViewController animated:YES];
#else
            [self.view addSubview:_revisionViewController.view];
#endif
            

            
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
}

- (void) downloadRevisionWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if(revision)
    {
		
		AFNetworkReachabilityStatus remoteHostStatus = [PCDownloadApiClient sharedClient].networkReachabilityStatus;
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
		}

	}
	
}

- (void) archiveRevisionWithIndex:(NSInteger)index {
    
    PCRevision *revision = [self revisionWithIndex:index];
    revision.state = PCRevisionStateArchived;
    
    [[self shelfView] reload];
    
    [ArchivingDataSource addId:revision.identifier];
    
    
}

- (void)restoreRevisionWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    revision.state = PCRevisionStatePublished;
    
    [[self shelfView] reload];
    
    [ArchivingDataSource removeId:revision.identifier];
}

- (void) updateRevisionWithIndex:(NSInteger) index
{
}


#pragma mark - I don't Know what is this.

- (void)previewRevisionWithIndex:(NSInteger)index {
    
}

- (BOOL)previewAvailableForRevisionWithIndex:(NSInteger)index {
    return NO;
}

#pragma mark - Download flow

- (void)doDownloadRevisionWithIndex:(NSNumber *)index
{
    @autoreleasepool {
    
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
    
    
    }
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
    
    PCRevision *revision = [self revisionWithIndex:[index integerValue]];
    
    [RueDownloadManager startDownloadingRevision:revision progressBlock:^BOOL(float progress) {
        
        return YES;
    }];
    
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
    NSDictionary * emailParams = @{PCApplicationNotificationTitleKey : @"Subject", PCApplicationNotificationMessageKey : @"Message"};
    self.emailController = [[PCEmailController alloc] initWithMessage:emailParams];
    [self.emailController.emailViewController setToRecipients:@[@"xxxxxxxxx@adyax.com"]];

    self.emailController.delegate = self;
    [self.emailController emailShow];
}

- (void)restorePurchasesButtonTapped:(BOOL)needRenewIssues {
    [[InAppPurchases sharedInstance] renewSubscription:YES];
}

- (void)subscribeButtonTapped {
    [[InAppPurchases sharedInstance] newSubscription];
}

- (void)shareButtonTapped {
    PCKioskSharePopupView * sharePopup = [[PCKioskSharePopupView alloc] initWithSize:CGSizeMake(640, 375) viewToShowIn:self.view];
    sharePopup.emailMessage = [currentApplication.notifications objectForKey:PCEmailNotificationType];
    sharePopup.facebookMessage = [currentApplication.notifications objectForKey:PCApplicationNotificationMessageKey];
    sharePopup.twitterMessage = [currentApplication.notifications objectForKey:PCApplicationNotificationMessageKey];
    sharePopup.descriptionLabel.text = currentApplication.shareMessage;
    sharePopup.delegate = self;
    [sharePopup show];
}

- (void)logoButtonTapped {
    if (self.selectedTag.tagId != TAG_ID_MAIN) {
        [self.kioskFooterView selectFirstTag];
    } else {
        if ([[self shelfView] respondsToSelector:@selector(logoButtonTapped)]) {
            [[self shelfView] logoButtonTapped];
        }
    }
}

#pragma mark - PCKioskFooterViewDelegate

- (void)kioskFooterView:(PCKioskFooterView *)footerView didSelectTag:(PCTag *)tag {
    
    self.selectedTag = tag;
    
    PCKioskShelfView * shelfView = [self shelfView];
    
    if (tag.tagId == TAG_ID_ARCHIVES) {
        [shelfView showSubHeader:YES];
    } else {
        [shelfView showSubHeader:NO];
    }
    
    
    shelfView.shouldScrollToTopAfterReload = YES;
    [self shelfView].pageControl.currentPage = 1;
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
            _revisionViewController.mainViewController = (PCMainViewController *)self;
            _revisionViewController.initialPageIndex = pageIndex;
            [self.view addSubview:_revisionViewController.view];
            self.mainView = _revisionViewController.view;
            self.mainView.tag = 100;
        }
    }
}

#pragma mark - PCKioskPopupViewDelegate

- (void)popupViewDidHide:(PCKioskPopupView *)popupView {
    if ([popupView isKindOfClass:[PCKioskIntroPopupView class]]) {
        PCKioskNotificationPopup * popup = [[PCKioskNotificationPopup alloc] initWithSize:CGSizeMake(self.view.frame.size.width, 155) viewToShowIn:self.view];
        popup.titleLabel.text = @"À nos lecteurs";
        popup.descriptionLabel.text = currentApplication.messageForReaders;
        [popup sizeToFitDescriptionLabelText];
        [popup show];
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
                revision.state = PCRevisionStatePublished;
                [ArchivingDataSource removeId:revision.identifier];
                [self.kioskViewController updateRevisionWithIndex:index];
                
                [[self shelfView] reload];
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

#pragma mark PCEmailControllerDelegate methods

- (void)dismissPCEmailController:(MFMailComposeViewController *)currentPCEmailController
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

- (void)showPCEmailController:(MFMailComposeViewController *)emailControllerToShow
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

#pragma mark TwitterNewControllerDelegate methods

- (void)dismissPCNewTwitterController:(TWTweetComposeViewController *)currentPCTwitterNewController
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

- (void)showPCNewTwitterController:(TWTweetComposeViewController *)tweetController
{
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)])
    {
        [self presentViewController:tweetController animated:YES completion:nil];
    }
    else
    {
        [self presentModalViewController:tweetController animated:YES];
    }
}


@end