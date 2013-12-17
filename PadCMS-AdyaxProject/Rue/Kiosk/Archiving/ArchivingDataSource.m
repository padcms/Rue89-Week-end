//
//  ArchivingDataSource.m
//  Pad CMS
//
//  Created by tar on 11.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "ArchivingDataSource.h"

#define REVISION_IDS_KEY @"revision_ids"

#define DEFAULTS [NSUserDefaults standardUserDefaults]

@implementation ArchivingDataSource

+ (NSArray *)allArchivedRevisionIds {
    return [DEFAULTS objectForKey:REVISION_IDS_KEY];
}

+ (void)addId:(NSInteger)revisionId {
    NSMutableArray * allIds = [[self allArchivedRevisionIds] mutableCopy];
    
    if (!allIds) {
        allIds = [NSMutableArray new];
    }
    
    [allIds addObject:@(revisionId)];
    [DEFAULTS setObject:allIds forKey:REVISION_IDS_KEY];
    [DEFAULTS synchronize];
}

+ (void)removeId:(NSInteger)revisionId {
    NSMutableArray * allIds = [[self allArchivedRevisionIds] mutableCopy];
    
    NSInteger indexToDelete = [allIds indexOfObject:@(revisionId)];
    
    if (indexToDelete != NSNotFound) {
        [allIds removeObjectAtIndex:indexToDelete];
        [DEFAULTS setObject:allIds forKey:REVISION_IDS_KEY];
        [DEFAULTS synchronize];
    }
}

@end
