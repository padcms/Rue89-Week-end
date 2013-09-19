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
#import "PCKioskSubHeaderView.h"
#import "PCKioskShelfViewCell.h"


@interface PCKioskShelfView() <PCKioskAdvancedControlElementHeightDelegate>

@property (nonatomic, strong) NSArray * revisions;
@property (nonatomic, strong) PCKioskSubHeaderView * subHeaderView;
@property (nonatomic) BOOL isSubheaderShown;
@property (nonatomic) NSInteger numberOfRevisionsForCurrentpage;


@end

#ifdef RUE

@interface PCKioskShelfView() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@end

#endif

@implementation PCKioskShelfView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _numberOfRevisionsPerPage = 20;
    }
    
    return self;
}

- (PCKioskPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [PCKioskPageControl pageControl];
        _pageControl.center = CGPointMake(self.frame.size.width/2, 500);
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.pagesCount = 1;
        _pageControl.delegate = self;
        _pageControl.currentPage = 1;
        
    }
    
    if (!_pageControl.superview) {
        [mainScrollView addSubview:_pageControl];
    }
    
    return _pageControl;
}

#ifdef RUE

- (void)setDataSource:(id<PCKioskDataSourceProtocol>)dataSource {
    [super setDataSource:dataSource];
    
    [self reload];
}

- (void)reload {
     self.revisions = [self.dataSource allSortedRevisions];
    [self calculateNumberOfRevisionsForCurrentPage];
    
    
    
    /* Animate the table view reload */
    [UIView transitionWithView: mainScrollView
                      duration: 0.35f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         //[self.tableView reloadData];
         [self createCells];
     }
                    completion: ^(BOOL isFinished)
     {
         
     }];
    
    [self layoutPageControl];
    
    
    
}


- (void)reloadWithScrollingToTop {
    self.shouldScrollToTopAfterReload = YES;
    [self reload];
}

- (void)showSubHeader:(BOOL)show {
    
    if ((show && !self.isSubheaderShown) || (!show && self.isSubheaderShown)) {
        self.isSubheaderShown = show;
        
        CGFloat width = self.subHeaderView.frame.size.width;
        CGFloat height = self.subHeaderView.frame.size.height;
        
        CGRect frame = CGRectMake(0, (show ? 0 : - height), width, height);
        
        UIEdgeInsets insets = UIEdgeInsetsMake(show ? 30 : 0, 0, 0, 0);
        
        
        CGPoint offset = CGPointMake(0, -insets.top);
        
        [UIView animateWithDuration:0.5f animations:^{
            self.subHeaderView.frame = frame;
            
            mainScrollView.contentInset = insets;
            mainScrollView.contentOffset = offset;
            
            
        }];
    }
}

- (void)createView {
    [super createView];
    
    self.backgroundColor = UIColorFromRGB(0xf6f8fa);
    
    self.subHeaderView = [[PCKioskSubHeaderView alloc] initWithFrame:CGRectMake(0, -40, self.bounds.size.width, 40)];
    [self addSubview:self.subHeaderView];
    
    [self createPrecomputedCells];

    //[self initTableView];
}

- (void)initTableView {
    
    [self createPrecomputedTableViewCells];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, mainScrollView.frame.size.width, mainScrollView.frame.size.height) style:UITableViewCellStyleDefault];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_tableView];
}

#endif

- (PCKioskAbstractControlElement*) newCellWithFrame:(CGRect) frame;
{
#ifdef RUE
    return [[PCKioskAdvancedControlElement alloc] initWithFrame:frame]; //autorelease
#else
    return [[PCKioskControlElement alloc] initWithFrame:frame];
#endif
}

- (void)setTotalNumberOfRevisions:(NSInteger)totalNumberOfRevisions {
    _totalNumberOfRevisions = totalNumberOfRevisions;
    
    self.pageControl.pagesCount = ceilf((float)_totalNumberOfRevisions / (float)_numberOfRevisionsPerPage);
}

#pragma mark - Overrides

#ifdef RUE

- (void)removeCells {
    
}

- (CGRect)cellFrameForIndex:(NSInteger)index {
    CGRect cellFrame;
    cellFrame.origin.x = KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT;
    cellFrame.origin.y = (index * (KIOSK_ADVANCED_SHELF_ROW_HEIGHT + KIOSK_ADVANCED_SHELF_ROW_MARGIN)) + KIOSK_ADVANCED_SHELF_MARGIN_TOP;
    cellFrame.size.width = self.bounds.size.width - KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT*2;
    cellFrame.size.height = KIOSK_ADVANCED_SHELF_ROW_HEIGHT;
    
    return cellFrame;
}

- (void)calculateNumberOfRevisionsForCurrentPage {
    
    self.totalNumberOfRevisions =  [self.revisions count];
    
    if (self.pageControl.currentPage > self.pageControl.pagesCount) {
        self.pageControl.currentPage = 1;
    }
    
    _numberOfRevisionsForCurrentpage = _numberOfRevisionsPerPage;
    if ((self.pageControl.currentPage == self.pageControl.pagesCount) && (_totalNumberOfRevisions % _numberOfRevisionsForCurrentpage != 0)) {
        _numberOfRevisionsForCurrentpage = _totalNumberOfRevisions % _numberOfRevisionsPerPage;
    }
    
    if (_totalNumberOfRevisions == 0) {
        _numberOfRevisionsForCurrentpage = 0;
    }
}

- (NSInteger)revisionIndexForRow:(NSInteger)row {
    NSInteger startRevisionIndex = (self.pageControl.currentPage - 1) * _numberOfRevisionsPerPage;
    NSInteger revisionIndex = startRevisionIndex + row;
    return revisionIndex;
}

- (void)createPrecomputedCells {
    if (!cells) {
        cells = [[NSMutableArray alloc] initWithCapacity:_numberOfRevisionsPerPage*2];
        
        for (int i = 0; i < _numberOfRevisionsPerPage*2;i++) {
            //[cells addObject:[NSNull null]];
            
            //if ([cell isEqual:[NSNull null]]) {
            CGRect cellFrame = [self cellFrameForIndex:i];
            
            PCKioskAdvancedControlElement        *cell = (PCKioskAdvancedControlElement *)[self newCellWithFrame:cellFrame];
            
            //setting delegates
            cell.dataSource = self.dataSource;
            cell.delegate = self;
            cell.heightDelegate = self;
            
            //allocation UI elements
            [cell load];
            
            [cells addObject:cell];
            //}
        }
    }
}

- (void) createCells
{
    
//    if (!cells) {
//        cells = [[NSMutableArray alloc] initWithCapacity:_numberOfRevisionsPerPage*2];
//        
//        for (int i = 0; i < _numberOfRevisionsPerPage*2;i++) {
//            //[cells addObject:[NSNull null]];
//            
//            //if ([cell isEqual:[NSNull null]]) {
//            CGRect cellFrame = [self cellFrameForIndex:i];
//            
//                PCKioskAdvancedControlElement        *cell = (PCKioskAdvancedControlElement *)[self newCellWithFrame:cellFrame];
//                
//                //setting delegates
//                cell.dataSource = self.dataSource;
//                cell.delegate = self;
//                cell.heightDelegate = self;
//                
//                //allocation UI elements
//                [cell load];
//                
//                [cells addObject:cell];
//            //}
//        }
//    }
//    
//    
//    /////////calculating all the stuff
//    self.totalNumberOfRevisions =  [self.revisions count];
//    
//    if (self.pageControl.currentPage > self.pageControl.pagesCount) {
//        self.pageControl.currentPage = 1;
//    }
//    
//    NSInteger numberOfRevisions = _numberOfRevisionsPerPage;
//    if ((self.pageControl.currentPage == self.pageControl.pagesCount) && (_totalNumberOfRevisions % numberOfRevisions != 0)) {
//        numberOfRevisions = _totalNumberOfRevisions % _numberOfRevisionsPerPage;
//    }
//    
//    if (_totalNumberOfRevisions == 0) {
//        numberOfRevisions = 0;
//    }
    
    NSInteger startRevisionIndex = (self.pageControl.currentPage - 1) * _numberOfRevisionsPerPage;
    
    //hardcoded pagination size
    CGFloat paginationHeight = 57.0f;
    
    //animate scroll view content size change
    [UIView animateWithDuration:0.5f animations:^{
        NSInteger multiplier = MAX(_numberOfRevisionsForCurrentpage, 1);
        
        mainScrollView.contentSize = CGSizeMake(self.frame.size.width, multiplier*(KIOSK_ADVANCED_SHELF_ROW_HEIGHT + KIOSK_ADVANCED_SHELF_ROW_MARGIN) + KIOSK_ADVANCED_SHELF_MARGIN_TOP + paginationHeight);
    }];
    
    //[cells removeAllObjects];
    
    //creating/updating new cells
    int counter = 0;
    for(int i = startRevisionIndex; i < startRevisionIndex + _numberOfRevisionsForCurrentpage; i++)
    {
        
        PCKioskAdvancedControlElement        *cell = [cells objectAtIndex:counter];
        
//        if ([cell isEqual:[NSNull null]]) {
//            CGRect cellFrame;
//            cellFrame.origin.x = KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT;
//            cellFrame.origin.y = (counter * (KIOSK_ADVANCED_SHELF_ROW_HEIGHT + KIOSK_ADVANCED_SHELF_ROW_MARGIN)) + KIOSK_ADVANCED_SHELF_MARGIN_TOP;
//            cellFrame.size.width = self.bounds.size.width - KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT*2;
//            cellFrame.size.height = KIOSK_ADVANCED_SHELF_ROW_HEIGHT;
//            
//            cell = (PCKioskAdvancedControlElement *)[self newCellWithFrame:cellFrame];
//            
//            //setting delegates
//            cell.dataSource = self.dataSource;
//            cell.delegate = self;
//            cell.heightDelegate = self;
//            
//            //allocation UI elements
//            [cell load];
//            
//            [cells replaceObjectAtIndex:counter withObject:cell];
//        }
        
        //and properties
        cell.revisionIndex = i;
        cell.revision = [self.revisions objectAtIndex:i];
        
        //reloading cell data
        [cell update];
        

        if (!cell.superview) {
            ////cell.alpha = 0.0f;
            [mainScrollView addSubview:cell];
            
//            [UIView animateWithDuration:0.5f animations:^{
//                cell.alpha = 1.0f;
//            }];
            cell.userInteractionEnabled = YES;
        }

        
        //newCell.backgroundColor = [UIColor orangeColor];
        
        counter++;
        //NSLog(@"SHELF VIEW CREATED");
    }
    
    //remove other cells
    for (int i = counter; i<_numberOfRevisionsPerPage; i++) {
        UIView * view = [cells objectAtIndex:i];
        if (![view isEqual:[NSNull null]]) {
//            [UIView animateWithDuration:0.5f animations:^{
//                view.alpha = 0.0f;
//                view.userInteractionEnabled = NO;
//            } completion:^(BOOL finished) {
                [view removeFromSuperview];
//            }];
        }
    }
    
    //[self layoutPageControl];
    
    [mainScrollView bringSubviewToFront:self.pageControl];
    
    NSLog(@"ALL SHELF VIEWS CREATED");
    
}

- (void)layoutPageControl {
    
    //updating page control alignment
    self.pageControl.alpha = 0.0f;
    [UIView animateWithDuration:0.5f animations:^{
        if (self.shouldScrollToTopAfterReload) {
            self.shouldScrollToTopAfterReload = NO;
            [mainScrollView setContentOffset:CGPointMake(0, -mainScrollView.contentInset.top)];
        }
        
        CGRect frame = self.pageControl.frame;
        frame.origin.y = mainScrollView.contentSize.height - frame.size.height - 12;
        self.pageControl.frame = frame;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            self.pageControl.alpha = 1.0f;
        }];
    }];
}

#endif


#pragma mark - PCKioskAdvancedControlElementHeightDelegate

- (void)setHeight:(CGFloat)height forCell:(PCKioskAdvancedControlElement *)cell {
    
    NSInteger index = [cells indexOfObject:cell];
    
    NSInteger count = 0;
    for (NSObject * object in cells) {
        if (![object isEqual:[NSNull null]]) {
            count++;
        }
    }
    
    //NSInteger count = [cells count];
    
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
        
        
        BOOL isLastCell = (index == (count - 1));
        
        if (isLastCell) {
            CGFloat y = mainScrollView.contentOffset.y;
            CGFloat height = mainScrollView.frame.size.height;
            CGFloat contentHeight = mainScrollView.contentSize.height;
            CGFloat treshOld = 100.0f;
            BOOL isContentSizeBiggerThanSize = (contentHeight > height);
            
            
            
            if (isContentSizeBiggerThanSize && ((y + height) > (contentHeight - treshOld))) {
                mainScrollView.contentOffset = CGPointMake(0, contentHeight - height);
            }
        }
    }
}

#pragma mark - PCKioskPageControlDelegate

- (void)kioskPageControl:(PCKioskPageControl *)pageControl didChangePage:(NSInteger)page {
    self.shouldScrollToTopAfterReload = YES;
    [self reload];
}


#pragma mark - PCKioskHeaderViewDelegate

- (void)logoButtonTapped {
    [mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)subscribeButtonTapped {
    //nothing
}

#ifdef RUE

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _numberOfRevisionsForCurrentpage;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return KIOSK_ADVANCED_SHELF_ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //static NSString * reuseIdentifier = @"ShelfCell";
    
    PCKioskShelfViewCell * cell = [cells objectAtIndex:indexPath.row];
    //[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil) {
//        cell = [[PCKioskShelfViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
//        
//        cell.controlElement.dataSource = self.dataSource;
//        cell.controlElement.delegate = self;
//        cell.controlElement.heightDelegate = self;
//
//        //allocation of UI elements
//        [cell.controlElement load];
    }
    
    NSInteger index = [self revisionIndexForRow:indexPath.row];
    
    cell.controlElement.revisionIndex = index;
    cell.controlElement.revision = [self.revisions objectAtIndex:index];
    
    [cell.controlElement update];
    
    return cell;
}

- (void)createPrecomputedTableViewCells {
    if (!cells) {
        cells = [NSMutableArray array];
        
        for (int i = 0; i < _numberOfRevisionsPerPage; i++) {
            PCKioskShelfViewCell * cell = [[PCKioskShelfViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            cell.controlElement.dataSource = self.dataSource;
            cell.controlElement.delegate = self;
            cell.controlElement.heightDelegate = self;
            
            //allocation of UI elements
            [cell.controlElement load];
            [cells addObject:cell];
        }
    }
}


#endif

@end
