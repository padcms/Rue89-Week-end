//
//  PCRevision+DataOfDownload.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/3/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevision.h"

@interface PCRevision (DataOfDownload)

/**
 @brief Returns creation date of content directory for that PCRevision instance. If dirrectori does not exists returns nil.
 */
- (NSDate*) dateOfDownload;

/**
 @brief Returns YES if download manager for that revision exists and actually is in progress, otherwise returns NO.
 */
- (BOOL) isContentDownloading;

/**
 @brief Removes download manager for thar revision.
 */
- (void) deleteFromDownloadManager;

@end
