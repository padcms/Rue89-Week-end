//
//  PCKioskBaseControlElement+CoreChanges.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/16/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskBaseControlElement.h"
#import "PCKioskShelfSettings.h"

@implementation PCKioskBaseControlElement (CoreChanges)

- (void) initDownloadingProgressComponents
{
    
    // Progress view init
    downloadingProgressView = [[PDColoredProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	[downloadingProgressView setTintColor: [UIColor colorWithRed:43.0/255.0
                                                           green:134.0/255.0
                                                            blue:225.0/255.0
                                                           alpha:1]];
    downloadingProgressView.hidden = YES;
    downloadingProgressView.frame = CGRectMake( KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_SECOND_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, 7);
	[self addSubview:downloadingProgressView];
    
    //    // Download info label
    //	downloadingInfoLabel = [[UILabel alloc] init];
    //	downloadingInfoLabel.font = [UIFont fontWithName:@"Verdana" size:15];
    //	downloadingInfoLabel.backgroundColor = [UIColor clearColor];
    //	downloadingInfoLabel.textAlignment = UITextAlignmentCenter;
    //	downloadingInfoLabel.textColor = [UIColor whiteColor];
    //    downloadingInfoLabel.hidden = YES;
    //    downloadingInfoLabel.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_THIRD_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, KIOSK_SHELF_CELL_REVISION_TITLE_HEIGHT);
    //	[self addSubview:downloadingInfoLabel];
}

- (void) downloadProgressUpdatedWithProgress:(float)progress andRemainingTime:(NSString *)time
{
    self.downloadInProgress = YES; //not sure if it will not bring any bugs
    downloadingProgressView.progress = progress;
    
    if(time)
    {
        downloadingInfoLabel.text = [NSString stringWithFormat:@"%3.0f %% %@",progress*100, time];
    } else {
        downloadingInfoLabel.text = [NSString stringWithFormat:@"%3.0f %%", progress*100];
    }
}

@end
