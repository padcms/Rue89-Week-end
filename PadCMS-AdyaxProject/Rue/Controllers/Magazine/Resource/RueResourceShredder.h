//
//  RueResourceShredder.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/8/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCPageElement;

@interface RueResourceShredder : NSObject

+ (int) piecesCountForResource:(NSString*)resourcePath;

+ (CGSize) sizeOfPieceAtIndex:(int)index forResours:(NSString*)resourcePath;

+ (void) preparePieceAtIndex:(int)index ofResource:(NSString*)resourcePath completion:(void(^)(NSString* piecePath))completionBlock;

+ (float) heightNoNeededToShred;


+ (BOOL) allPeacesExistsForResource:(NSString*)resourcePath;

+ (int) piecesCountForElement:(PCPageElement*)element;

+ (BOOL) pieceExistsAtIndex:(int)index forResource:(NSString*)resource;

+ (NSString*) piecePathAtIndex:(int)index forResource:(NSString*)resource;

@end
