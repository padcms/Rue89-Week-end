//
//  PCGooglePlusController.h
//  Pad CMS
//
//  Created by Martyniuk.M on 9/23/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCGooglePlusController : NSObject

- (id) initWithMessage:(NSString*)postMessage postUrl:(NSString*)urlPath;

- (void) shareWithDialog:(void(^)(UIView* dialogView))dialogBlock authorizationComplete:(void(^)(UIView* dialogView))authComplBlock complete:(void(^)(UIView* dialogView))completionBlock;

@end
