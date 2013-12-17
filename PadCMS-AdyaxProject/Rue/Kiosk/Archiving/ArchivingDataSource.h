//
//  ArchivingDataSource.h
//  Pad CMS
//
//  Created by tar on 11.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArchivingDataSource : NSObject

+ (NSArray *)allArchivedRevisionIds;

+ (void)addId:(NSInteger)revisionId;
+ (void)removeId:(NSInteger)revisionId;

@end
