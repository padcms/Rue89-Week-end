//
//  PCKioskControlElement.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskControlElement.h"
#import "PCKioskShelfSettings.h"
#import "InAppPurchases.h"
#import "PCLocalizationManager.h"

@implementation PCKioskControlElement

-(void)dealloc
{
	[payButton release];
	[super dealloc];
}

- (void) initDownloadingProgressComponents
{
	[super initDownloadingProgressComponents];
	downloadingInfoLabel.frame = CGRectMake(downloadingProgressView.frame.origin.x,downloadingProgressView.frame.origin.y+downloadingProgressView.frame.size.height,downloadingProgressView.frame.size.width,30);
}

-(void)initButtons
{
 // [super initButtons];
	downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[downloadButton setBackgroundImage:[[UIImage imageNamed:@"wired_button3.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[downloadButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DOWNLOAD"
                                                                    value:@"Download"]
                    forState:UIControlStateNormal];
	[downloadButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:15];
	[downloadButton titleLabel].backgroundColor = [UIColor clearColor];
	[downloadButton titleLabel].textAlignment = UITextAlignmentCenter;
	[downloadButton titleLabel].textColor = [UIColor whiteColor];	
	[downloadButton sizeToFit];
	downloadButton.hidden = YES;
	[self addSubview:downloadButton];
	
	readButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[readButton setBackgroundImage:[[UIImage imageNamed:@"wired_button3.png.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[readButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_READ"
                                                                value:@"Read"]
                forState:UIControlStateNormal];
	[readButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:15];
	[readButton titleLabel].backgroundColor = [UIColor clearColor];
	[readButton titleLabel].textAlignment = UITextAlignmentCenter;
	[readButton titleLabel].textColor = [UIColor whiteColor];
	[readButton sizeToFit];
	readButton.hidden = YES;
	[self addSubview:readButton];	
	
	cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[cancelButton setBackgroundImage:[[UIImage imageNamed:@"wired_button1.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[cancelButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_CANCEL"
                                                                  value:@"Cancel"]
                  forState:UIControlStateNormal];
	[cancelButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:14];
	[cancelButton titleLabel].backgroundColor = [UIColor clearColor];
	[cancelButton titleLabel].textAlignment = UITextAlignmentCenter;
	[cancelButton titleLabel].textColor = [UIColor whiteColor];	
	[cancelButton sizeToFit];
	cancelButton.hidden = YES;
	[self addSubview:cancelButton];
	
	deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[deleteButton setBackgroundImage:[[UIImage imageNamed:@"wired_button2.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[deleteButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DELETE"
                                                                  value:@"Delete"]
                  forState:UIControlStateNormal];
	[deleteButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:15];
	[deleteButton titleLabel].backgroundColor = [UIColor clearColor];
	[deleteButton titleLabel].textAlignment = UITextAlignmentCenter;
	[deleteButton titleLabel].textColor = [UIColor whiteColor];
	[deleteButton sizeToFit];
	deleteButton.hidden = YES;
	[self addSubview:deleteButton];
	
	payButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[payButton setBackgroundImage:[[UIImage imageNamed:@"wired_button2.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[payButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_PAY"
                                                               value:@"Pay"]
               forState:UIControlStateNormal];
	[payButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:14];
	[payButton titleLabel].backgroundColor = [UIColor clearColor];
	[payButton titleLabel].textAlignment = UITextAlignmentCenter;
	[payButton titleLabel].textColor = [UIColor whiteColor];	
	[payButton sizeToFit];
	deleteButton.hidden = YES;
	[self addSubview:payButton];
  
	downloadButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
	cancelButton.frame = downloadButton.frame;
	readButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
	deleteButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_SECOND_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
	payButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
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




@end
