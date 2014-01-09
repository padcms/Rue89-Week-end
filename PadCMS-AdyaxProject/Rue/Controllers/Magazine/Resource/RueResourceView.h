//
//  RueResourceView.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/4/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "PCResourceView.h"

@interface RueResourceView : PCResourceView

@property (nonatomic, assign) int indexOfPiece;

- (void) load;
- (void) unload;

- (BOOL) isLoaded;

@end
