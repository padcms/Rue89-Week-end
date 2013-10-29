//
//  ImagesBank+Networking.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/28/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "ImagesBank.h"

@interface ImagesBank (Networking)

- (void) findImageInNetworkWithPath:(NSString*)path completion:(void(^)(NSDate* lastModifiedDate, NSError* error))complBlock;
- (void) downloadImageFromPath:(NSString*)path completion:(void(^)(UIImage* image, NSDate* lastModifiedDate, NSError* error))complBlock;

@end
