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

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _numberOfRevisionsPerPage = 5;
        _currentPage = 1;

    }
    
    return self;
}

- (void)setDataSource:(id<PCKioskDataSourceProtocol>)dataSource {
    [super setDataSource:dataSource];
    
    _totalNumberOfRevisions = [self.dataSource numberOfRevisions];
    _totalPages = ceilf((float)_totalNumberOfRevisions / (float)_numberOfRevisionsPerPage);
    
}

- (PCKioskAbstractControlElement*) newCellWithFrame:(CGRect) frame;
{
    return [[PCKioskAdvancedControlElement alloc] initWithFrame:frame];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    
    [self createCells];
}

- (void)setNumberOfRevisionsPerPage:(NSInteger)numberOfRevisionsPerPage {
    _numberOfRevisionsPerPage = numberOfRevisionsPerPage;
    
    [self createCells];
}

#pragma mark - Overrides

- (void) createCells
{
    
    NSInteger numberOfRevisions = _numberOfRevisionsPerPage;
    if (_currentPage == _totalPages) {
        numberOfRevisions = _totalNumberOfRevisions % _numberOfRevisionsPerPage;
    }
    
    NSInteger startRevisionIndex = (_currentPage - 1) * _numberOfRevisionsPerPage;
    
    
    
            CGFloat paginationHeight = 57.0f;
    mainScrollView.contentSize = CGSizeMake(self.frame.size.width, numberOfRevisions*(KIOSK_ADVANCED_SHELF_ROW_HEIGHT + KIOSK_ADVANCED_SHELF_ROW_MARGIN) + KIOSK_ADVANCED_SHELF_MARGIN_TOP + paginationHeight);
    
    for (UIView * view in cells) {
        [view removeFromSuperview];
    }
    
    [cells removeAllObjects];
    [cells release];
    
    cells = [[NSMutableArray alloc] initWithCapacity:numberOfRevisions];
    
    //CGFloat         middle = self.bounds.size.width / 2.0f;
    
    int counter = 0;
    for(int i = startRevisionIndex; i < startRevisionIndex + numberOfRevisions; i++)
    {
        CGRect                   cellFrame;
        

        cellFrame.origin.x = KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT;

        cellFrame.origin.y = (counter * (KIOSK_ADVANCED_SHELF_ROW_HEIGHT + KIOSK_ADVANCED_SHELF_ROW_MARGIN)) + KIOSK_ADVANCED_SHELF_MARGIN_TOP;
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
        
        counter++;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        [mainScrollView setContentOffset:CGPointMake(0, 0)];
    }];
    
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

#pragma mark - PCKioskPageControlDelegate

- (void)kioskPageControl:(PCKioskPageControl *)pageControl didChangePage:(NSInteger)page {
    [self setCurrentPage:page];
}

@end
