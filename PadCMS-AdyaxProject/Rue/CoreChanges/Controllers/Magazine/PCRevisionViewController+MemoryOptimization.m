//
//  PCRevisionViewController+MemoryOptimization.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevisionViewController.h"

@interface PCRevisionViewController ()

- (NSInteger) currentColumnIndex;
- (void) unloadFullColumnAtIndex:(NSInteger)index;

@end

@implementation PCRevisionViewController (MemoryOptimization)

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSInteger currentIndex = [self currentColumnIndex];
    
    if(currentIndex > 0)
    {
        [self unloadFullColumnAtIndex:currentIndex - 1];
    }
    if(currentIndex + 1 < columnsViewControllers.count)
    {
        [self unloadFullColumnAtIndex:currentIndex + 1];
    }
    NSLog(@"Left/right columns was cleaned");
}

@end
