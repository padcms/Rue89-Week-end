//
//  ImagesBankImage.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/28/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "ImagesBankImage.h"

@implementation ImagesBankImage




#pragma mark - NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:UIImagePNGRepresentation(self.rootImage) forKey:@"imageData"];
    [aCoder encodeObject:self.lastModifiedDate forKey:@"date"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        _rootImage = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"imageData"]];
        _lastModifiedDate = [aDecoder decodeObjectForKey:@"date"];
    }
    return self;
}

@end
