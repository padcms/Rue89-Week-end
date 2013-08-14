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

@interface PCKioskAdvancedControlElement() {
    NSString * testText;
    NSString * testHighlightedText; 
    UIFont * testFont;
    UIColor * testColor;
    UIColor * testHighlightingColor;
    
    
}

@property (nonatomic, retain) UIImageView * illustrationImageView;
@property (nonatomic, retain) PCKioskAdvancedControlElementTitleLabel * titleLabel;
@property (nonatomic, retain) UIImage * imageViewShadowImage;

@end

@implementation PCKioskAdvancedControlElement

-(void)dealloc
{
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
    // [super initButtons];
	downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[downloadButton setBackgroundImage:[[UIImage imageNamed:@"home_issue_button_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[downloadButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DOWNLOAD"
                                                                    value:@"Donwload"]
                    forState:UIControlStateNormal];
	[downloadButton titleLabel].font = [UIFont fontWithName:@"QuicksandBold-Regular" size:17];
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
                                                                value:@"Read"]
                forState:UIControlStateNormal];
	[readButton titleLabel].font = [UIFont fontWithName:@"QuicksandBold-Regular" size:17];
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
                                                                  value:@"Cancel"]
                  forState:UIControlStateNormal];
	[cancelButton titleLabel].font = [UIFont fontWithName:@"QuicksandBold-Regular" size:17];
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
                                                                  value:@"Delete"]
                  forState:UIControlStateNormal];
	[deleteButton titleLabel].font = [UIFont fontWithName:@"QuicksandBold-Regular" size:17];
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
                                                               value:@"Pay"]
               forState:UIControlStateNormal];
	[payButton titleLabel].font = [UIFont fontWithName:@"QuicksandBold-Regular" size:17];
    [payButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
	[payButton titleLabel].backgroundColor = [UIColor clearColor];
	[payButton titleLabel].textAlignment = UITextAlignmentCenter;
	[payButton titleLabel].textColor = [UIColor whiteColor];
	[payButton sizeToFit];
	deleteButton.hidden = YES;
	[self addSubview:payButton];
    
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
    UIImage * placeholderImage = [UIImage imageNamed:@"home_illustration_placeholder"];
    self.illustrationImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - placeholderImage.size.width) /2, (self.bounds.size.height - placeholderImage.size.height) /2, placeholderImage.size.width, placeholderImage.size.height)];
    self.illustrationImageView.image = placeholderImage;
    self.illustrationImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.illustrationImageView.clipsToBounds = YES;
    [self addSubview:self.illustrationImageView];
    
    self.imageViewShadowImage = [[UIImage imageNamed:@"home_issue_bg_shadow_6px"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
}

- (void)initLabels {
    //[super initLabels];
    NSString * text = @"hello Text! I am a big line\nof the text\ntest test test";
    self.titleLabel = [[PCKioskAdvancedControlElementTitleLabel alloc] initWithFrame:CGRectMake(0, 31, 400, 200)];
    [_titleLabel setFont:[UIFont fontWithName:@"Interstate-Black" size:30.0f]];
    [_titleLabel setText:text];
    [_titleLabel setHighlightText:text];
    //[_titleLabel sizeToFit];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    
    //[_titleLabel setNeedsDisplay];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_titleLabel setHighlightColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
    [self addSubview:_titleLabel];
}

- (void) assignButtonsHandlers
{
    [super assignButtonsHandlers];
    
    [payButton addTarget:self
                  action:@selector(payButtonTapped)
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
    
    if (self.revisionIndex != 1) {
        UIImage         *coverImage = [self.dataSource revisionCoverImageWithIndex:self.revisionIndex andDelegate:self];
        self.illustrationImageView.image = coverImage;
    }

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

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    
    CGRect imageRect = self.illustrationImageView.frame;
    CGFloat  shadowWidth = 6.0f;
    CGRect shadowRect = CGRectMake(imageRect.origin.x - shadowWidth, imageRect.origin.y - shadowWidth, imageRect.size.width + shadowWidth*2, imageRect.size.height + shadowWidth*2);
    [self.imageViewShadowImage drawInRect:shadowRect];
}

@end
