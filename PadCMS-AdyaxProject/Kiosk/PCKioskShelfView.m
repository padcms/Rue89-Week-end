//
//  PCKioskShelfView.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskShelfView.h"
#import "PCKioskControlElement.h"
#import "PCKioskAdvancedControlElement.h"
#import "PCKioskShelfSettings.h"

@implementation PCKioskShelfView

- (PCKioskAbstractControlElement*) newCellWithFrame:(CGRect) frame;
{
    return [[PCKioskAdvancedControlElement alloc] initWithFrame:frame];
}

#pragma mark - Overrides

- (void) createCells
{
    NSInteger       numberOfRevisions = [self.dataSource numberOfRevisions];
    mainScrollView.contentSize = CGSizeMake(self.frame.size.width, numberOfRevisions*(KIOSK_ADVANCED_SHELF_ROW_HEIGHT + KIOSK_ADVANCED_SHELF_ROW_MARGIN_TOP));
    
    cells = [[NSMutableArray alloc] initWithCapacity:numberOfRevisions];
    
    //CGFloat         middle = self.bounds.size.width / 2.0f;
    
    for(int i=0; i<numberOfRevisions; i++)
    {
        CGRect                   cellFrame;
        

        cellFrame.origin.x = KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT;

        cellFrame.origin.y = (i * (KIOSK_ADVANCED_SHELF_ROW_HEIGHT + KIOSK_ADVANCED_SHELF_ROW_MARGIN_TOP)) + KIOSK_ADVANCED_SHELF_ROW_MARGIN_TOP;
        cellFrame.size.width = self.bounds.size.width - KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT*2;
        cellFrame.size.height = KIOSK_ADVANCED_SHELF_ROW_HEIGHT;
        
        PCKioskAbstractControlElement        *newCell = [self newCellWithFrame:cellFrame];
        
        newCell.autoresizesSubviews = YES;

        newCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        newCell.revisionIndex = i;
        newCell.dataSource = self.dataSource;
        newCell.delegate = self;
        
        
        
        [mainScrollView addSubview:newCell];
        
        [newCell load];
        
        
        [cells addObject:newCell];
    }
}

@end
