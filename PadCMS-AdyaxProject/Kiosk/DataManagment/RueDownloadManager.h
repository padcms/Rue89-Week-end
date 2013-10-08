//
//  RueDownloadManager.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 9/30/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCDownloadManager.h"

typedef BOOL(^RueDownloadManagerProgressBlock)(float progress);//return YES to continue notifying

@interface RueDownloadManager : PCDownloadManager

+ (void) startDownloadingRevision:(PCRevision*)revision progressBlock:(RueDownloadManagerProgressBlock)progressBlock;

+ (BOOL) isRevisionContentDownloading:(PCRevision*)revision;

@end
