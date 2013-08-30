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
#import "UIImageView+AFNetworking.h"
#import "PCConfig.h"
#import "PCKioskAdvancedControlElementDateLabel.h"

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

@property (nonatomic, retain) UIImageView * illustrationImageView;
@property (nonatomic, retain) UIImageView * shadowImageView;
@property (nonatomic, retain) UIImageView * detailsShadowImageView;
@property (nonatomic, retain) PCKioskAdvancedControlElementTitleLabel * titleLabel;
@property (nonatomic, retain) UIImage * imageViewShadowImage;
@property (nonatomic, retain) UIButton * showDetailsButton;
@property (nonatomic, retain) PCKioskControlElementDetailsView * detailsView;
@property (nonatomic, retain) PCKioskAdvancedControlElementDateLabel * dateLabel;
@property (nonatomic, retain) MTLabel * categoryLabel;

@end

const CGFloat kDetailsHeight = 80.0f;

@implementation PCKioskAdvancedControlElement

-(void)dealloc
{
    [_imageViewShadowImage release];
    [_showDetailsButton release];
    [_titleLabel release];
    [_illustrationImageView release];
	[payButton release];
	[super dealloc];
}

- (void) initDownloadingProgressComponents
{
	[super initDownloadingProgressComponents];
    
    //TODO: Move these vars to the settings.
    CGFloat progressViewWidth = 200.0f;
    CGFloat progressViewY = 200.0f;
    
    downloadingProgressView.frame = CGRectMake((self.bounds.size.width - progressViewWidth) /2, progressViewY, progressViewWidth, 7);
    
    CGRect labelFrame = downloadingProgressView.frame;
    labelFrame.origin.y += 16;
    labelFrame.size.height = 16;
    downloadingInfoLabel.frame = labelFrame;
    
    downloadingInfoLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    
	//downloadingInfoLabel.frame = CGRectMake(downloadingProgressView.frame.origin.x,downloadingProgressView.frame.origin.y+downloadingProgressView.frame.size.height,downloadingProgressView.frame.size.width,30);
}

-(void)initButtons
{
    
    CGFloat fontSize = 16.5;
    // [super initButtons];
	downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[downloadButton setBackgroundImage:[[UIImage imageNamed:@"home_issue_button_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[downloadButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DOWNLOAD"
                                                                    value:@"DOWNLOAD"]
                    forState:UIControlStateNormal];
	[downloadButton titleLabel].font = [UIFont fontWithName:PCFontQuicksandBold size:fontSize];
    [downloadButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
	[downloadButton titleLabel].backgroundColor = [UIColor clearColor];
	[downloadButton titleLabel].textAlignment = UITextAlignmentCenter;
	[downloadButton titleLabel].textColor = [UIColor whiteColor];
	[downloadButton sizeToFit];
	downloadButton.hidden = YES;
	[self addSubview:downloadButton];
	
	readButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[readButton setBackgroundImage:[[UIImage imageNamed:@"home_issue_button_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[readButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_READ"
                                                                value:@"READ"]
                forState:UIControlStateNormal];
	[readButton titleLabel].font = [UIFont fontWithName:PCFontQuicksandBold size:fontSize];
    [readButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
	[readButton titleLabel].backgroundColor = [UIColor clearColor];
	[readButton titleLabel].textAlignment = UITextAlignmentCenter;
	[readButton titleLabel].textColor = [UIColor whiteColor];
	[readButton sizeToFit];
	readButton.hidden = YES;
	[self addSubview:readButton];
	
	cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[cancelButton setBackgroundImage:[[UIImage imageNamed:@"home_issue_button_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[cancelButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_CANCEL"
                                                                  value:@"CANCEL"]
                  forState:UIControlStateNormal];
	[cancelButton titleLabel].font = [UIFont fontWithName:PCFontQuicksandBold size:fontSize];
    [cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
	[cancelButton titleLabel].backgroundColor = [UIColor clearColor];
	[cancelButton titleLabel].textAlignment = UITextAlignmentCenter;
	[cancelButton titleLabel].textColor = [UIColor whiteColor];
	[cancelButton sizeToFit];
	cancelButton.hidden = YES;
	[self addSubview:cancelButton];
	
	deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[deleteButton setBackgroundImage:[[UIImage imageNamed:@"home_issue_button_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[deleteButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DELETE"
                                                                  value:@"DELETE"]
                  forState:UIControlStateNormal];
    //[deleteButton setTitle:[[NSAttributedString alloc] initWithString:[deleteButton titleForState:UIControlStateNormal]]  forState:UIControlStateNormal];
    //[deleteButton setAttributedTitle:[[NSAttributedString alloc] initWithString:[deleteButton titleForState:UIControlStateNormal]] forState:UIControlStateNormal];
	[deleteButton titleLabel].font = [UIFont fontWithName:PCFontQuicksandBold size:fontSize];
    [deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
	[deleteButton titleLabel].backgroundColor = [UIColor clearColor];
	[deleteButton titleLabel].textAlignment = UITextAlignmentCenter;
	[deleteButton titleLabel].textColor = [UIColor whiteColor];
	[deleteButton sizeToFit];
	deleteButton.hidden = YES;
	[self addSubview:deleteButton];
	
	payButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[payButton setBackgroundImage:[[UIImage imageNamed:@"home_issue_button_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[payButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_PAY"
                                                               value:@"PAY"]
               forState:UIControlStateNormal];
	[payButton titleLabel].font = [UIFont fontWithName:PCFontQuicksandBold size:fontSize];
    [payButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
	[payButton titleLabel].backgroundColor = [UIColor clearColor];
	[payButton titleLabel].textAlignment = UITextAlignmentCenter;
	[payButton titleLabel].textColor = [UIColor whiteColor];
	[payButton sizeToFit];
	deleteButton.hidden = YES;
	[self addSubview:payButton];
    
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
    
	downloadButton.frame = CGRectMake(buttonX, buttonY1, buttonWidth, buttonHeight);
	cancelButton.frame = downloadButton.frame;
	readButton.frame = CGRectMake(buttonX, buttonY1, buttonWidth, buttonHeight);
	deleteButton.frame = CGRectMake(buttonX, buttonY2, buttonWidth, buttonHeight);
	payButton.frame = CGRectMake(buttonX, buttonY1, buttonWidth, buttonHeight);
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
    
    NSString * illustrationURLString = [self.dataSource issueImageSmallURLWithIndex:self.revisionIndex];
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
    [self insertSubview:self.detailsView belowSubview:self.illustrationImageView];
    
    NSString * excerptString = [self.dataSource issueExcerptWithIndex:self.revisionIndex];
    NSString * authors = [self.dataSource issueAuthorWithIndex:self.revisionIndex];
    NSInteger wordsCount = [self.dataSource issueWordsCountWithIndex:self.revisionIndex];
    
    [self.detailsView setExcerptString:excerptString];
    [self.detailsView setAuthorsString:authors];
    [self.detailsView setNumberOfWords:wordsCount];
    
    //self.detailsView.descriptionTextView.text = self.dataSource
    
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
    self.titleLabel = [[PCKioskAdvancedControlElementTitleLabel alloc] initWithFrame:CGRectMake(0, 31, 400, 200)];
    [_titleLabel setFont:[UIFont fontWithName:PCFontInterstateBlack size:29.5f]];
    [_titleLabel setText:text];
    [_titleLabel setHighlightText:text];
    //[_titleLabel sizeToFit];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    
    //[_titleLabel setNeedsDisplay];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_titleLabel setHighlightColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
    [self addSubview:_titleLabel];
    
    CGRect imageFrame = self.illustrationImageView.frame;
    CGFloat dateLabelPaddingLeft = 8.0f;
    self.dateLabel = [[PCKioskAdvancedControlElementDateLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageFrame) + dateLabelPaddingLeft, imageFrame.origin.y - 2, 100, 100)];
    [self addSubview:self.dateLabel];
    
    NSDate * date = [self.dataSource revisionDateWithIndex:self.revisionIndex];
    
    self.dateLabel.date = date;
    
    
    self.categoryLabel = [[MTLabel alloc] initWithFrame:CGRectMake(0, imageFrame.origin.y + 4, imageFrame.origin.x, 20)];
    [self.categoryLabel setText:@"Category"];
    [self.categoryLabel setTextAlignment:MTLabelTextAlignmentCenter];
    [self.categoryLabel setFont:[UIFont fontWithName:PCFontInterstateRegular size:13.5]];
    [self.categoryLabel setCharacterSpacing:-0.75f];
    [self.categoryLabel setBackgroundColor:[UIColor clearColor]];
    [self.categoryLabel setFontColor:UIColorFromRGB(0x91b4d7)];
    [self addSubview:self.categoryLabel];
    
    NSString * category = [self.dataSource issueCategoryWithIndex:self.revisionIndex];
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
}

- (void) adjustElements
{
    
    [super adjustElements];
    if([self.dataSource isRevisionPaidWithIndex:self.revisionIndex])
    {
		
		payButton.hidden = YES;
    }
	else {
		downloadButton.hidden = YES;
		readButton.hidden = YES;
		cancelButton.hidden = YES;
		deleteButton.hidden = YES;
		NSString* price = [self.dataSource priceWithIndex:self.revisionIndex];
		if (price ) {
			[payButton setTitle:price forState:UIControlStateNormal];
			payButton.hidden = NO;
		}
		else {
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(productDataRecieved:)
														 name:kInAppPurchaseManagerProductsFetchedNotification
													   object:nil];
			NSString* productIdentifier = [self.dataSource productIdentifierWithIndex:self.revisionIndex];
			[[InAppPurchases sharedInstance] requestProductDataWithProductId:productIdentifier];
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
    self.titleLabel.text = [self.dataSource issueTitleWithIndex:self.revisionIndex];
    //revisionTitleLabel.text = [self.dataSource revisionTitleWithIndex:self.revisionIndex];
    //revisionStateLabel.text = [self.dataSource revisionStateWithIndex:self.revisionIndex];
    [self adjustElements];
}

#pragma mark - Buttons actions

- (void) payButtonTapped
{
    [self.delegate purchaseButtonTappedWithRevisionIndex:self.revisionIndex];
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
//        if (!descriptionHidden) {
//            self.detailsView.descriptionTextView.hidden = NO;
//        }
        
        
        //setting details frame
        self.detailsView.frame = detailsFrame;
    } completion:^(BOOL finished) {
//        if (descriptionHidden) {
//            self.detailsView.descriptionTextView.hidden = YES;
//        }
    }];
}

- (void) productDataRecieved:(NSNotification *) notification
{
	if([[(NSDictionary *)[notification object] objectForKey:@"productIdentifier"] isEqualToString:[self.dataSource productIdentifierWithIndex:self.revisionIndex]])
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
