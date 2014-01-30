//
//  RueDownloadManagerWithShreddingResources.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/16/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "RueDownloadManager.h"

/**
 @brief Subclass of RueDownloadManager that shredding image resources with big height via RueResourceShredder into small pieces as part of downloading operation.
 @see RueResourceShredder
 */
@interface RueDownloadManagerWithShreddingResources : RueDownloadManager

@end
