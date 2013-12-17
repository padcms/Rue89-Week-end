//
//  PCKioskViewController+CoreChanges.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/16/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskViewControllerDelegateProtocol.h"
#import "PCKioskViewController.h"
#import "PCKioskSubviewDelegateProtocol.h"

@implementation PCKioskViewController (CoreChanges)

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadSubviewsOnViewWillAppear];
    
    [super viewWillAppear:animated];
}

- (void)reloadSubviewsOnViewWillAppear
{
    [self reloadSubviews];
}

- (void) archiveButtonTappedWithRevisionIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(archiveRevisionWithIndex:)]) {
        [self.delegate archiveRevisionWithIndex:index];
    }
}

- (void)restoreButtonTappedWithRevisionIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(restoreRevisionWithIndex:)]) {
        [self.delegate restoreRevisionWithIndex:index];
    }
}

@end
