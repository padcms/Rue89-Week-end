//
//  PCKioskBaseShelfView+CoreChanges.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/16/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskSubviewDelegateProtocol.h"
#import "PCKioskBaseShelfView.h"

@interface PCKioskBaseShelfView ()
- (void) createCells;
@end

@implementation PCKioskBaseShelfView (CoreChanges)

- (void) disableAllCellsExceptCellWithIndex:(NSInteger) index
{
    if([cells count]==1) return;
    
    [UIView beginAnimations:@"disable_cells" context:nil];
    [UIView setAnimationDuration:0.5];
    
    for(PCKioskAbstractControlElement *cell in cells)
    {
        if(cell.revisionIndex!=index)
        {
            cell.userInteractionEnabled = NO;
            cell.alpha = 0.6;
        }
    }
    
    [UIView commitAnimations];
}

- (void) archiveButtonTappedWithRevisionIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(archiveButtonTappedWithRevisionIndex:)]) {
        [self.delegate archiveButtonTappedWithRevisionIndex:index];
    }
}

- (void)restoreButtonTappedWithRevisionIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(restoreButtonTappedWithRevisionIndex:)]) {
        [self.delegate restoreButtonTappedWithRevisionIndex:index];
    }
}

- (void) createView
{
    [super createView];
    
    
    self.backgroundColor = UIColorFromRGB(0x303030);
    
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mainScrollView.autoresizesSubviews = YES;
    mainScrollView.userInteractionEnabled = YES;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = YES;
    mainScrollView.alwaysBounceVertical = NO;
    
    [self addSubview:mainScrollView];
    
    [self createCells];
}

@end
