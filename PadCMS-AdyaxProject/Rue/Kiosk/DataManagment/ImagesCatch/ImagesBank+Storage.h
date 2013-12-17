//
//  ImagesBank+Storage.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/28/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "ImagesBank.h"

@class ImagesBankImage;

@interface ImagesBank (Storage)

- (BOOL) existsFileWithName:(NSString*)fileName;

- (ImagesBankImage*) storedImageWithName:(NSString*)name;
- (void) writeImage:(ImagesBankImage*)image toDiscWithName:(NSString*)fileName;

@end
