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

#import "PCJSONKeys.h"
#import "RueDownloadManager.h"
#import "PCRevision+DataOfDownload.h"
#import "UINavigationController+BalancedTransition.h"
#import "PCRevisionSummaryPopup.h"

#import "RueSubscriptionManager.h"
#import "SubscribeMenuPopuverController.h"

@interface PCTMainViewController() <PCKioskHeaderViewDelegate, PCKioskPopupViewDelegate, PCKioskSharePopupViewDelegate, PCKioskFooterViewDelegate, RueSubscriptionManagerDelegate>

@property (nonatomic, strong) SubscribeMenuPopuverController* subscribePopoverController;

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

static NSString* newsstand_cover_key = @"application_newsstand_cover_path";

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
    //[self showIntroPopup];
    
    [self performSelector:@selector(showIntroPopup) withObject:nil afterDelay:0.1f];
#endif
}

#ifdef RUE
- (void)showIntroPopup {
    PCKioskIntroPopupView * introPopup = [[PCKioskIntroPopupView alloc] initWithSize:CGSizeMake(640, 500) viewToShowIn:self.view];
    //introPopup.titleText = currentApplication...
    //introPopup.descriptionText = currentApplication...
    //introPopup.infoText = currentApplication...
    introPopup.purchaseDelegate = self;
    introPopup.delegate = self;
    [introPopup show];
}
#endif


- (void) switchToKiosk
{
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[PCDownloadManager sharedManager] cancelAllOperations];
    if(_revisionViewController)
    {
        mainView = nil;
#ifdef RUE
        [self.navigationController  popViewControllerAnimated:YES completion:nil];
        //_revisionViewController = nil;
#else
        [_revisionViewController.view removeFromSuperview];
        _revisionViewController = nil;
#endif

    }
}

- (void) switchToRevision:(PCRevision*)revisionToPresent
{
    _revisionViewController.view.userInteractionEnabled = NO;
    
    NSArray* previousNavigationMenuList = [(PCRueRevisionViewController*)_revisionViewController summaryPopup].revisionsList;
    float previousListOffset = [[(PCRueRevisionViewController*)_revisionViewController summaryPopup] contentOffset];
    
    [(PCRueRevisionViewController*)_revisionViewController fadeInViewWithDuration:0.3 completion:^{
        
        [self checkInterfaceOrientationForRevision:revisionToPresent];
        
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources" withExtension:@"bundle"]];
        _revisionViewController = [[PCRueRevisionViewController alloc]
                                   initWithNibName:@"PCRevisionViewController"
                                   bundle:bundle];
        
        [_revisionViewController setRevision:revisionToPresent];
        
        _revisionViewController.mainViewController = (PCMainViewController *)self;
        _revisionViewController.initialPageIndex = 0;
        
        [_revisionViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        [_revisionViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        _revisionViewController.view.userInteractionEnabled = NO;
        
        [(PCRueRevisionViewController*)_revisionViewController showSummaryMenuAnimated:NO withRevisionsList:previousNavigationMenuList menuOffset:previousListOffset];
        [(PCRueRevisionViewController*)_revisionViewController fadeInViewWithDuration:0 completion:nil];
        
        [self.navigationController popViewControllerAnimated:NO];
        [self.navigationController pushViewController:_revisionViewController animated:NO];
        
        [(PCRueRevisionViewController*)_revisionViewController fadeOutViewWithDuration:0.3 completion:^{
            
            [(PCRueRevisionViewController*)_revisionViewController hideSummaryMenuAnimated:YES];
            
            _revisionViewController.view.userInteractionEnabled = YES;
        }];
        
        self.mainView = _revisionViewController.view;
        self.mainView.tag = 100;
    }];
    
    return;
    
    // back/forward transition
    void (^showRevision)(PCRevision*) = ^(PCRevision* revision){
        
        NSUInteger index = [self.allRevisions indexOfObject:revisionToPresent];
        if(index != NSNotFound)
        {
            [self readRevisionWithIndex:index];
        }
    };
    
    if(self.navigationController.visibleViewController == _revisionViewController)
    {
        if(_revisionViewController.revision != revisionToPresent)
        {
            [self.navigationController popViewControllerAnimated:YES completion:^{
                
                showRevision(revisionToPresent);
            }];
        }
    }
    else
    {
        showRevision(revisionToPresent);
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
        NSString *plistPath = [[PCPathHelper pathForPrivateDocuments] stringByAppendingPathComponent:@"server.plist"];
        NSDictionary *previousPlistContent = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSDictionary *previousApplicationsList = [previousPlistContent objectForKey:PCJSONApplicationsKey];
        NSDictionary *previousApplicationParameters = nil;
        if(previousApplicationsList && previousApplicationsList.count)
        {
            previousApplicationParameters = [previousApplicationsList objectForKey:[[previousApplicationsList allKeys] objectAtIndex:0]];
        }
        
		AFNetworkReachabilityStatus remoteHostStatus = [PCDownloadApiClient sharedClient].networkReachabilityStatus;

		if(remoteHostStatus == AFNetworkReachabilityStatusNotReachable) 
		{
	/*		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Vous devez être connecté à Internet." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];*/
		
		}
		else
        {
			PadCMSCoder *padCMSCoder = [[PadCMSCoder alloc] initWithDelegate:self];
			self.padcmsCoder = padCMSCoder;
			if (![self.padcmsCoder syncServerPlistDownload])
			{
				/*UIAlertView* alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:alertCancelButtonTitle
                                                      otherButtonTitles:nil];
				[alert show];*/
			}
		}
        
        NSDictionary *plistContent = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
		if(plistContent == nil || [plistContent count] == 0)
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
				currentApplication = [[PCRueApplication alloc] initWithParameters:applicationParameters
																 rootDirectory:[PCPathHelper pathForPrivateDocuments]];
                
                if(previousApplicationParameters)
                {
                    [self syncronyzeApp:currentApplication fromOldApplicationParameters:previousApplicationParameters toNewApplicationParameters:applicationParameters];
                }
			}
			else
            {
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

- (void) changeShareMessageFromServerPlistContent:(NSDictionary*)previousContent toContent:(NSDictionary*)newContent
{
    NSDictionary *prevApplicationsList = [previousContent objectForKey:PCJSONApplicationsKey];
    NSDictionary *newApplicationsList = [newContent objectForKey:PCJSONApplicationsKey];
    
    NSString* prevMessage = nil;
    if(prevApplicationsList && prevApplicationsList.count)
    {
        NSDictionary* settingsDict = [prevApplicationsList objectForKey:[[prevApplicationsList allKeys] objectAtIndex:0]];
        prevMessage = [settingsDict objectForKey:PCJSONApplicationShareMessageKey];
    }
    NSString* newMessage = nil;
    if(newApplicationsList && newApplicationsList.count)
    {
        NSDictionary* settingsDict = [newApplicationsList objectForKey:[[newApplicationsList allKeys] objectAtIndex:0]];
        newMessage = [settingsDict objectForKey:PCJSONApplicationShareMessageKey];
    }
    
    if(stringExists(newMessage))
    {
        if(stringExists(prevMessage) && [newMessage isEqualToString:prevMessage] == NO)
        {
            currentApplication.shareMessage = prevMessage;
        }
    }
}

BOOL stringExists(NSString* str)
{
    return (str && [str isKindOfClass:[NSString class]] && str.length);
}

- (void) changeNewsstandIfNeededFromParameters:(NSDictionary*)previousParams toParameters:(NSDictionary*)newParams
{
    NSString* oldPath = [previousParams objectForKey:newsstand_cover_key];
    NSString* newPath = [newParams objectForKey:newsstand_cover_key];
    
#warning newsstand cover update uncomment "if" for release
//    if(stringExists(newPath) && (stringExists(oldPath) == NO || (stringExists(oldPath) && [newPath isEqualToString:oldPath] == NO)))
//    {
        NSString* fullPath = [[[PCConfig serverURLString]stringByAppendingPathComponent:newPath]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSData* newImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fullPath]];
        
        if(newImageData && newImageData.length)
        {
            UIImage* newImage = [UIImage imageWithData:newImageData];
            if(newImage)
            {
                [[UIApplication sharedApplication] setNewsstandIconImage:newImage];
            }
        }
//    }
}

- (void) syncronyzeApp:(PCRueApplication*)application fromOldApplicationParameters:(NSDictionary*)oldParametersList toNewApplicationParameters:(NSDictionary*)newParametersList
{
    [self changeNewsstandIfNeededFromParameters:oldParametersList toParameters:newParametersList];
    
    //[self changeShareMessageFromServerPlistContent:previousPlistContent toContent:plistContent];
    
}

-(void)restartApplication
{
    
    //what? restart? This just means that we are successfully subscribed to the app/purchased some item. Taras.
    
#ifdef RUE
    //make all paid (except individually paid) revisions free
    [[self shelfView] reload];
#else
    currentApplication = nil;
	self.padcmsCoder = nil;
	[self initManager];
	[self initKiosk];
#endif
	
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
    
    [RueSubscriptionManager sharedManager].delegate = self;
    
    //load all revisions
    self.allRevisions = [NSMutableArray new];
    
    NSArray *issues = [self getApplication].issues;
    for (PCIssue *issue in issues)
    {
        [self.allRevisions addObjectsFromArray:issue.revisions];
    }
    
    [self setArchivedRevisionStates];
    
    self.allRevisions = [NSMutableArray arrayWithArray:[self.allRevisions sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        PCRevision* rev1 = obj1;
        PCRevision* rev2 = obj2;
        NSDate* date1 = rev1.issue.publishDate ? rev1.issue.publishDate : rev1.createDate;
        NSDate* date2 = rev2.issue.publishDate ? rev2.issue.publishDate : rev2.createDate;
        
        NSComparisonResult result = [date1 compare:date2];
        
        switch (result)
        {
            case NSOrderedAscending:
                
                return NSOrderedDescending;
                
            case NSOrderedSame:
                
                return NSOrderedDescending;
                
            case NSOrderedDescending:
                
                return NSOrderedAscending;
        }
    }]];
    
    NSInteger           kioskBarHeight = 34.0;
    
    self.kioskNavigationBar = [[PCKioskNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kioskBarHeight)];
    self.kioskNavigationBar.delegate = self;
    
    Class kioskClass;
    
#ifdef RUE
    //header
    self.kioskHeaderView = (PCKioskHeaderView *)[[[NSBundle mainBundle] loadNibNamed:@"PCKioskHeaderView" owner:nil options:nil] objectAtIndex:0];
    self.kioskHeaderView.delegate = self;
    [self.view addSubview:self.kioskHeaderView];
    
    //subscription notification
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsFetched:) name:kProductFetchedNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscriptionsPurchased:) name:kSubscriptionsPurchasedNotification object:nil];

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
    
    UISwipeGestureRecognizer* recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.kioskViewController.view addGestureRecognizer:recognizer];
    
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
    return [self.allRevisions objectAtIndex:index];
    
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

- (NSUInteger) indexForRevision:(PCRevision*)revision
{
    return [self.allRevisions indexOfObject:revision];
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


- (NSArray*) allDownloadedRevisions
{
    NSMutableArray* sortedRevisions = [[NSMutableArray alloc]init];
    
    NSMutableArray* sortedDates = [[NSMutableArray alloc]init];
    
    NSArray* revisionsArray = self.allRevisions;
    NSLog(@"revisions count : %i", revisionsArray.count);
    
    for (PCRevision* revision in revisionsArray)
    {
        NSDate* downloadedDate = revision.dateOfDownload;
        
        if(downloadedDate)
        {
            int index = 0;
            
            for(int i = 0; i < sortedDates.count; ++i)
            {
                NSDate* currDate = [sortedDates objectAtIndex:i];
                if([downloadedDate compare:currDate] == NSOrderedAscending)
                {
                    index++;
                    continue;
                }
                else break;
            }
            
            [sortedDates insertObject:downloadedDate atIndex:index];
            [sortedRevisions insertObject:revision atIndex:index];
            
        }
    }
    
    return [NSArray arrayWithArray:sortedRevisions];
}

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

- (BOOL)isRevisionPaidWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
    
    return [[RueSubscriptionManager sharedManager] isRevisionPaid:revision];
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
        
//        if (_revisionViewController == nil)
//        {
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
            
            [self showRevisioViewController];
            
//        }
    }
}

- (void) showRevisioViewController
{
    _revisionViewController.mainViewController = (PCMainViewController *)self;
    _revisionViewController.initialPageIndex = 0;
    
#ifdef RUE
    [_revisionViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [_revisionViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [[self navigationController] pushViewController:_revisionViewController animated:YES completion:nil];
#else
    [self.view addSubview:_revisionViewController.view];
#endif
    
    self.mainView = _revisionViewController.view;
    self.mainView.tag = 100;
}

- (void) swipeLeft:(UISwipeGestureRecognizer*)recognizer
{
    if(_revisionViewController)
    {
        [self showRevisioViewController];
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
    PCRevision *revision = [self.allRevisions objectAtIndex:index];//[self revisionWithIndex:index];
    
    if(revision)
    {
		if([self isNotConnectedToNetwork])
		{
			[self showNoConnectionAlert];
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
    
//	if (revision)
//	{
//		NSLog(@"doPay");
//		
//		NSLog(@"productId: %@", revision.issue.productIdentifier);
//
//		if([[InAppPurchases sharedInstance] canMakePurchases])
//		{
//			
//			[[InAppPurchases sharedInstance] purchaseForProductId:revision.issue.productIdentifier];
//			
//		}
//		else
//		{
//			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"ALERT_TITLE_CANT_MAKE_PURCHASE"
//                                                                                                           value:@"You can't make the purchase"]
//                                                            message:nil
//                                                           delegate:nil
//                                                  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
//                                                                                                           value:@"OK"]
//                                                  otherButtonTitles:nil];
//			[alert show];
//		}
//
//	}
    
    [[RueSubscriptionManager sharedManager] purchaseRevision:revision completion:^{
        
        revision.issue.paid = YES;
        [[self shelfView] reload];
    }];
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
        
        if(progress < 1)
        {
            [self.kioskViewController downloadingProgressChangedWithRevisionIndex:[index integerValue]
                                                                   andProgess:progress];
            return YES;
        }
        else
        {
            [(PCRueKioskViewController*)self.kioskViewController downloadingContentFinishedWithRevisionIndex:[index integerValue]];
            return NO;
        }
        
    }];
    
    [(PCRueKioskViewController*)self.kioskViewController downloadingContentStartedWithRevisionIndex:[index integerValue]];
    
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

- (void)contactUsButtonTapped
{
    NSDictionary * emailParams = @{PCApplicationNotificationTitleKey : @"", PCApplicationNotificationMessageKey : @""};
    self.emailController = [[PCEmailController alloc] initWithMessage:emailParams];
    
    NSString * contactEmail = @"";
    if (currentApplication.contactEmail)
    {
        contactEmail = currentApplication.contactEmail;
    }
    [self.emailController.emailViewController setToRecipients:@[contactEmail]];
    
    self.emailController.delegate = self;
    [self.emailController emailShow];
    
}

- (void)restorePurchasesButtonTapped:(BOOL)needRenewIssues
{
//    [[InAppPurchases sharedInstance] renewSubscription:YES];
    
    if([self isNotConnectedToNetwork])
    {
        [self showNoConnectionAlert];
    }
    else
    {
        [[RueSubscriptionManager sharedManager] restorePurchasesCompletion:^(NSError *error) {
            
            if(error == nil)
            {
                [[self shelfView] reload];
            }
        }];
    }
}

- (void)subscribeButtonTapped:(PCKioskSubscribeButton*)button
{
    if([self isNotConnectedToNetwork])
    {
        [self showNoConnectionAlert];
    }
    else
    {
        NSArray* subscriptionsList = [[RueSubscriptionManager sharedManager] avaliableSubscriptions];
        CGRect buttonRect = [self.view convertRect:button.frame fromView:button.superview];
        
        self.subscribePopoverController = [SubscribeMenuPopuverController showMenuPopoverWithSubscriptions:subscriptionsList fromRect:buttonRect inView:self.view];
        
        return;
        
        [[RueSubscriptionManager sharedManager] subscribeCompletion:^(NSError *error) {
            
            if(error)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:error.localizedDescription
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                
                self.kioskHeaderView.subscribeButton.isSubscribedState = YES;
                [[self shelfView] reload];
            }
        }];
    }
}

- (BOOL) isNotConnectedToNetwork
{
    AFNetworkReachabilityStatus remoteHostStatus = [PCDownloadApiClient sharedClient].networkReachabilityStatus;
    return (remoteHostStatus == AFNetworkReachabilityStatusNotReachable);
}

- (void) showNoConnectionAlert
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"MSG_NO_NETWORK_CONNECTION"
                                                                                                   value:@"You must be connected to the Internet."]
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                                   value:@"OK"]
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)shareButtonTapped
{
    PCKioskSharePopupView * sharePopup = [[PCKioskSharePopupView alloc] initWithSize:CGSizeMake(640, 375) viewToShowIn:self.view];
    sharePopup.emailMessage = [currentApplication.notifications objectForKey:PCEmailNotificationType];
    sharePopup.facebookMessage = currentApplication.notifications[PCFacebookNotificationType][PCApplicationNotificationMessageKey];
    sharePopup.twitterMessage = currentApplication.notifications[PCTwitterNotificationType][PCApplicationNotificationMessageKey];
    sharePopup.googleMessage = currentApplication.notifications[PCGoogleNotificationType][PCApplicationNotificationMessageKey];
    sharePopup.descriptionLabel.text = currentApplication.shareMessage;
    sharePopup.postUrl = currentApplication.shareUrl;
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

- (void)kioskFooterView:(PCKioskFooterView *)footerView didSelectTag:(PCTag *)tag
{
    
    NSLog(@"title : %@, id : %i", tag.tagTitle, tag.tagId);
    
    self.selectedTag = tag;
    
    PCKioskShelfView * shelfView = [self shelfView];
    
    if (tag.tagId == TAG_ID_MAIN)
    {
        [shelfView showSubHeader:NO withTitle:nil];
    }
    else
    {
        [shelfView showSubHeader:YES withTitle:tag.tagTitle];
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
                [revision deleteFromDownloadManager];
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

#pragma mark - RueSubscriptionManagerDelegate Protocol

- (NSArray*) allIssues
{
    return [self getApplication].issues;
}

/*- (void)productsFetched:(NSNotification *)notification {
    //
    //    NSString * featureId = [[PCConfig subscriptions] lastObject];
    //
    //    BOOL isSubscriptionActive = [[MKStoreManager sharedManager] isSubscriptionActive:featureId];
    //
    //    NSLog(@"IS SUBSCRIBED productsFetched: %d", isSubscriptionActive);
    //
    //    self.kioskHeaderView.subscribeButton.isSubscribedState = isSubscriptionActive;
}*/

/*- (void)subscriptionsPurchased:(NSNotification *)notification {
    //    NSString * featureId = [[PCConfig subscriptions] lastObject];
    //
    //    BOOL isSubscriptionActive = [[MKStoreManager sharedManager] isSubscriptionActive:featureId];
    //
    //    NSLog(@"IS SUBSCRIBED subscriptionsPurchasedNotification: %d", isSubscriptionActive);
    //
    //    self.kioskHeaderView.subscribeButton.isSubscribedState = isSubscriptionActive;
}*/

#pragma mark -

@end