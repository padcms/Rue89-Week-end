//
//  RueDownloadManager.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 9/30/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCDownloadManager.h"

typedef BOOL(^RueDownloadManagerProgressBlock)(float progress);//return YES to continue notifying

/**
 @brief Subclass of PCDownloadManager.
 @brief Service class that create separate instances of RueDownloadManager for each PCRevision object and download all content related for that PCRevision object as part of one downloading process.
 */
@interface RueDownloadManager : PCDownloadManager

/**
 @brief Creates RueDownloadManager instance if such not exists for specified revision and starts its downloading operations. Downloading progress is notifiing thru block. If download manager for specified PCRevision object already exists then only progressBlock will be added to execution queue. 
 @param revision PCRevision instance for which shold be started content downloading operations.
 @param progressBlock code block that executes each 0.75 seconds with current content downloadin progress. That block should return YES for continue execution. If block returns NO then it removes from execution queue. When downloading complete all blocks removing from queue automatically.
 */
+ (void) startDownloadingRevision:(PCRevision*)revision progressBlock:(RueDownloadManagerProgressBlock)progressBlock;

/**
 @brief returns YES if download manager for specified revision exists and all its download operations are complete, otherwise returns NO.
 */
+ (BOOL) isRevisionContentDownloading:(PCRevision*)revision;

/**
 @brief Removes download manager for specified revision.
 */
+ (void) removeRevision:(PCRevision*)revision;

@end
