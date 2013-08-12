//
//  PCMSKioskGalleryControlElement.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 27.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCMSKioskGalleryControlElement.h"
#import "PCKioskShelfSettings.h"

@implementation PCMSKioskGalleryControlElement

- (void) initCover
{
    // No cover
}

- (void) initLabels
{
    [super initLabels];
    
    CGRect        rect;
    
    rect = issueTitleLabel.frame;
    issueTitleLabel.frame = CGRectMake(0, rect.origin.y, self.bounds.size.width, rect.size.height);
    issueTitleLabel.textAlignment = UITextAlignmentCenter;
    issueTitleLabel.font = [UIFont fontWithName:@"Verdana" size:17];
    
    rect = revisionTitleLabel.frame;
    revisionTitleLabel.frame = CGRectMake(0, rect.origin.y, self.bounds.size.width, rect.size.height);
    revisionTitleLabel.textAlignment = UITextAlignmentCenter;
    revisionTitleLabel.font = [UIFont fontWithName:@"Verdana" size:19];

    rect = revisionStateLabel.frame;
    revisionStateLabel.frame = CGRectMake(0, rect.origin.y, self.bounds.size.width, rect.size.height);
    revisionStateLabel.textAlignment = UITextAlignmentCenter;
    revisionStateLabel.font = [UIFont fontWithName:@"Verdana" size:17];
}

- (void) initButtons
{
    [super initButtons];
    
    CGFloat xCenter = self.bounds.size.width / 2;
    
    downloadButton.center = CGPointMake(xCenter - (downloadButton.bounds.size.width + KIOSK_SHELF_CELL_BUTTONS_INTERVAL) / 2,
                                        KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN);
    
    previewButton.center = CGPointMake(xCenter + (previewButton.bounds.size.width + KIOSK_SHELF_CELL_BUTTONS_INTERVAL) / 2,
                                       KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN);
    
    cancelButton.center = CGPointMake(xCenter, KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN);

    updateButton.center = CGPointMake(xCenter - updateButton.bounds.size.width - KIOSK_SHELF_CELL_BUTTONS_INTERVAL, 
                                      KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN);
    
    readButton.center = CGPointMake(xCenter, KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN);
    
    deleteButton.center = CGPointMake(xCenter + updateButton.bounds.size.width + KIOSK_SHELF_CELL_BUTTONS_INTERVAL, 
                                      KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN);
}

- (void)adjustElements
{
    [super adjustElements];

    CGFloat xCenter = self.bounds.size.width / 2;

    if (previewButton.hidden) {
        downloadButton.center = CGPointMake(xCenter, KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN);
    } else {
        downloadButton.center = CGPointMake(xCenter - (downloadButton.bounds.size.width + KIOSK_SHELF_CELL_BUTTONS_INTERVAL) / 2,
                                            KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN);
        
        previewButton.center = CGPointMake(xCenter + (previewButton.bounds.size.width + KIOSK_SHELF_CELL_BUTTONS_INTERVAL) / 2,
                                           KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN);
    }
}

- (void) initDownloadingProgressComponents
{
    [super initDownloadingProgressComponents];

    downloadingProgressView.frame = CGRectMake((self.bounds.size.width - KIOSK_SHELF_CELL_BUTTONS_WIDTH)/2, KIOSK_SHELF_CELL_SECOND_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, 7);
    downloadingInfoLabel.frame = CGRectMake((self.bounds.size.width - KIOSK_SHELF_CELL_BUTTONS_WIDTH)/2, KIOSK_SHELF_CELL_SECOND_BUTTON_TOP_MARGIN + 10, KIOSK_SHELF_CELL_BUTTONS_WIDTH, KIOSK_SHELF_CELL_REVISION_TITLE_HEIGHT);
}

@end
