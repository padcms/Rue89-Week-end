//
//  ImagesBank.h
//  ClosetSwap
//
//  Created by Martyniuk.M on 7/22/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagesBank : NSObject

+ (ImagesBank*) sharedBank;

- (void) getImageWithName:(NSString*)name path:(NSString*)imagePath toBlock:(void(^)(UIImage* image, NSError* error))completionBlock;

@end
