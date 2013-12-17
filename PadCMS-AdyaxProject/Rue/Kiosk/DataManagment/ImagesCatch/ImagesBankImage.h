//
//  ImagesBankImage.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/28/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagesBankImage : NSObject <NSCoding>

@property UIImage* rootImage;
@property NSDate* lastModifiedDate;

@end
