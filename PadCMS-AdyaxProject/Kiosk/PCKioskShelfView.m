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

@interface PCKioskShelfView() <PCKioskAdvancedControlElementHeightDelegate>

@end

@implementation PCKioskShelfView

- (PCKioskAbstractControlElement*) newCellWithFrame:(CGRect) frame;
{
    return [[PCKioskAdvancedControlElement alloc] initWithFrame:frame];
}

#pragma mark - Overrides

- (void) createCells
{
    NSInteger       numberOfRevisions = [self.dataSource numberOfRevisions];
    mainScrollView.contentSize = CGSizeMake(self.frame.size.width, numberOfRevisions*(KIOSK_ADVANCED_SHELF_ROW_HEIGHT + KIOSK_ADVANCED_SHELF_ROW_MARGIN) + KIOSK_ADVANCED_SHELF_MARGIN_TOP);
    
    cells = [[NSMutableArray alloc] initWithCapacity:numberOfRevisions];
    
    //CGFloat         middle = self.bounds.size.width / 2.0f;
    
    for(int i=0; i<numberOfRevisions; i++)
    {
        CGRect                   cellFrame;
        

        cellFrame.origin.x = KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT;

        cellFrame.origin.y = (i * (KIOSK_ADVANCED_SHELF_ROW_HEIGHT + KIOSK_ADVANCED_SHELF_ROW_MARGIN)) + KIOSK_ADVANCED_SHELF_MARGIN_TOP;
        cellFrame.size.width = self.bounds.size.width - KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT*2;
        cellFrame.size.height = KIOSK_ADVANCED_SHELF_ROW_HEIGHT;
        
        PCKioskAdvancedControlElement        *newCell = (PCKioskAdvancedControlElement *)[self newCellWithFrame:cellFrame];
        
        newCell.autoresizesSubviews = YES;

        newCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        newCell.revisionIndex = i;
        newCell.dataSource = self.dataSource;
        newCell.delegate = self;
        newCell.heightDelegate = self;
        
        
        
        
        [mainScrollView addSubview:newCell];
        
        [newCell load];
        
        //newCell.backgroundColor = [UIColor orangeColor];
        
        [cells addObject:newCell];
        
//        [self performSelector:@selector(testSetHeight) withObject:nil afterDelay:2.0f];
//        [self performSelector:@selector(testSetHeight2) withObject:nil afterDelay:3.0f];
//        [self performSelector:@selector(testSetHeight3) withObject:nil afterDelay:4.0f];
    }
}

//- (void)testSetHeight {
//    [self setHeight:400 forCellAtIndex:0];
//}
//
//- (void)testSetHeight2 {
//    [self setHeight:400 forCellAtIndex:1];
//}
//
//- (void)testSetHeight3 {
//    [self setHeight:320 forCellAtIndex:0];
//}



#pragma mark - PCKioskAdvancedControlElementHeightDelegate

- (void)setHeight:(CGFloat)height forCell:(PCKioskAdvancedControlElement *)cell {
    
    NSInteger index = cell.revisionIndex;
    
    NSInteger count = [cells count];
    
    if (index < count) {
        
        
        PCKioskAdvancedControlElement * cellToChange = [cells objectAtIndex:index];
        CGRect cellToChangeFrame = cellToChange.frame;
        CGFloat heightDelta = height - cellToChangeFrame.size.height;
        cellToChangeFrame.size.height = height;
        cellToChange.frame = cellToChangeFrame;
        [cellToChange setNeedsDisplay];
        
        int i = index + 1;
        if (i < count) {
            for (; i < count; i++) {
                PCKioskAdvancedControlElement * cell = [cells objectAtIndex:i];
                CGRect cellFrame = cell.frame;
                cellFrame.origin.y += heightDelta;
                cell.frame = cellFrame;
            }
        }
        mainScrollView.contentSize = CGSizeMake(mainScrollView.contentSize.width, mainScrollView.contentSize.height + heightDelta);
    }
}

@end
