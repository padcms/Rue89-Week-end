//
//  PCKioskAdvancedControlElement.m
//  Pad CMS
//
//  Created by tar on 14.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

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
#import "PCIssue.h"

@interface PCKioskAdvancedControlElement() {
    NSString * testText;
    NSString * testHighlightedText; 
    UIFont * testFont;
    UIColor * testColor;
    UIColor * testHighlightingColor;
    CGFloat  shadowInitialHeight;
    
    CGRect detailsFrameShown;
    CGRect detailsFrameHidden;
    
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

const CGFloat kDetailsHeight = 80.0f;

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
    [self addSubview:button];
    return button;
}

-(void)initButtons
{
	downloadButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DOWNLOAD"
                                                                                  value:@"DOWNLOAD"]];
	
	readButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_READ"
                                                                              value:@"READ"]];
	
	cancelButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_CANCEL"
                                                                                value:@"CANCEL"]];
	
	deleteButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DELETE"
                                                                                value:@"DELETE"]];
	
	payButton = [self buttonWithTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_PAY"
                                                                             value:@"PAY"]];
    
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
    
    NSString * illustrationURLString = self.revision.issue.imageSmallURL; //[self.dataSource issueImageSmallURLWithIndex:self.revisionIndex];
    NSString * serverURLString = [PCConfig serverURLString];
    
    NSURL * illustrationURL = [ NSURL URLWithString:[NSString stringWithFormat:@"%@%@", serverURLString, illustrationURLString]];
    
    [self.illustrationImageView setImageWithURL:illustrationURL placeholderImage:placeholderImage];
    
    //self.imageViewShadowImage = [[UIImage imageNamed:@"home_issue_bg_shadow_6px"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
    
    //shadow
    CGFloat  shadowWidth = 6.0f;
    CGRect imageRect = self.illustrationImageView.frame;
    CGRect shadowRect = CGRectMake(imageRect.origin.x - shadowWidth, imageRect.origin.y - shadowWidth, imageRect.size.width + shadowWidth*2, imageRect.size.height + shadowWidth*2);
    self.shadowImageView = [[UIImageView alloc] initWithFrame:shadowRect];
    self.shadowImageView.image = [[UIImage imageNamed:@"home_issue_bg_shadow_6px"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
    [self addSubview:self.shadowImageView];
    
    shadowInitialHeight = self.shadowImageView.frame.size.height;
    
    //details shadow
    UIImage * detailsShadowImage = [UIImage imageNamed:@"home_issue_details_top_shadow_6px"];
    self.detailsShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageRect.origin.x, CGRectGetMaxY(imageRect), imageRect.size.width, shadowWidth)];
    self.detailsShadowImageView.image = detailsShadowImage;
    self.detailsShadowImageView.alpha = 0;
    [self addSubview:self.detailsShadowImageView];
    
    [self initDetailsView];

}

- (void)initDetailsView {
    CGRect imageRect = self.illustrationImageView.frame;
    detailsFrameHidden = CGRectMake(imageRect.origin.x, CGRectGetMaxY(imageRect) - kDetailsHeight, imageRect.size.width, kDetailsHeight);
    detailsFrameShown = detailsFrameHidden;
    detailsFrameShown.origin.y += kDetailsHeight;
    
    self.detailsView = [[PCKioskControlElementDetailsView alloc] initWithFrame:detailsFrameHidden];
    self.detailsView.hidden = YES;
    [self insertSubview:self.detailsView belowSubview:self.illustrationImageView];
    
    NSString * excerptString = self.revision.issue.excerpt;//[self.dataSource issueExcerptWithIndex:self.revisionIndex];
    NSString * authors = self.revision.issue.author;//[self.dataSource issueAuthorWithIndex:self.revisionIndex];
    NSInteger wordsCount = self.revision.issue.wordsCount;//[self.dataSource issueWordsCountWithIndex:self.revisionIndex];
    
    [self.detailsView setExcerptString:excerptString];
    [self.detailsView setAuthorsString:authors];
    [self.detailsView setNumberOfWords:wordsCount];
    
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
    NSString * text = @"hello Text! I am a big line\nof the text\ntest test test";
    self.titleLabel = [[PCKioskAdvancedControlElementTitleLabel alloc] initWithFrame:CGRectMake(0, 31, 600, 210)];
    
    [_titleLabel setFont:[UIFont fontWithName:PCFontInterstateBlack size:29.5f]];
    [_titleLabel setText:text];
    [_titleLabel setHighlightText:text];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_titleLabel setHighlightColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
    [self addSubview:_titleLabel];
    
    CGRect imageFrame = self.illustrationImageView.frame;
    CGFloat dateLabelPaddingLeft = 8.0f;
    self.dateLabel = [[PCKioskAdvancedControlElementDateLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageFrame) + dateLabelPaddingLeft, imageFrame.origin.y - 2, 100, 100)];
    [self addSubview:self.dateLabel];
    
    NSDate * date = self.revision.createDate;//[self.dataSource revisionDateWithIndex:self.revisionIndex];
    
    self.dateLabel.date = date;
    
    
    self.categoryLabel = [[MTLabel alloc] initWithFrame:CGRectMake(0, imageFrame.origin.y + 4, imageFrame.origin.x, 20)];
    [self.categoryLabel setText:@"Category"];
    [self.categoryLabel setTextAlignment:MTLabelTextAlignmentCenter];
    [self.categoryLabel setFont:[UIFont fontWithName:PCFontInterstateRegular size:13.5]];
    [self.categoryLabel setCharacterSpacing:-0.75f];
    [self.categoryLabel setBackgroundColor:[UIColor clearColor]];
    [self.categoryLabel setFontColor:UIColorFromRGB(0x91b4d7)];
    [self addSubview:self.categoryLabel];
    
    NSString * category = self.revision.issue.category;[self.dataSource issueCategoryWithIndex:self.revisionIndex];
    self.categoryLabel.text = category;
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
}

- (void) adjustElements
{
    
    [super adjustElements];
    if(self.revision.issue.paid/*[self.dataSource isRevisionPaidWithIndex:self.revisionIndex]*/)
    {
		
		payButton.hidden = YES;
    }
	else {
		downloadButton.hidden = YES;
		readButton.hidden = YES;
		cancelButton.hidden = YES;
		deleteButton.hidden = YES;
		NSString* price = self.revision.issue.price;// [self.dataSource priceWithIndex:self.revisionIndex];
		if (price ) {
			[payButton setTitle:price forState:UIControlStateNormal];
			payButton.hidden = NO;
		}
		else {
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(productDataRecieved:)
														 name:kInAppPurchaseManagerProductsFetchedNotification
													   object:nil];
			NSString* productIdentifier = self.revision.issue.productIdentifier;//[self.dataSource productIdentifierWithIndex:self.revisionIndex];
			[[InAppPurchases sharedInstance] requestProductDataWithProductId:productIdentifier];
		}
		
	}
    
    if (self.revision.isDownloaded) {
        deleteButton.hidden = YES;
        _archiveButton.hidden = NO;
    }
    
    if (self.revision.state == PCRevisionStateArchived) {
        if (self.revision.isDownloaded) {
            deleteButton.hidden = NO;
            _restoreButton.hidden = NO;
            _archiveButton.hidden = YES;
            readButton.hidden = YES;
        }
    } else {
        if (self.revision.isDownloaded) {
            deleteButton.hidden = YES;
            _archiveButton.hidden = NO;
            _restoreButton.hidden = YES;
        }

    }
	
}

- (void) update
{
    //if(revisionCoverView)
    //{
    
//    if (self.revisionIndex != 1) {
//        UIImage         *coverImage = [self.dataSource revisionCoverImageWithIndex:self.revisionIndex andDelegate:self];
//        self.illustrationImageView.image = coverImage;
//    }

//        
//        [self assignCoverImage:coverImage];
   //}
    self.titleLabel.text = self.revision.issue.title;//[self.dataSource issueTitleWithIndex:self.revisionIndex];
    //revisionTitleLabel.text = [self.dataSource revisionTitleWithIndex:self.revisionIndex];
    //revisionStateLabel.text = [self.dataSource revisionStateWithIndex:self.revisionIndex];
    [self adjustElements];
}

#pragma mark - Buttons actions

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
    [self.showDetailsButton setSelected:![self.showDetailsButton isSelected]];
    
    CGFloat height = KIOSK_ADVANCED_SHELF_ROW_HEIGHT;
    CGFloat shadowHeight = shadowInitialHeight;
    CGFloat shadowAlpha = 0;
    CGRect detailsFrame = detailsFrameHidden;
    BOOL descriptionHidden = YES;
    
    if (self.showDetailsButton.selected) {
        height += kDetailsHeight;
        shadowHeight += kDetailsHeight;
        shadowAlpha = 0.3f;
        detailsFrame = detailsFrameShown;
        descriptionHidden = NO;
    }

    [UIView animateWithDuration:0.3f animations:^{
        //setting frame of current cell and other cells
        if([self.heightDelegate respondsToSelector:@selector(setHeight:forCell:)]) {
            [self.heightDelegate setHeight:height forCell:self];
        }
        
        //setting shadow frame
        CGRect shadowFrame = self.shadowImageView.frame;
        shadowFrame.size.height = shadowHeight;
        self.shadowImageView.frame = shadowFrame;
        
        //setting details top shadow alpha
        self.detailsShadowImageView.alpha = shadowAlpha;
        
        //show textview'
        if (!descriptionHidden) {
            self.detailsView.hidden = NO;
        }
        
        
        //setting details frame
        self.detailsView.frame = detailsFrame;
    } completion:^(BOOL finished) {
        if (descriptionHidden) {
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
			payButton.hidden = NO;
		}
		
		return;
	}
}

//#pragma mark - Drawing
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
//}

@end
