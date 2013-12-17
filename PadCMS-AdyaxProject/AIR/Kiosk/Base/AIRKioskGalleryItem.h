//
//  DCCVKioskGalleryItem.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/5/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PCKioskGalleryItem.h"

#ifdef IMAGE_WIDTH
#undef IMAGE_WIDTH
#endif

#ifdef IMAGE_HEIGHT
#undef IMAGE_HEIGHT
#endif

#ifdef DISTANCE_FROM_CENTER_Y
#undef DISTANCE_FROM_CENTER_Y
#endif

#ifdef GAP
#undef GAP
#endif

#ifdef DISTANCE_FROM_CENTER_X
#undef DISTANCE_FROM_CENTER_X
#endif

#define IMAGE_HEIGHT   (374)
#define IMAGE_WIDTH    (262)

#define GAP            (59)
#define DISTANCE_FROM_CENTER_Y (29)
#define DISTANCE_FROM_CENTER_X (232)

@interface AIRKioskGalleryItem : PCKioskGalleryItem

@end


@interface PCKioskGalleryItem (CorrectPosition)

- (void) correctPosition;

@end