//
//  PCKioskAdvancedControlElement.m
//  Pad CMS
//
//  Created by tar on 14.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskDataSourceProtocol.h"
#import "PCKioskSubviewDelegateProtocol.h"
#import "PCKioskAdvancedControlElement.h"
#import "PCKioskShelfSettings.h"
#import "InAppPurchases.h"
#import "PCLocalizationManager.h"
#import <CoreText/CoreText.h>
#import "PCKioskAdvancedControlElementTitleLabel.h"
#import "PCKioskControlElementDetailsView.h"
#import "PCFonts.h"
#import "MTLabel.h"
//#import "UIImageView+AFNetworking.h"
#ifdef RUE
#import <SDWebImage/UIImageView+WebCache.h>
#endif
#import "PCConfig.h"
#import "PCKioskAdvancedControlElementDateLabel.h"
#import "RueIssue.h"

#import "PCRevision+DataOfDownload.h"
#import "ProgressButton.h"
#import "ImagesBank.h"
#import "PCDownloadApiClient.h"
#import "RueSubscriptionManager.h"
#import "RueKioskShelfView.h"

typedef enum {
    ElementsStateNotDownloaded,
    ElementsStateInfoIsDownloading,
    ElementsStateInfoDownloaded,
    ElementsStateArchived,
    ElementsStatePay,
    ElementsStateContentDownloading,
    
    ElementsStateFree,
    ElementsStateSubscribe,
    ElementsStateSubscribePay
    
}ElementsState;

@interface PCKioskAdvancedControlElement()
{
    NSString * testText;
    NSString * testHighlightedText; 
    UIFont * testFont;
    UIColor * testColor;
    UIColor * testHighlightingColor;
    CGFloat  shadowInitialHeight;
    
//    CGRect detailsFrameShown;
//    CGRect detailsFrameHidden;
    
    BOOL _isContentDownloading;
    BOOL _isObservingReachability;
    
    UIButton* subscribeButton;
}

@property (nonatomic, strong) UIImageView * illustrationImageView;
@property (nonatomic, strong) UIImageView * shadowImageView;
@property (nonatomic, strong) UIImageView * detailsShadowImageView;
@property (nonatomic, strong) PCKioskAdvancedControlElementTitleLabel * titleLabel;
@property (nonatomic, strong) UIImage * imageViewShadowImage;
@property (nonatomic, strong) UIButton * showDetailsButton;
@property (nonatomic, strong) PCKioskControlElementDetailsView * detailsView;
@property (nonatomic, strong) PCKioskAdvancedControlElementDateLabel * dateLabel;
@property (nonatomic, strong) MTLabel * categoryLabel;

@end

//const CGFloat kDetailsHeight = 80.0f;

@implementation PCKioskAdvancedControlElement

- (void) initDownloadingProgressComponents
{
	[super initDownloadingProgressComponents];
    
    //TODO: Move these vars to the settings.
    CGFloat progressViewWidth = 135.0f;
    CGFloat progressViewY = 282.0f;
    
    downloadingProgressView.frame = CGRectMake((self.bounds.size.width - progressViewWidth), progressViewY, progressViewWidth, 7);
    downloadingProgressView.progressTintColor = [UIColor whiteColor];
    
    CGRect labelFrame = downloadingProgressView.frame;
    labelFrame.origin.y += 16;
    labelFrame.size.height = 16;
    downloadingInfoLabel.frame = labelFrame;
    
    downloadingInfoLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    
    downloadingProgressView.alpha = 0.0;
    
	//downloadingInfoLabel.frame = CGRectMake(downloadingProgressView.frame.origin.x,downloadingProgressView.frame.origin.y+downloadingProgressView.frame.size.height,downloadingProgressView.frame.size.width,30);
}

- (UIButton *)buttonWithTitle:(NSString *)title {
   
    CGFloat fontSize = 16.5;

	UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:[[UIImage imageNamed:@"home_issue_button_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[button setTitle:[title uppercaseString]
                    forState:UIControlStateNormal];
	[button titleLabel].font = [UIFont fontWithName:PCFontQuicksandBold size:fontSize];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
	[button titleLabel].backgroundColor = [UIColor clearColor];
	[button titleLabel].textAlignment = UITextAlignmentCenter;
	[button titleLabel].textColor = [UIColor whiteColor];
	[button sizeToFit];
	button.hidden = YES;
    
    UIEdgeInsets titleInset = {4, 0, 0, 0};
    button.titleEdgeInsets = titleInset;
    
    [self addSubview:button];
    return button;
}

-(void)initButtons
{
//    É
//    LATIN CAPITAL LETTER E WITH ACUTE
//Unicode: U+00C9, UTF-8: C3 89
    NSString * downloadButtonTitle = @"TÉLÉCHARGER";//[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DOWNLOAD" value:@"DOWNLOAD"];
    
    downloadButton = [ProgressButton progressButtonWithTitle:downloadButtonTitle];
    [self addSubview:downloadButton];
	
	readButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_READ"
                                                                              value:@"READ"]];
	
//	cancelButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_CANCEL" value:@"CANCEL"]];
    cancelButton = [ProgressButton progressButtonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_CANCEL" value:@"CANCEL"]];
    [self addSubview:cancelButton];
    [(ProgressButton*)cancelButton showProgress];
	
	deleteButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DELETE"
                                                                                value:@"DELETE"]];
	
	payButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_PAY"
                                                                             value:@"BUY"]];
    
    _archiveButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_ARCHIVE"
                                                                                   value:@"ARCHIVE"]];
    
    _restoreButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_RESTORE"
                                                                                  value:@"RESTORE"]];
    
    UIImage * showDetailsButtonNormalBackgroundImage = [UIImage imageNamed:@"home_issue_details_button_bg_normal"];
    self.showDetailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.showDetailsButton setBackgroundImage:showDetailsButtonNormalBackgroundImage forState:UIControlStateNormal];
    //[self.showDetailsButton setBackgroundImage:[UIImage imageNamed:@"home_issue_details_button_bg_selected"] forState:UIControlStateHighlighted];
     //[self.showDetailsButton setBackgroundImage:[UIImage imageNamed:@"home_issue_details_button_bg_selected"] forState:UIControlStateSelected];
    [self.showDetailsButton setImage:[UIImage imageNamed:@"home_issue_details_button_plus"] forState:UIControlStateNormal];
    [self.showDetailsButton setImage:[UIImage imageNamed:@"home_issue_details_button_minus"] forState:UIControlStateSelected];
    [self.showDetailsButton setFrame:CGRectMake(105, 243, showDetailsButtonNormalBackgroundImage.size.width, showDetailsButtonNormalBackgroundImage.size.height)];
    [self.showDetailsButton setAdjustsImageWhenHighlighted:NO];
    [self addSubview:self.showDetailsButton];
    
    //TODO: move this to settings like it was done before
    CGFloat buttonWidth = 140.0f;
    CGFloat buttonHeight = 37.0f;
    CGFloat buttonX = self.bounds.size.width - buttonWidth;
    
    CGFloat buttonY1 = self.bounds.size.height - buttonHeight - 30.0f;
    CGFloat buttonY2 = buttonY1 - buttonHeight - 10.0f;
    
    CGRect topButtonRect = CGRectMake(buttonX, buttonY2, buttonWidth, buttonHeight);
    CGRect bottomButtonRect = CGRectMake(buttonX, buttonY1, buttonWidth, buttonHeight);
    
	downloadButton.frame = bottomButtonRect;
	cancelButton.frame = bottomButtonRect;
	readButton.frame = topButtonRect;
	deleteButton.frame = bottomButtonRect;
	payButton.frame = bottomButtonRect;
    _archiveButton.frame = bottomButtonRect;
    _restoreButton.frame = topButtonRect;
    
    subscribeButton = [self buttonWithTitle:@"S'ABONNER"];
    subscribeButton.hidden = YES;
    subscribeButton.frame = bottomButtonRect;
}

- (void)initCover {
    
    //illustration
    UIImage * placeholderImage = [UIImage imageNamed:@"home_illustration_placeholder"];
    self.illustrationImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - placeholderImage.size.width) /2, (self.bounds.size.height - placeholderImage.size.height) /2, placeholderImage.size.width, placeholderImage.size.height)];
    self.illustrationImageView.image = placeholderImage;
    self.illustrationImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.illustrationImageView.clipsToBounds = YES;
    self.illustrationImageView.backgroundColor = UIColorFromRGB(0xf6f8fa);
    [self addSubview:self.illustrationImageView];
    
    //self.imageViewShadowImage = [[UIImage imageNamed:@"home_issue_bg_shadow_6px"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
    
    //shadow
    CGFloat  shadowWidth = 6.0f;
    CGRect imageRect = self.illustrationImageView.frame;
    CGRect shadowRect = CGRectMake(imageRect.origin.x - shadowWidth, imageRect.origin.y - shadowWidth, imageRect.size.width + shadowWidth*2, imageRect.size.height + shadowWidth*2);
    self.shadowImageView = [[UIImageView alloc] initWithFrame:shadowRect];
    self.shadowImageView.image = [[UIImage imageNamed:@"home_issue_bg_shadow_6px"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
    [self addSubview:self.shadowImageView];
    
    shadowInitialHeight = self.shadowImageView.frame.size.height;
    
    [self initDetailsView];

}

- (void)initDetailsView
{
    //details shadow
    CGRect imageRect = self.illustrationImageView.frame;
    CGFloat  shadowWidth = 6.0f;
    UIImage * detailsShadowImage = [UIImage imageNamed:@"home_issue_details_top_shadow_6px"];
    self.detailsShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageRect.origin.x, CGRectGetMaxY(imageRect), imageRect.size.width, shadowWidth)];
    self.detailsShadowImageView.image = detailsShadowImage;
    self.detailsShadowImageView.alpha = 0;
    [self addSubview:self.detailsShadowImageView];
    
    self.detailsView = [[PCKioskControlElementDetailsView alloc] initWithFrame:CGRectMake(imageRect.origin.x, CGRectGetMaxY(imageRect), imageRect.size.width, 0)];
    self.detailsView.hidden = YES;
    [self addSubview:self.detailsView];
}

- (void)initLabels {
    
//    NSArray *fontFamilies = [UIFont familyNames];
//
//    for (int i = 0; i < [fontFamilies count]; i++)
//    {
//        NSString *fontFamily = [fontFamilies objectAtIndex:i];
//        NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
//        NSLog (@"%@: %@", fontFamily, fontNames);
//    }
    
    //[super initLabels];

    self.titleLabel = [[PCKioskAdvancedControlElementTitleLabel alloc] initWithFrame:CGRectMake(0, 31, 600, 210)];
    
    [_titleLabel setFont:[UIFont fontWithName:PCFontInterstateBlack size:29.5f]];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_titleLabel setHighlightColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
    [self addSubview:_titleLabel];
    
    CGRect imageFrame = self.illustrationImageView.frame;
    CGFloat dateLabelPaddingLeft = 8.0f;
    self.dateLabel = [[PCKioskAdvancedControlElementDateLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageFrame) + dateLabelPaddingLeft, imageFrame.origin.y - 2, 100, 65)];
    [self addSubview:self.dateLabel];
    
    
    self.categoryLabel = [[MTLabel alloc] initWithFrame:CGRectMake(0, imageFrame.origin.y + 4, imageFrame.origin.x, 20)];
    [self.categoryLabel setText:@"Category"];
    [self.categoryLabel setTextAlignment:MTLabelTextAlignmentCenter];
    [self.categoryLabel setFont:[UIFont fontWithName:PCFontInterstateRegular size:13.5]];
    [self.categoryLabel setCharacterSpacing:-0.75f];
    [self.categoryLabel setBackgroundColor:[UIColor clearColor]];
    [self.categoryLabel setFontColor:UIColorFromRGB(0x91b4d7)];
    [self addSubview:self.categoryLabel];
    
    //[self.dateLabel setBackgroundColor:[UIColor redColor]];
}

- (void) assignButtonsHandlers
{
    [super assignButtonsHandlers];
    
    [payButton addTarget:self
                  action:@selector(payButtonTapped)
        forControlEvents:UIControlEventTouchUpInside];
    
    [self.showDetailsButton addTarget:self
                               action:@selector(showDetailsButtonTapped)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.archiveButton addTarget:self
                           action:@selector(archiveButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.restoreButton addTarget:self
                           action:@selector(restoreButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [subscribeButton addTarget:self action:@selector(subscribeButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) adjustElements
{
//    BOOL previewAvailable = NO;
//    if ([self.dataSource respondsToSelector:@selector(previewAvailableForRevisionWithIndex:)]) {
//        previewAvailable = [self.dataSource previewAvailableForRevisionWithIndex:self.revisionIndex];
//    }
    
    if (self.revision.isDownloaded)
    {
        if (self.revision.state == PCRevisionStateArchived)
        {
            [self setElementsState:ElementsStateArchived];
        }
        else if(self.revision.isContentDownloading)
        {
            self.downloadInProgress = YES;
            [self setElementsState:ElementsStateContentDownloading];
        }
        else
        {
            [self setElementsState:ElementsStateInfoDownloaded];
        }
    }
    else
    {
        if (self.downloadInProgress)
        {
            [self setElementsState:ElementsStateInfoIsDownloading];
        }
        else
        {
//            [self setElementsState:ElementsStateNotDownloaded];
            //----- case that revision dont starts downloading ----------------------
            switch ([(RueIssue*)self.revision.issue pricingPlan])
            {
                case IssuePricingPlanFree:
                    [self setElementsState:ElementsStateFree];
                    break;
                    
                case IssuePricingPlanSubscriptionOnly:
                    if([[RueSubscriptionManager sharedManager] isSubscribed])
                    {
                        [self setElementsState:ElementsStateNotDownloaded];
                    }
                    else
                    {
                        [self setElementsState:ElementsStateSubscribe];
                    }
                    break;
                    
                case IssuePricingPlanSinglePurchase:
                    if([[RueSubscriptionManager sharedManager]isRevisionPaid:self.revision])
                    {
                        [self setElementsState:ElementsStateNotDownloaded];
                    }
                    else
                    {
                        [self setElementsState:ElementsStatePay];
                    }
                    break;
                    
                case IssuePricingPlanSubscriptionOrSinglePurchase:
                    if([[RueSubscriptionManager sharedManager] isSubscribed] || [[RueSubscriptionManager sharedManager]isRevisionPaid:self.revision])
                    {
                        [self setElementsState:ElementsStateNotDownloaded];
                    }
                    else
                    {
                        [self setElementsState:ElementsStatePay];
                        //[self setElementsState:ElementsStateSubscribePay];
                    }
                    break;
            }
            //-----------------------------------------------------------------------
        }
    }
    self.downloadInProgress = NO;
}

- (void) subscribeButtonTaped:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(subscribeButtonTaped:fromRevision:)])
    {
        [(RueKioskShelfView*)self.delegate subscribeButtonTaped:sender fromRevision:self.revision];
    }
}

- (void) setElementsState:(ElementsState)state
{
    downloadButton.hidden = cancelButton.hidden = readButton.hidden = downloadingInfoLabel.hidden = downloadingProgressView.hidden = deleteButton.hidden = previewButton.hidden = _archiveButton.hidden = payButton.hidden = _restoreButton.hidden = YES;
    downloadButton.enabled = YES;
    downloadButton.userInteractionEnabled = YES;
    [(ProgressButton*)downloadButton hidePatience];
    [(ProgressButton*)downloadButton hideProgress];
    [self stopObserveReachability];
    
    [downloadButton setTitle:@"TÉLÉCHARGER" forState:UIControlStateNormal];//[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DOWNLOAD" value:@"Download"] forState:UIControlStateNormal];
    subscribeButton.hidden = YES;
    subscribeButton.frame = downloadButton.frame;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerProductsFetchedNotification object:nil];
    
    switch (state)
    {
        case ElementsStateNotDownloaded:
            
            downloadButton.hidden = NO;
            
            break;
            
        case ElementsStateInfoIsDownloading:

            [self startObserveReachability];
            
            downloadingInfoLabel.hidden = NO;
            downloadingProgressView.hidden = NO;
            [(ProgressButton*)downloadButton showProgress];
            [(ProgressButton*)downloadButton showPatience];
            downloadButton.userInteractionEnabled = NO;
            downloadButton.hidden = NO;
            break;
            
        case ElementsStateInfoDownloaded:
            
            readButton.hidden = NO;
            _archiveButton.hidden = NO;
            
            break;
            
        case ElementsStatePay:
        {
            NSString* price = self.revision.issue.price;
            if (price )
            {
                [payButton setTitle:price forState:UIControlStateNormal];
                payButton.hidden = NO;
            }
            else
            {
                payButton.hidden = NO;
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(productDataRecieved:)
                                                             name:kInAppPurchaseManagerProductsFetchedNotification
                                                           object:nil];
                NSString* productIdentifier = self.revision.issue.productIdentifier;//[self.dataSource productIdentifierWithIndex:self.revisionIndex];
                [[InAppPurchases sharedInstance] requestProductDataWithProductId:productIdentifier];
            }
            
            [self setupAvailabilityOfSubscribeAndPayButtons];
        }
        break;
            
        case ElementsStateFree:
            
            downloadButton.hidden = NO;
            [downloadButton setTitle:@"GRATUIT" forState:UIControlStateNormal];
            
            break;
            
        case ElementsStateSubscribe:
        {
            [self setupAvailabilityOfSubscribeAndPayButtons];
            subscribeButton.hidden = NO;
        }
            break;
            
        case ElementsStateSubscribePay:
        {
            [self setupAvailabilityOfSubscribeAndPayButtons];
            
            subscribeButton.hidden = NO;
            subscribeButton.frame = readButton.frame;
            payButton.hidden = NO;
        }
            break;
            
        case ElementsStateArchived:
            
            deleteButton.hidden = NO;
            _restoreButton.hidden = NO;
            
            break;
            
        case ElementsStateContentDownloading:
            
            downloadingInfoLabel.hidden = NO;
            downloadingProgressView.hidden = NO;
            downloadButton.hidden = NO;
            [(ProgressButton*)downloadButton showProgress];
            [(ProgressButton*)downloadButton showPatience];
            downloadButton.userInteractionEnabled = NO;
            
            break;
    }
}

- (void) setupAvailabilityOfSubscribeAndPayButtons
{
    RueSubscriptionManager* subscrManager = [RueSubscriptionManager sharedManager];
    if([subscrManager isRestoringPurchases] || [subscrManager isSubscribing])
    {
        subscribeButton.alpha = 0.5;
        subscribeButton.userInteractionEnabled = NO;
        payButton.alpha = 0.5;
        payButton.userInteractionEnabled = NO;
    }
    else
    {
        if([subscrManager isPurchasingRevision])
        {
            payButton.alpha = 0.5;
            payButton.userInteractionEnabled = NO;
        }
        else
        {
            payButton.alpha = 1;
            payButton.userInteractionEnabled = YES;
        }
        subscribeButton.alpha = 1;
        subscribeButton.userInteractionEnabled = YES;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"networkReachabilityStatus"])
    {
        NSLog(@"reachability : %@", change.debugDescription);
        if(change[@"new"] == 0)
        {
            [self stopObserveReachability];
            [self cancelButtonTapped];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"MSG_NO_NETWORK_CONNECTION"
                                                                                                           value:@"You must be connected to the Internet."]
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                                           value:@"OK"]
                                                  otherButtonTitles:nil];
			[alert show];
        }
    }
}

- (void) startObserveReachability
{
    if(_isObservingReachability == NO)
    {
        [[PCDownloadApiClient sharedClient] addObserver:self forKeyPath:@"networkReachabilityStatus" options:NSKeyValueObservingOptionNew context:nil];
        _isObservingReachability = YES;
    }
}

- (void) stopObserveReachability
{
    if(_isObservingReachability)
    {
        [[PCDownloadApiClient sharedClient] removeObserver:self forKeyPath:@"networkReachabilityStatus"];
        _isObservingReachability = NO;
    }
}

- (void) downloadProgressUpdatedWithProgress:(float)progress andRemainingTime:(NSString *)time
{
    static const float contentProgressPart = 0.9;
    
    self.downloadInProgress = YES; //not sure if it will not bring any bugs
    downloadingProgressView.progress = progress;
    
    if(self.revision.isDownloaded)
    {
        progress = progress * contentProgressPart + (1 - contentProgressPart);
    }
    else
    {
        progress = progress * (1.0 - contentProgressPart);
    }
    [(ProgressButton*)downloadButton setProgress:progress];
    //[(ProgressButton*)cancelButton setProgress:progress];
    
    if(time)
    {
        downloadingInfoLabel.text = [NSString stringWithFormat:@"%3.0f %% %@",progress*100, time];
    } else {
        downloadingInfoLabel.text = [NSString stringWithFormat:@"%3.0f %%", progress*100];
    }
}

- (void) update
{
    self.downloadInProgress = NO;
   //NSDate *methodStart = [NSDate date];
    //title
    self.titleLabel.text = self.revision.issue.title;
    
    //details
    
    [self.detailsView setupForRevision:self.revision];
    
    //date
    NSDate * dateOfRevisionCreate = self.revision.createDate;
    NSDate* dateOfIssuePublication = ((RueIssue*)self.revision.issue).publishDate;
    
    self.dateLabel.date = dateOfIssuePublication ? dateOfIssuePublication : dateOfRevisionCreate;
    self.dateLabel.hidden = NO;
    
    //category
    NSString * category = ((RueIssue*)self.revision.issue).category;
    [self.dataSource issueCategoryWithIndex:self.revisionIndex];
    self.categoryLabel.text = category;
    
    //illustration
    UIImage * placeholderImage = [UIImage imageNamed:@"home_illustration_placeholder"];
    NSString * illustrationURLString = ((RueIssue*)self.revision.issue).imageSmallURL;
    NSString * serverURLString = [PCConfig serverURLString];
    NSString * illustrationPath = [NSString stringWithFormat:@"%@%@", serverURLString, illustrationURLString];
//    NSURL * illustrationURL = [ NSURL URLWithString:illustrationPath];
    
    self.illustrationImageView.image = placeholderImage;
    
    PCRevision* updatedRevision = self.revision;
    
    [[ImagesBank sharedBank] getImageWithName:[NSString stringWithFormat:@"%i", self.revision.issue.identifier] path:illustrationPath toBlock:^(UIImage *image, NSError *error) {
        
        if(image && updatedRevision == [self revision])
        {
            self.illustrationImageView.image = image;
        }
    }];
    
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //[self.illustrationImageView setImage:placeholderImage];
//        [self.illustrationImageView setImageWithURL:illustrationURL placeholderImage:placeholderImage];
    //});
    
    
    [self adjustElements];
    
    //NSDate *methodFinish = [NSDate date];
    //NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    
    //if (executionTime > 0.05) {
         //NSLog(@"UPDATE executionTime = %f", executionTime);
    //}
}

NSDate* onlyDayDateFromDate (NSDate* date)
{
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    
    [dateFormatter setDateFormat:@"dd"];
    NSString * dayString = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * yearString = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"MM"];
    NSString * monthString = [dateFormatter stringFromDate:date];
    
    NSString* fullDate = [NSString stringWithFormat:@"%@-%@-%@", yearString, monthString, dayString];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate* newDate = [dateFormatter dateFromString:fullDate];
    
    return newDate;
}

- (BOOL) isTheSameDateWithCell:(PCKioskAdvancedControlElement*)prevCell
{
    NSDate* prevDate = prevCell.dateLabel.date;
    NSDate* newDate = self.dateLabel.date;
    
    return ([newDate compare:prevDate] == NSOrderedSame);
}

- (void) hideDateLabel
{
    self.dateLabel.hidden = YES;
}

#pragma mark - Buttons actions

- (void) cancelButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(cancelButtonTappedWithRevisionIndex:)]) {
        [self.delegate cancelButtonTappedWithRevisionIndex:self.revisionIndex];
    }
}

- (void) downloadButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(downloadButtonTappedWithRevisionIndex:)])
    {
        [self.delegate downloadButtonTappedWithRevisionIndex:self.revisionIndex];
    }
}

- (void) payButtonTapped
{
    [self.delegate purchaseButtonTappedWithRevisionIndex:self.revisionIndex];
}

- (void)archiveButtonTapped {
//    self.revision.state = PCRevisionStateArchived;
//    [self adjustElements];
    
    [self.delegate archiveButtonTappedWithRevisionIndex:self.revisionIndex];
}

- (void)restoreButtonTapped {
    [self.delegate restoreButtonTappedWithRevisionIndex:self.revisionIndex];
}

- (void)showDetailsButtonTapped {
    [self showDescription:!self.showDetailsButton.isSelected animated:YES];
}

- (void)showDescription:(BOOL)show animated:(BOOL)animated {
    [self showDescription:show animated:animated notifyDelegate:YES];
}

- (void)showDescription:(BOOL)show animated:(BOOL)animated notifyDelegate:(BOOL)notify {
    
    [self.showDetailsButton setSelected:show];
    
    CGFloat height = KIOSK_ADVANCED_SHELF_ROW_HEIGHT;
    CGFloat shadowHeight = shadowInitialHeight;
    CGFloat shadowAlpha = 0;
    CGRect detailsFrame = self.detailsView.frame;
    detailsFrame.size.height = 0;
    
    if (show)
    {
        detailsFrame.size.height = self.detailsView.openedHeight;
        height += detailsFrame.size.height;
        shadowHeight += detailsFrame.size.height;
        shadowAlpha = 0.3f;
    }
    
    float animationDuration = animated ? 0.3f : 0.0f;
    
    [UIView animateWithDuration:animationDuration animations:^{
        //setting frame of current cell and other cells
        
        if (notify) {
            if([self.heightDelegate respondsToSelector:@selector(setHeight:forCell:)]) {
                [self.heightDelegate setHeight:height forCell:self];
            }
        }

        
        //setting shadow frame
        CGRect shadowFrame = self.shadowImageView.frame;
        shadowFrame.size.height = shadowHeight;
        self.shadowImageView.frame = shadowFrame;
        
        //setting details top shadow alpha
        self.detailsShadowImageView.alpha = shadowAlpha;
        
        //show textview'
        if (show) {
            self.detailsView.hidden = NO;
        }
        
        
        //setting details frame
        self.detailsView.frame = detailsFrame;
    } completion:^(BOOL finished) {
        if (!show) {
            self.detailsView.hidden = YES;
        }
    }];

}

- (void) productDataRecieved:(NSNotification *) notification
{
	if([[(NSDictionary *)[notification object] objectForKey:@"productIdentifier"] isEqualToString:self.revision.issue.productIdentifier]/*[self.dataSource productIdentifierWithIndex:self.revisionIndex]]*/)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerProductsFetchedNotification object:nil];
		
        if(![self.dataSource isRevisionPaidWithIndex:self.revisionIndex])
		{
			[payButton setTitle:[NSString stringWithString:[(NSDictionary *)[notification object] objectForKey:@"localizedPrice"]] forState:UIControlStateNormal];
			//payButton.hidden = NO;
		}
		return;
	}
}

/*//#pragma mark - Drawing
//
//- (void)drawRect:(CGRect)rect {
//    
//    CGRect imageRect = self.illustrationImageView.frame;
//    
//    NSLog(@"Image rect: %@", NSStringFromCGRect(imageRect));
//    
//    CGFloat  shadowWidth = 6.0f;
//    CGRect shadowRect = CGRectMake(imageRect.origin.x - shadowWidth, imageRect.origin.y - shadowWidth, imageRect.size.width + shadowWidth*2, imageRect.size.height + shadowWidth*2);
//    [self.imageViewShadowImage drawInRect:shadowRect];
//}*/

- (void) downloadContentStarted
{
    self.downloadInProgress = YES;
    _isContentDownloading = YES;
    [self adjustElements];
}

- (void) downloadContentFinished
{
    _isContentDownloading = NO;
    self.downloadInProgress = FALSE;
    [self adjustElements];
}

@end
