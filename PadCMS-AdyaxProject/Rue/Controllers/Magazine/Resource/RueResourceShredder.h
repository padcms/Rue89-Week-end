//
//  RueResourceShredder.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/8/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RueResourceShredder : NSObject

+ (int) piecesCountForResource:(NSString*)resourcePath;

+ (CGSize) sizeOfPieceAtIndex:(int)index forResours:(NSString*)resourcePath;

+ (void) preparePieceAtIndex:(int)index ofResource:(NSString*)resourcePath completion:(void(^)(NSString* piecePath))completionBlock;

@end
