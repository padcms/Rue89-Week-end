//
//  PCMSKioskControlElement.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCMSKioskControlElement.h"
#import "PCKioskShelfSettings.h"
#import "PCLocalizationManager.h"

@interface PCMSKioskControlElement ()
{
    UIImageView *_coverBackgroundImageView;
}

@end

@implementation PCMSKioskControlElement

#pragma mark - Override

- (void)dealloc
{
    [updateButton release];
    [super dealloc];
}

- (void) initButtons
{
    [super initButtons];
    
    [downloadButton setBackgroundImage:[[UIImage imageNamed:@"button-black.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
    
    [previewButton setBackgroundImage:[[UIImage imageNamed:@"button-black.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
    
    [readButton setBackgroundImage:[[UIImage imageNamed:@"button-black.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
    
    [cancelButton setBackgroundImage:[[UIImage imageNamed:@"button-black.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
    
    [deleteButton setBackgroundImage:[[UIImage imageNamed:@"button-black.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
    
    updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateButton setBackgroundImage:[[UIImage imageNamed:@"button-black.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
    [updateButton setTitle:NSLocalizedString(@"Update", nil)
                  forState:UIControlStateNormal];
    [updateButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:15];
    [updateButton titleLabel].backgroundColor = [UIColor clearColor];
    [updateButton titleLabel].textAlignment = UITextAlignmentCenter;
    [updateButton titleLabel].textColor = [UIColor whiteColor];
    [updateButton sizeToFit];
    updateButton.hidden = YES;

    [self addSubview:updateButton];
    
    downloadButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN,
                                      KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN - KIOSK_SHELF_CELL_BUTTONS_INTERVAL, 
                                      KIOSK_SHELF_CELL_BUTTONS_WIDTH, 
                                      KIOSK_SHELF_CELL_BUTTONS_HEIGHT);

    previewButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN,
                                     KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN + KIOSK_SHELF_CELL_BUTTONS_HEIGHT, 
                                     KIOSK_SHELF_CELL_BUTTONS_WIDTH, 
                                     KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
    
	cancelButton.frame = downloadButton.frame;
    
	readButton.frame = downloadButton.frame;
    
	deleteButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, 
                                    KIOSK_SHELF_ROW_HEIGHT - KIOSK_SHELF_CELL_BUTTONS_HEIGHT - KIOSK_SHELF_CELL_BUTTONS_INTERVAL * 2, 
                                    KIOSK_SHELF_CELL_BUTTONS_WIDTH, 
                                    KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
    
    updateButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, 
                                    KIOSK_SHELF_ROW_HEIGHT - KIOSK_SHELF_CELL_BUTTONS_HEIGHT * 2 - KIOSK_SHELF_CELL_BUTTONS_INTERVAL * 3, 
                                    KIOSK_SHELF_CELL_BUTTONS_WIDTH, 
                                    KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
}

- (void)initCover
{
    [super initCover];
    
    if (_coverBackgroundImageView == nil) {
        CGRect coverBackgroundImageViewFrame = CGRectMake(KIOSK_SHELF_CELL_COVER_MARGIN_LEFT, 
                                                          (self.bounds.size.height-KIOSK_SHELF_CELL_COVER_HEIGHT) / 2,
                                                          KIOSK_SHELF_CELL_COVER_WIDTH, 
                                                          KIOSK_SHELF_CELL_COVER_HEIGHT);
        _coverBackgroundImageView = [[UIImageView alloc] initWithFrame:coverBackgroundImageViewFrame];
    }
    
    UIImage *backgroundImage = [UIImage imageNamed:@"kiosk-shelf-cell-background.png"];
    UIImage *resizableBackgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    _coverBackgroundImageView.image = resizableBackgroundImage;
    [self addSubview:_coverBackgroundImageView];

    CGRect revisionCoverViewFrame = CGRectMake(5,
                                               5,
                                               KIOSK_SHELF_CELL_COVER_WIDTH - 10,
                                               KIOSK_SHELF_CELL_COVER_HEIGHT - 10);
    revisionCoverView.frame = revisionCoverViewFrame;
    [_coverBackgroundImageView addSubview:revisionCoverView];
}

- (void) assignButtonsHandlers
{
    [super assignButtonsHandlers];
    
    [updateButton addTarget:self
                     action:@selector(updateButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void) adjustElements
{
    [super adjustElements];
    
    if ([self.dataSource isRevisionDownloadedWithIndex:self.revisionIndex])
    {
        updateButton.hidden = NO;
    } else {

        if (self.downloadInProgress)
        {
            updateButton.hidden = YES;
        } else {
            updateButton.hidden = YES;
        }
    
    }
}

- (void)initLabels
{
    [super initLabels];
    
    issueTitleLabel.textColor = [UIColor blackColor];
    issueTitleLabel.font = [UIFont boldSystemFontOfSize:17];

    revisionTitleLabel.hidden = YES;
    revisionStateLabel.font = [UIFont systemFontOfSize:17];
    revisionStateLabel.textColor = [UIColor orangeColor];
    
    CGRect revisionTitleLabelFrame = revisionTitleLabel.frame;
    revisionStateLabel.frame = CGRectMake(revisionTitleLabelFrame.origin.x,
                                          revisionTitleLabelFrame.origin.y + 7,
                                          revisionTitleLabelFrame.size.width,
                                          revisionTitleLabelFrame.size.height);
}

#pragma mark - Buttons actions

- (void)updateButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(updateButtonTappedWithRevisionIndex:)]) {
        [self.delegate updateButtonTappedWithRevisionIndex:self.revisionIndex];
    }
}

- (void)previewButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(previewButtonTappedWithRevisionIndex:)]) {
        [self.delegate previewButtonTappedWithRevisionIndex:self.revisionIndex];
    }
}

@end
