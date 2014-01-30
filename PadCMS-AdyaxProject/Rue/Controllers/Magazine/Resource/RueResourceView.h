//
//  RueResourceView.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/4/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "PCResourceView.h"

/**@brief Subclass of PCResourceView designed to represent only piece of resource.*/

@interface RueResourceView : PCResourceView

/**@brief Index of resource piece that must be represented.*/

@property (nonatomic, assign) int indexOfPiece;

/**@brief Get piece image from cache or original resource file in background and show it when complete.*/
- (void) load;

/**@brief Hide image*/
- (void) unload;

/**@brief Returns YES if image is curently showing. Otherwise returns NO.*/
- (BOOL) isLoaded;

@end
