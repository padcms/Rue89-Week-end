//
//  PCIssuesViewController.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCIssuesListViewController.h"
#import "VersionManager.h"
#import "PCApplication.h"
#import "PCIssue.h"
#import "PCPrivacyPolicyViewController.h"
#import "PCNavigationControllerWithDismissableKeyboard.h"
#import "PCAccount.h"
#import "PCDownloadManager.h"
#import "PCRevisionViewController.h"
#import "Helper.h"
#import "PCMSKioskSubviewsFactory.h"
#import "PCKioskViewController.h"
#import "PCMSMainSplitViewController.h"
#import "PCTopBarButtonView.h"
#import "PCLocalizationManager.h"

#define ButtonBackground @"top-bar-button-background.png"
#define KioskFanViewButtonImage @"top-bar-button-kioskfan-image.png"
#define KioskShelfViewButtonImage @"top-bar-button-kioskshelf-image.png"


@interface PCIssuesListViewController ()
{
    PCTopBarButtonView *_displayModeButtonView;
    BOOL _previewMode;
    NSInteger _currentRevisionIndex;
}

@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) PCKioskViewController *kioskViewController;

- (void)createDisplayModeButton;
- (void)reloadData;
- (void)displayModeButtonTapped:(UIButton *)sender;
- (PCRevision *)revisionWithIndex:(NSInteger)index;
- (void)doDownloadRevisionWithIndex:(NSNumber*)index;
- (void)downloadRevisionFinishedWithIndex:(NSNumber*)index;
- (void)downloadRevisionFailedWithIndex:(NSNumber*)index;
- (void)downloadRevisionCanceledWithIndex:(NSNumber*)index;
- (void)downloadingRevisionProgressUpdate:(NSDictionary*)info;
- (void)readRevision:(PCRevision *)revision preview:(BOOL)preview;

@end


@implementation PCIssuesListViewController

@synthesize mainSplitViewController = _mainSplitViewController;
@synthesize application = _application;
@synthesize contentView = _contentView;
@synthesize kioskViewController = _kioskViewController;

- (void)dealloc
{
    [_mainSplitViewController release];
    [_application release];
    [_contentView release];
    [_displayModeButtonView release];
    
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"PCIssuesListViewController" bundle:nil];
    
    if (self != nil)
    {
        _displayModeButtonView = nil;
        _previewMode = NO;
    }
    
    return self;
}

- (void)setApplication:(PCApplication *)application
{
    if (_application != application)
    {
        [_application release];
        _application = [application retain];
    }
    
    [self reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize contentViewSize = self.contentView.frame.size;
    PCMSKioskSubviewsFactory *factory = [[[PCMSKioskSubviewsFactory alloc] init] autorelease];
    self.kioskViewController = [[[PCKioskViewController alloc] initWithKioskSubviewsFactory:factory
                                                                                  andFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)
                                                                             andDataSource:self] autorelease];
    self.kioskViewController.delegate = self;
    self.kioskViewController.view.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.kioskViewController.view];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self createDisplayModeButton];
}

- (void)viewDidUnload
{
    [self setContentView:nil];
    
    [super viewDidUnload];

    [_displayModeButtonView release], _displayModeButtonView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)createDisplayModeButton
{
    // display mode button
    _displayModeButtonView = [[PCSplitViewController topBarButtonViewWithImage:[UIImage imageNamed:KioskFanViewButtonImage] 
                                                                title:nil 
                                                                 size:CGSizeMake(36, 36)] retain];
    _displayModeButtonView.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_displayModeButtonView.button addTarget:self action:@selector(displayModeButtonTapped:) 
                 forControlEvents:UIControlEventTouchUpInside];
    [self.mainSplitViewController insertRightBarButton:_displayModeButtonView atIndex:0];
}

- (void)reloadData
{
    if (self.application != nil)
    {
        [self.mainSplitViewController setTopBarTitle:self.application.title];
    }
    else
    {
        [self.mainSplitViewController setTopBarTitle:@""];
    }
    
    [self.kioskViewController reloadSubviews];
}

- (void)displayModeButtonTapped:(UIButton *)sender
{
    static BOOL kioskShelfMode = YES;
    
    if (kioskShelfMode)
    {
        kioskShelfMode = NO;
        [_displayModeButtonView.button setImage:[UIImage imageNamed:KioskShelfViewButtonImage
                                                 ] 
                                       forState:UIControlStateNormal];
    }
    else
    {
        kioskShelfMode = YES;
        [_displayModeButtonView.button setImage:[UIImage imageNamed:KioskFanViewButtonImage]
                                       forState:UIControlStateNormal];
    }
    
    [self.kioskViewController switchToNextSubview];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

// TODO: for compatibility with PCRevisionViewController
- (void)switchToKiosk
{
    if (_previewMode) {
        PCRevisionViewController *revisionViewController = (PCRevisionViewController *)self.mainSplitViewController.presentedViewController;
        PCRevision *revision = revisionViewController.revision;
        
        if (revision != nil) {
            [revision deleteContent];
            [self.kioskViewController updateRevisionWithIndex:_currentRevisionIndex];
            _currentRevisionIndex = -1;
        }
        
        _previewMode = NO;
    }
	
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[PCDownloadManager sharedManager] cancelAllOperations];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.mainSplitViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Private

- (PCRevision *)revisionWithIndex:(NSInteger)index
{
    NSMutableArray *allRevisions = [[[NSMutableArray alloc] init] autorelease];
    
    NSArray *issues = self.application.issues;
    for (PCIssue *issue in issues)
    {
        [allRevisions addObjectsFromArray:issue.revisions];
    }
    
    if (index >= 0 && index < [allRevisions count])
    {
        PCRevision *revision = [allRevisions objectAtIndex:index];
        return revision;
    }
    
    return nil;
}

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
}

- (void)downloadRevisionFinishedWithIndex:(NSNumber*)index
{
    [self.kioskViewController downloadFinishedWithRevisionIndex:[index integerValue]];

    if (_previewMode) {
        [self readRevision:[self revisionWithIndex:[index integerValue]] preview:YES];
    }
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
}

- (void)downloadingRevisionProgressUpdate:(NSDictionary*)info
{
    NSNumber        *index = [info objectForKey:@"index"];
    NSNumber        *progress = [info objectForKey:@"progress"];
    
    [self.kioskViewController downloadingProgressChangedWithRevisionIndex:[index integerValue]
                                                               andProgess:[progress floatValue]];
}

#pragma mark - PCKioskDataSourceProtocol

- (NSInteger)numberOfRevisions
{
    NSInteger revisionsCount = 0;
    
    NSArray *issues = self.application.issues;
    for (PCIssue *issue in issues)
    {
        revisionsCount += [issue.revisions count];
    }
    
    return revisionsCount;
}

- (NSString *)issueTitleWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if (revision != nil && revision.issue != nil)
    {
        return revision.issue.title;
    }
    
    return @"";
}

- (NSString *)revisionTitleWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if (revision != nil)
    {
        return revision.title;
    }
    
    return @"";
}

- (NSString *)revisionStateWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if (revision)
    {
        NSString    *result = @"";
        
        switch (revision.state) {
            case PCRevisionStateArchived:
                result = NSLocalizedString(@"Archived", @"Revision state");
                break;
                
            case PCRevisionStateForReview:
                result = NSLocalizedString(@"For review", @"Revision state");
                break;
                
            case PCRevisionStatePublished:
                result = NSLocalizedString(@"Published", @"Revision state");
                break;
                
            case PCRevisionStateWorkInProgress:
                result = NSLocalizedString(@"Work in progress", @"Revision state");
                break;
                
            default:
                break;
        }
        
        return result;
    }
    
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

- (BOOL)previewAvailableForRevisionWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];

    return revision.issue.application.previewColumnsNumber != 0;
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

- (void)readRevision:(PCRevision *)revision preview:(BOOL)previewMode
{
    if (revision == nil || revision.pages.count == 0) {
        return;
    }
    
    [PCDownloadManager sharedManager].revision = revision;
    [[PCDownloadManager sharedManager] startDownloading];
    
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources" withExtension:@"bundle"]];
    PCRevisionViewController *revisionViewController = [[PCRevisionViewController alloc] 
                                                        initWithNibName:@"PCRevisionViewController"
                                                        bundle:bundle];
    //        PCRevisionViewController *revisionViewController = [[PCRevisionViewController alloc] init];
    revisionViewController.revision = revision;
    revisionViewController.previewMode = previewMode;
    revisionViewController.initialPageIndex = [Helper getInternalPageIndex];
    // TODO: for compatibility with PCRevisionViewController
    revisionViewController.mainViewController = self;
    revisionViewController.view.tag = 100;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.mainSplitViewController presentViewController:revisionViewController animated:NO completion:nil];
    [revisionViewController release];
}

#pragma mark - PCKioskViewControllerDelegateProtocol

- (void) readRevisionWithIndex:(NSInteger)index
{
    PCRevision *currentRevision = [self revisionWithIndex:index];
    [self readRevision:currentRevision preview:NO];
}

- (void) deleteRevisionDataWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];

    if (revision)
    {
        [revision deleteContent];
        [self.kioskViewController updateRevisionWithIndex:index];
    }
}

- (void) updateRevisionWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];

    if(revision)
    {
        [revision deleteContent];
        [self downloadRevisionWithIndex:index];
    }
}

- (void) previewRevisionWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if (revision != nil)
    {
        [self.kioskViewController downloadStartedWithRevisionIndex:index];
        _previewMode = YES;
        _currentRevisionIndex = index;
        [self performSelectorInBackground:@selector(doDownloadRevisionWithIndex:) withObject:[NSNumber numberWithInteger:index]];
    }

}

- (void) downloadRevisionWithIndex:(NSInteger)index
{
    PCRevision *revision = [self revisionWithIndex:index];
    
    if(revision)
    {
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
}

- (void) tapInKiosk
{
    // nothing
}

@end
