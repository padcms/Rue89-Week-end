//
//  RueMainViewController.m
//  the_reader
//
//  Created by Mac OS on 7/23/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RueMainViewController.h"
#import "ZipArchive.h"
#import "PCRevisionViewController.h"
#import "Helper.h"
#import "PCSQLLiteModelBuilder.h"
#import "PCPathHelper.h"
#import "PCMacros.h"
#import "RueDownloadManagerWithShreddingResources.h"
#import "PCKioskSubviewsFactory.h"
#import "RueKioskShelfView.h"
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
#import "PCTag.h"
#import "PCJSONKeys.h"
//#import "RueDownloadManager.h"
#import "PCRevision+DataOfDownload.h"
#import "UINavigationController+BalancedTransition.h"
#import "PCRevisionSummaryPopup.h"

#import "RueSubscriptionManager.h"
#import "SubscribeMenuPopuverController.h"
#import "SubscriptionScheme.h"
#import "SubscriptionMenuActionSheet.h"
#import "RueIssue.h"

#import "RueAccessManager.h"
#import "PublisherPasswordAlertView.h"

#import "PCRueApplication.h"
#import "RuePadCMSCoder.h"

#import "PCKioskViewController+RemoveMemoryLeak.h"

@interface PCTMainViewController ()
{
    @public
    PCKioskViewController* _kioskViewController;
}
- (void) checkInterfaceOrientationForRevision:(PCRevision*)revision;
- (void) downloadRevisionFinishedWithIndex:(NSNumber*)index;
- (void) bindNotifications;

@end

@interface RueMainViewController() <PCKioskHeaderViewDelegate, PCKioskPopupViewDelegate, PCKioskSharePopupViewDelegate, PCKioskFooterViewDelegate, RueSubscriptionManagerDelegate, SubscribeMenuPopuverDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIAlertView* publisherPasswordAlert;

@property (nonatomic, strong) SubscribeMenuPopuverController* subscribePopoverController;

@property (nonatomic, strong) NSMutableArray * allRevisions;
@property (nonatomic, strong) PCTag * selectedTag;
@property (nonatomic, strong) PCEmailController * emailController;
@property (nonatomic, assign) BOOL needUpdate;

@property (nonatomic, strong) PCKioskNotificationPopup* kioskNotificationPopup;

@end

@implementation RueMainViewController

static NSString* newsstand_cover_key = @"application_newsstand_cover_path";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    
    
//    if(_revisionViewController != nil && _revisionViewController.revision != nil) {
//        
//        PCRevision *revision = _revisionViewController.revision;
//        
//        if (!revision.horizontalOrientation && !revision.horizontalMode) {
//            // vertical only revision
//            return UIInterfaceOrientationIsPortrait(interfaceOrientation);
//            
//        } else if (revision.horizontalOrientation && !revision.horizontalMode) {
//            // horizontal only revision
//            return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//            
//        } else if (!revision.horizontalOrientation && revision.horizontalMode) {
//            // vertical and horizontal revision
//            return YES;
//        }
//    
//        return NO;
//    }
//    
//    if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation)) {
//        return YES;
//    }
//    
//    return NO;
}

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

	self.magManagerExist = NO;
	
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
	static BOOL notFirstRun = NO;
	if(notFirstRun)
    {
        if(self.kioskViewController == nil)
        {
            [self initKiosk];
        }
        return;
    }
	
	[VersionManager sharedManager];
    
	notFirstRun = YES;
    
    [self initManager];
    [self initKiosk];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
#ifdef RUE
    //[self showIntroPopup];
    
    [self performSelector:@selector(showIntroPopup) withObject:nil afterDelay:0.1f];
#endif
}

- (void) viewDidUnload
{
    [self dissmissKiosk];
    [super viewDidUnload];
}

- (void) didEnterBackground
{
    
}

- (void) willEnterForeground
{
    if([self isKioskPresented])
    {
        [self update];
    }
    else
    {
        self.needUpdate = YES;
    }
}

- (BOOL) isKioskPresented
{
    if(mainView == nil)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) switchToKiosk
{
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[PCDownloadManager sharedManager] cancelAllOperations];
    if(self.revisionViewController)
    {
        mainView = nil;
#ifdef RUE
        [self.navigationController  popViewControllerAnimated:YES completion:^{
            
            if(self.needUpdate)
            {
                [self update];
            }
        }];
        //_revisionViewController = nil;
#else
        [_revisionViewController.view removeFromSuperview];
        _revisionViewController = nil;
#endif
        
    }
}

#ifdef RUE

#define FIRST_START_UP_KEY @"is_first_startup"

- (void)showIntroPopup
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FIRST_START_UP_KEY]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_START_UP_KEY];
        PCKioskIntroPopupView * introPopup = [[PCKioskIntroPopupView alloc] initWithSize:CGSizeMake(640, 500) viewToShowIn:self.view];
        //introPopup.titleText = currentApplication...
        introPopup.descriptionText = ((PCRueApplication*)currentApplication).wellcomeMessage;
        introPopup.infoText = ((PCRueApplication*)currentApplication).welcomeMessageUnderButton;
        //introPopup.infoText = currentApplication...
        introPopup.purchaseDelegate = self;
        introPopup.delegate = self;
        introPopup.subscribeButton.bottomLabel.text = ((PCRueApplication*)currentApplication).subscribeButtonTitle;
        [introPopup show];
    } else {
        [self showForOurReadersPopup];
    }

}
#endif


- (void) switchToRevision:(PCRevision*)revisionToPresent
{
    self.revisionViewController.view.userInteractionEnabled = NO;
    
    NSArray* previousNavigationMenuList = [(PCRueRevisionViewController*)self.revisionViewController summaryPopup].revisionsList;
    float previousListOffset = [[(PCRueRevisionViewController*)self.revisionViewController summaryPopup] contentOffset];
    
    [(PCRueRevisionViewController*)self.revisionViewController fadeInViewWithDuration:0.3 completion:^{
        
        self.revisionViewController.mainViewController = nil;
        
        [self checkInterfaceOrientationForRevision:revisionToPresent];
        
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources" withExtension:@"bundle"]];
        self.revisionViewController = [[PCRueRevisionViewController alloc]
                                   initWithNibName:@"PCRevisionViewController"
                                   bundle:bundle];
        
        [self.revisionViewController setRevision:revisionToPresent];
        
        self.revisionViewController.mainViewController = (PCMainViewController *)self;
        self.revisionViewController.initialPageIndex = 0;
        
        [self.revisionViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        [self.revisionViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        self.revisionViewController.view.userInteractionEnabled = NO;
        
        [(PCRueRevisionViewController*)self.revisionViewController showSummaryMenuAnimated:NO withRevisionsList:previousNavigationMenuList menuOffset:previousListOffset];
        [(PCRueRevisionViewController*)self.revisionViewController fadeInViewWithDuration:0 completion:nil];
        
        [self.navigationController popViewControllerAnimated:NO];
        [self.navigationController pushViewController:self.revisionViewController animated:NO];
        
        [(PCRueRevisionViewController*)self.revisionViewController fadeOutViewWithDuration:0.3 completion:^{
            
            [(PCRueRevisionViewController*)self.revisionViewController hideSummaryMenuAnimated:YES];
            
            self.revisionViewController.view.userInteractionEnabled = YES;
        }];
        
        self.mainView = self.revisionViewController.view;
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
    
    if(self.navigationController.visibleViewController == self.revisionViewController)
    {
        if(self.revisionViewController.revision != revisionToPresent)
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


- (PCRueApplication*) getApplication
{
    return (PCRueApplication*)currentApplication;
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
        NSDictionary *previousApplicationParameters = [RuePadCMSCoder applicationParametersFromCuurentPlistContent];
        
		if([PCDownloadApiClient sharedClient].networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable)
		{
			RuePadCMSCoder* padCMSCoder = [[RuePadCMSCoder alloc] initWithDelegate:self];
			self.padcmsCoder = padCMSCoder;
            
			[padCMSCoder syncServerPlistDownloadWithPassword:[RueAccessManager publisherPassword]];
            
            self.padcmsCoder = nil;
		}
        
        NSDictionary* applicationParametersAfterSyncPlist = [RuePadCMSCoder applicationParametersFromCuurentPlistContent];;
        
        if(applicationParametersAfterSyncPlist)
		{
			currentApplication = [[PCRueApplication alloc] initWithParameters:applicationParametersAfterSyncPlist
                                                                    rootDirectory:[PCPathHelper pathForPrivateDocuments]];
                
            if(previousApplicationParameters)
            {
                [self syncronyzeApp:[self getApplication] fromOldApplicationParameters:previousApplicationParameters toNewApplicationParameters:applicationParametersAfterSyncPlist];
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
            [self getApplication].shareMessage = prevMessage;
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
    
//#warning newsstand cover update uncomment "if" for release
    if(stringExists(newPath) && (stringExists(oldPath) == NO || (stringExists(oldPath) && [newPath isEqualToString:oldPath] == NO)))
    {
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
    }
}

- (void) syncronyzeApp:(PCRueApplication*)application fromOldApplicationParameters:(NSDictionary*)oldParametersList toNewApplicationParameters:(NSDictionary*)newParametersList
{
    [self changeNewsstandIfNeededFromParameters:oldParametersList toParameters:newParametersList];
    
    //[self changeShareMessageFromServerPlistContent:previousPlistContent toContent:plistContent];
    
}

-(void)restartApplication
{
    return;
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

#pragma mark - New kiosk implementation

- (RueKioskShelfView *)shelfView {
    return (RueKioskShelfView *)[self.kioskViewController.view viewWithTag:[PCKioskShelfView subviewTag]];
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
        NSDate* date1 = ((RueIssue*)rev1.issue).publishDate ? ((RueIssue*)rev1.issue).publishDate : rev1.createDate;
        NSDate* date2 = ((RueIssue*)rev2.issue).publishDate ? ((RueIssue*)rev2.issue).publishDate : rev2.createDate;
        
        NSComparisonResult result = [date1 compare:date2];
        
        switch (result)
        {
            case NSOrderedAscending:
                
                return NSOrderedDescending;
                
            case NSOrderedSame:
                if(rev1.issue.number.intValue > rev2.issue.number.intValue)
                {
                    return NSOrderedAscending;
                }
                else
                {
                    return NSOrderedDescending;
                }
                
            case NSOrderedDescending:
                
                return NSOrderedAscending;
        }
    }]];
    
    //NSInteger           kioskBarHeight = 34.0;
    
    //self.kioskNavigationBar = [[PCKioskNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kioskBarHeight)];
    //self.kioskNavigationBar.delegate = self;
    
    Class kioskClass;
    
    //header
    self.kioskHeaderView = (PCKioskHeaderView *)[[[NSBundle mainBundle] loadNibNamed:@"PCKioskHeaderView" owner:nil options:nil] objectAtIndex:0];
    self.kioskHeaderView.delegate = self;
    [self.view addSubview:self.kioskHeaderView];
    self.kioskHeaderView.subscribeButton.bottomLabel.text = [self getApplication].subscribeButtonTitle;
    
    //subscription notification
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsFetched:) name:kProductFetchedNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscriptionsPurchased:) name:kSubscriptionsPurchasedNotification object:nil];

    //footer
    self.kioskFooterView = [PCKioskFooterView footerViewForView:self.view];
    self.kioskFooterView.delegate = self;
    self.kioskFooterView.tags = [self getApplication].tags;
    [self.view addSubview:self.kioskFooterView];
    
    if (self.kioskFooterView.staticTags.count) {
        self.selectedTag = self.kioskFooterView.staticTags[0];
    }
    
    
    NSInteger footerHeight = self.kioskFooterView.frame.size.height - 3;
    NSInteger headerHeight = 136;
    
    kioskClass = [PCRueKioskViewController class];
    
    //gallery
    PCKioskSubviewsFactory      *factory = [[PCKioskSubviewsFactory alloc] init];
    
    PCKioskViewController* kioskController = [[kioskClass alloc] initWithKioskSubviewsFactory:factory andFrame:CGRectMake(0, headerHeight, self.view.bounds.size.width, self.view.bounds.size.height-headerHeight - footerHeight) andDataSource:self];
    
    _kioskViewController = kioskController;
    
    kioskController = nil;
    
    self.kioskViewController.delegate = self;
    [self.view addSubview:self.kioskViewController.view];
    [self.view bringSubviewToFront:self.kioskViewController.view];
    
    UISwipeGestureRecognizer* recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.kioskViewController.view addGestureRecognizer:recognizer];
    
    [self.view bringSubviewToFront:self.kioskHeaderView];
    [self.view bringSubviewToFront:self.kioskFooterView];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    [[RueSubscriptionManager sharedManager] checkForActiveSubscriptionAndNotifyDelegate];
}

- (void) dissmissKiosk
{
    self.kioskViewController.delegate = nil;
    [self.kioskViewController unloadView];
    [self.kioskViewController.view removeFromSuperview];
    self.kioskViewController = nil;
    
    self.kioskHeaderView.delegate = nil;
    [self.kioskHeaderView removeFromSuperview];
    self.kioskFooterView.delegate = nil;
    [self.kioskFooterView removeFromSuperview];
    
    self.kioskNavigationBar.delegate = nil;
    
//    self.kioskNavigationBa
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

- (BOOL)isRevisionPaidWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
    
    return [[RueSubscriptionManager sharedManager] isRevisionPaid:revision];
}

- (NSString *)issueAuthorWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return ((RueIssue*)revision.issue).author;
}

- (NSString *)issueExcerptWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return ((RueIssue*)revision.issue).excerpt;
}

- (NSString *)issueImageLargeURLWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return ((RueIssue*)revision.issue).imageLargeURL;
}

- (NSString *)issueImageSmallURLWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return ((RueIssue*)revision.issue).imageSmallURL;
}

- (NSInteger)issueWordsCountWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return ((RueIssue*)revision.issue).wordsCount;
}

- (NSString *)issueCategoryWithIndex:(NSInteger)index {
    PCRevision *revision = [self revisionWithIndex:index];
    return ((RueIssue*)revision.issue).category;
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
        
        if (![staticTagIds containsObject:@(self.selectedTag.tagId)])
        {
            predicate = [NSPredicate predicateWithBlock:^BOOL(PCRevision * revision, NSDictionary *bindings) {
                
                if (revision.state != PCRevisionStateArchived)
                {
                    for (PCTag * tag in ((RueIssue*)revision.issue).tags)
                    {
                        if (tag.tagId == self.selectedTag.tagId)
                        {
                            return YES;
                        }
                    }
                }

                return NO;
            }];
        }
        else if (self.selectedTag.tagId == TAG_ID_ARCHIVES)
        {
            predicate = [NSPredicate predicateWithBlock:^BOOL(PCRevision * revision, NSDictionary *bindings) {
                
                if (revision.state == PCRevisionStateArchived || [(RueIssue*)revision.issue isOld])
                {
                    return YES;
                }
                else
                {
                    return NO;
                }
            }];
        }
        else if (self.selectedTag.tagId == TAG_ID_FREE)
        {
            predicate = [NSPredicate predicateWithBlock:^BOOL(PCRevision * revision, NSDictionary *bindings){
                
                if ([(RueIssue*)revision.issue pricingPlan] == IssuePricingPlanFree && (revision.state != PCRevisionStateArchived) && ((RueIssue*)revision.issue).isOld == NO)
                {
                    return YES;
                }
                
                return NO;
            }];
        }
        else if (self.selectedTag.tagId == TAG_ID_MAIN)
        {
            predicate = [NSPredicate predicateWithBlock:^BOOL(PCRevision * revision, NSDictionary *bindings) {
                
                if (revision.state != PCRevisionStateArchived && ((RueIssue*)revision.issue).isOld == NO)
                {
                    return YES;
                }
                else
                {
                    return NO;
                }
            }];
        }
        
        allSortedRevisions = [self.allRevisions filteredArrayUsingPredicate:predicate];
    }
    
    
    
    return allSortedRevisions;
}

#pragma mark - PCKioskViewControllerDelegateProtocol

//- (void) tapInKiosk
//{
//    subscriptionsMenu.hidden = YES;
//}

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
            self.revisionViewController = [[PCRueRevisionViewController alloc]
                                       initWithNibName:@"PCRevisionViewController"
                                       bundle:bundle];
#else
            self.revisionViewController = [[PCRevisionViewController alloc]
                                       initWithNibName:@"PCRevisionViewController"
                                       bundle:bundle];
#endif
        
            [self.revisionViewController setRevision:currentRevision];
            
            [self showRevisioViewController];
            
//        }
    }
}

- (void) showRevisioViewController
{
    self.revisionViewController.mainViewController = (PCMainViewController *)self;
    self.revisionViewController.initialPageIndex = 0;
    
#ifdef RUE
    [self.revisionViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self.revisionViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [[self navigationController] pushViewController:self.revisionViewController animated:YES completion:nil];
#else
    [self.view addSubview:self.revisionViewController.view];
#endif
    
    self.mainView = self.revisionViewController.view;
    self.mainView.tag = 100;
}

- (void) swipeLeft:(UISwipeGestureRecognizer*)recognizer
{
    if(self.revisionViewController)
    {
        [self showRevisioViewController];
    }
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

-(void) purchaseRevisionWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    [[RueSubscriptionManager sharedManager] purchaseRevision:revision completion:^(NSError* error){
        
        if(error)
        {
            [self showAlertWithError:error];
        }
        else
        {
            revision.issue.paid = YES;
        }
        
        [[self shelfView] updateElementsButtons];
    }];
    
    [[self shelfView] updateElementsButtons];
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

#pragma mark - I don't Know what is this.

- (void)previewRevisionWithIndex:(NSInteger)index {
    
}

- (BOOL)previewAvailableForRevisionWithIndex:(NSInteger)index {
    return NO;
}

#pragma mark - Download flow

- (void)downloadRevisionFinishedWithIndex:(NSNumber*)index
{
//    [self.kioskViewController downloadFinishedWithRevisionIndex:[index integerValue]];
    [super downloadRevisionFinishedWithIndex:index];
    
    PCRevision *revision = [self revisionWithIndex:[index integerValue]];
    
    [RueDownloadManagerWithShreddingResources startDownloadingRevision:revision progressBlock:^BOOL(float progress) {
        
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

//- (void)downloadRevisionFailedWithIndex:(NSNumber*)index
//{
//    [self.kioskViewController downloadFailedWithRevisionIndex:[index integerValue]];
//    
//    UIAlertView *errorAllert = [[UIAlertView alloc] 
//                                initWithTitle:[PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_DOWNLOADING_FAILED_TITLE"
//                                                                                     value:@"Error downloading issue!"]
//                                message:[PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_DOWNLOADING_FAILED_MESSAGE"
//                                                                               value:@"Try again later"] 
//                                delegate:nil
//                                cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
//                                                                                         value:@"OK"]
//                                otherButtonTitles:nil];
//    
//    [errorAllert show];
//    
//    PCRevision      *revision = [self revisionWithIndex:[index integerValue]];
//    if(revision)
//    {
//        [revision deleteContent];
//        [self.kioskViewController updateRevisionWithIndex:[index integerValue]];
//    }
//}

//- (void)downloadingRevisionProgressUpdate:(NSDictionary*)info
//{
//    NSNumber        *index = [info objectForKey:@"index"];
//    NSNumber        *progress = [info objectForKey:@"progress"];
//    
//    [self.kioskViewController downloadingProgressChangedWithRevisionIndex:[index integerValue]
//                                                               andProgess:[progress floatValue]];
//}

#pragma mark - PCKioskNavigationBarDelegate

//- (void) switchToNextKioskView
//{
//    [self.kioskViewController switchToNextSubview];
//}

//- (NSInteger) currentSubviewTag
//{
//    return [self.kioskViewController currentSubviewTag];
//}

//- (void) searchWithKeyphrase:(NSString*) keyphrase
//{
//    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources"
//                                                                       withExtension:@"bundle"]];
//    PCSearchViewController* searchViewController = [[PCSearchViewController alloc] initWithNibName:@"PCSearchViewController"
//                                                                                            bundle:bundle];
//    searchViewController.searchKeyphrase = keyphrase;
//    searchViewController.application = [self getApplication];
//    searchViewController.delegate = self;
//    
//    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) 
//    {
//        [self presentViewController:searchViewController animated:YES completion:nil];
//    } 
//    else 
//    {
//        [self presentModalViewController:searchViewController animated:YES];   
//    }
//}

//- (void) showSubscriptionsPopupInRect:(CGRect)rect
//{
//    if (!subscriptionsMenu)
//    {
//        subscriptionsMenu = [[PCSubscriptionsMenuView alloc] initWithFrame:rect andSubscriptionFlag:[currentApplication hasIssuesProductID]];
//        subscriptionsMenu.delegate = [InAppPurchases sharedInstance];
//        [self.view addSubview:subscriptionsMenu];
//        subscriptionsMenu.hidden = YES;
//    }
//    [subscriptionsMenu updateFrame:rect];
//    subscriptionsMenu.hidden = !subscriptionsMenu.hidden;
//    subscriptionsMenu.alpha = subscriptionsMenu.hidden?0.0:1.0;
//}

#pragma mark - PCKioskHeaderViewDelegate

- (void)contactUsButtonTapped
{
    NSMutableDictionary * emailParams = [NSMutableDictionary new];
    
    if ([self getApplication].contactEmailSubject) {
        [emailParams setObject:[self getApplication].contactEmailSubject forKey:PCApplicationNotificationTitleKey];
    }
    
    if ([self getApplication].contactEmailText) {
        [emailParams setObject:[self getApplication].contactEmailText forKey:PCApplicationNotificationMessageKey];
    }
    
    self.emailController = [[PCEmailController alloc] initWithMessage:emailParams];
    
    NSString * contactEmail = @"";
    if ([self getApplication].contactEmail)
    {
        contactEmail = [self getApplication].contactEmail;
    }
    [self.emailController.emailViewController setToRecipients:@[contactEmail]];
    
    self.emailController.delegate = self;
    [self.emailController emailShow];
    
}

- (void)restorePurchasesButtonTapped:(UIButton*)sender
{
//    [[InAppPurchases sharedInstance] renewSubscription:YES];
    
    if([self isNotConnectedToNetwork])
    {
        [self showNoConnectionAlert];
    }
    else
    {
        sender.enabled = NO;
        self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateSubscribing;
        
        [[RueSubscriptionManager sharedManager] restorePurchasesCompletion:^(NSError *error) {
            
            if(error)
            {
                [self showAlertWithError:error];
            }
            
            if([[RueSubscriptionManager sharedManager] isSubscribed])
            {
                self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateSubscribed;
            }
            else
            {
                self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateNotSubscribed;
            }
            
            [[self shelfView] updateElementsButtons];
            sender.enabled = YES;
        }];
        
        [[self shelfView] updateElementsButtons];
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
        button.state = PCKioskSubscribeButtonStateSubscribing;
        self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateSubscribing;
        
        [[RueSubscriptionManager sharedManager] getAvalialeSubscriptionsToBlock:^(NSArray *avaliableSubscriptions, NSError *error) {
            
            if(error)
            {
                [self showAlertWithError:error];
            }
            else
            {
                NSArray* subscriptionsList = avaliableSubscriptions;
                CGRect buttonRect = [self.view convertRect:button.frame fromView:button.superview];
                NSString* title = [self getApplication].subscriptionsListTitle;
                
                //self.subscribePopoverController = [SubscribeMenuPopuverController showMenuPopoverWithSubscriptions:subscriptionsList fromRect:buttonRect inView:self.view popoverTitle:titile];
                //self.subscribePopoverController.delegate = self;
                
                SubscriptionMenuActionSheet* sheet = [[SubscriptionMenuActionSheet alloc]initWithTitle:title subscriptions:subscriptionsList];
                sheet.delegate = self;
                sheet.initiatorButton = button;
                [sheet showFromRect:buttonRect inView:self.view animated:YES];
            }
            
            button.state = PCKioskSubscribeButtonStateNotSubscribed;
            self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateNotSubscribed;
            [[self shelfView]updateElementsButtons];
        }];
        [[self shelfView]updateElementsButtons];
    }
}

- (void) subscribeButtonTaped:(UIButton*)button fromRevision:(PCRevision*)revision
{
    if([self isNotConnectedToNetwork])
    {
        [self showNoConnectionAlert];
    }
    else
    {
        //button.state = PCKioskSubscribeButtonStateSubscribing;
        self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateSubscribing;
        
        [[RueSubscriptionManager sharedManager] getAvalialeSubscriptionsToBlock:^(NSArray *avaliableSubscriptions, NSError *error) {
            
            if(error)
            {
                [self showAlertWithError:error];
            }
            else
            {
                NSArray* subscriptionsList = avaliableSubscriptions;
                CGRect buttonRect = [self.view convertRect:button.frame fromView:button.superview];
                NSString* title = [self getApplication].subscriptionsListTitle;
                
                //self.subscribePopoverController = [SubscribeMenuPopuverController showMenuPopoverWithSubscriptions:subscriptionsList fromRect:buttonRect inView:self.view popoverTitle:titile];
                //self.subscribePopoverController.delegate = self;
                
                SubscriptionMenuActionSheet* sheet = [[SubscriptionMenuActionSheet alloc]initWithTitle:title subscriptions:subscriptionsList];
                sheet.delegate = self;
                //sheet.initiatorButton = button;
                [sheet showFromRect:buttonRect inView:self.view animated:YES];
                
                
            }
            
            [[self shelfView] updateElementsButtons];
            self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateNotSubscribed;
        }];
        
        [[self shelfView]updateElementsButtons];
    }
}

- (void)shareButtonTapped
{
    PCKioskSharePopupView * sharePopup = [[PCKioskSharePopupView alloc] initWithSize:CGSizeMake(640, 375) viewToShowIn:self.view];
    sharePopup.emailMessage = [currentApplication.notifications objectForKey:PCEmailNotificationType];
    sharePopup.facebookMessage = [self getApplication].shareMessage;//currentApplication.notifications[PCFacebookNotificationType][PCApplicationNotificationMessageKey];
    sharePopup.twitterMessage = [self getApplication].shareMessage;//currentApplication.notifications[PCTwitterNotificationType][PCApplicationNotificationMessageKey];
    sharePopup.googleMessage = [self getApplication].shareMessage;//currentApplication.notifications[PCGoogleNotificationType][PCApplicationNotificationMessageKey];
    sharePopup.descriptionLabel.text = [self getApplication].shareMessage;
    sharePopup.postUrl = [self getApplication].shareUrl;
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

- (void) secretGestureRecognized
{
    [self showPublisherPasswordAlert];
}

#pragma mark - PCKioskFooterViewDelegate

- (void)kioskFooterView:(PCKioskFooterView *)footerView didSelectTag:(PCTag *)tag
{
    
    NSLog(@"title : %@, id : %i", tag.tagTitle, tag.tagId);
    
    self.selectedTag = tag;
    
    RueKioskShelfView * shelfView = [self shelfView];
    
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

#pragma mark - PCKioskPopupViewDelegate

- (void)popupViewDidHide:(PCKioskPopupView *)popupView
{
    if ([popupView isKindOfClass:[PCKioskIntroPopupView class]])
    {
        [self showForOurReadersPopup];
    }
}

- (void)showForOurReadersPopup
{
    PCKioskNotificationPopup * popup = [[PCKioskNotificationPopup alloc] initWithSize:CGSizeMake(self.view.frame.size.width, 155) viewToShowIn:self.view];
    popup.titleLabel.text = @"À nos lecteurs";
    popup.descriptionLabel.text = [self getApplication].messageForReaders;
    [popup sizeToFitDescriptionLabelText];
    
    self.kioskNotificationPopup = popup;
    [popup show];
}

- (void) hideForOurReadersPopup
{
    if(self.kioskNotificationPopup)
    {
        [self.kioskNotificationPopup hideAnimated:NO completion:^{
            self.kioskNotificationPopup = nil;
        }];
    }
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == self.publisherPasswordAlert && buttonIndex == 1)
    {
        NSString* enteredText = [(PublisherPasswordAlertView*)alertView text];
        [RueAccessManager confirmPassword:enteredText completion:^(NSError *error) {
            
            if(error)
            {
                [self showAlertWithError:error];
            }
            else
            {
                [self update];
            }
        }];
    }
    else
    {
        if(buttonIndex == 1)
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
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if(alertView == self.publisherPasswordAlert)
    {
        return [(PublisherPasswordAlertView*)alertView hasText];
    }
    return YES;
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

- (NSArray*) subscriptionSchemes
{
    return [self getApplication].subscriptionsSchemes;
}

- (NSArray*) allIssues
{
    return [self getApplication].issues;
}

#pragma mark - SubscribeMenuPopuverDelegate Protocol

- (void) subscribtionScheme:(SubscriptionScheme *)scheme selectedInPopove:(SubscribeMenuPopuverController *)popover
{
    [self.subscribePopoverController dismissPopoverAnimated:YES];
    self.subscribePopoverController = nil;
    
    [[RueSubscriptionManager sharedManager] subscribeForScheme:scheme completion:^(NSError *error) {
     
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
            self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateSubscribed;
            [[self shelfView] reload];
        }
    }];
}

- (void) subscriptionIsActive:(SubscriptionScheme*)activeSubscriptionScheme
{
    self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateSubscribed;
    [[self shelfView]updateElementsButtons];
}

#pragma mark - UIActionSheetDelegate Protocol

- (void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    SubscriptionScheme* scheme = nil;
    
    NSArray* subscrList = [(SubscriptionMenuActionSheet*)actionSheet subscriptions];
    
    if(subscrList && subscrList.count > buttonIndex)
    {
        scheme = subscrList[buttonIndex];
    }
    
    PCKioskSubscribeButton* initiator = [(SubscriptionMenuActionSheet*)actionSheet initiatorButton];
    
    if(scheme)
    {
        initiator.state = PCKioskSubscribeButtonStateSubscribing;
        self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateSubscribing;
        
        [[RueSubscriptionManager sharedManager] subscribeForScheme:scheme completion:^(NSError *error) {
            
            if(error)
            {
                [self showAlertWithError:error];
                initiator.state = PCKioskSubscribeButtonStateNotSubscribed;
                self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateNotSubscribed;
            }
            else
            {
                initiator.state = PCKioskSubscribeButtonStateSubscribed;
                self.kioskHeaderView.subscribeButton.state = PCKioskSubscribeButtonStateSubscribed;
            }
            
            [[self shelfView] updateElementsButtons];
        }];
        
        [[self shelfView]updateElementsButtons];
    }
}

#pragma mark - Alerts

- (void) showPublisherPasswordAlert
{
    self.publisherPasswordAlert = [[PublisherPasswordAlertView alloc]initWithTitle:@"Publisher password." message:nil delegate:self cancelButtonTitle:@"Cancel" confirmButtonTitle:@"OK"];

    
    
    [self.publisherPasswordAlert show];
}

- (void) showAlertWithError:(NSError*)error
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                     message:error.localizedDescription
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
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

@end