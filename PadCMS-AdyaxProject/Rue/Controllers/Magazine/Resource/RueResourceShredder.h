//
//  RueResourceShredder.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/8/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCPageElement;

/**
 Service class that managing deviding big height image files to small pieces for memory optimization.
 */
@interface RueResourceShredder : NSObject

/**
 @brief Pieces count of image devided by height equals to the height of the screen
 @param resouecePath full file path to image on disk
 @return (int) the rounded up result of dividing image height in points by a constant kPieceHeight
 @see kPieceHeight
 */
+ (int) piecesCountForResource:(NSString*)resourcePath;

/**
 @brief Size of image piece at specified index that will be when image will be devided by height
 @param index index of piece which size you want to determine.
 @param resouecePath full file path to image on disk
 @return (CGSize) size in points of piece
 @see kPieceHeight
 */
+ (CGSize) sizeOfPieceAtIndex:(int)index forResours:(NSString*)resourcePath;

/**
 @brief Find piece file or create it for specified image and return its full file path thru completionBlock piecePath parameter. 
 @brief If piece file already exists then completionBlock executed immediately, other way the original image resurce is adding to shredding queue in background and completionBlock will be called when piese file will be created.
 @param index index of image piece you need
 @param resouecePath full file path to original image on disk
 @param completionBlock block of code that will be performed on main tread when operation complete
 */
+ (void) preparePieceAtIndex:(int)index ofResource:(NSString*)resourcePath completion:(void(^)(NSString* piecePath))completionBlock;

/**
 @brief Maximum height of image resource that do not need to be shredded
 @return (float) height of image in poins
 */
+ (float) heightNoNeededToShred;

/**
 @brief Check that all pieces files exists for specified original image resource
 @param resouecePath full file path to original big image on disk
 @return YES if all pieces files exist
 @return NO if at least one piece file for original big image does not exists
 */
+ (BOOL) allPeacesExistsForResource:(NSString*)resourcePath;

/**
 @brief Count of pieces for resource image file that not already exists from PCPageElement object that describe it
 @param element object that describe image resource
 @return (int) the rounded up result of dividing element height in points by a constant kPieceHeight
 */
+ (int) piecesCountForElement:(PCPageElement*)element;

/**
 @brief Check that piece file exist for original big image resource at specified index
 @param index index of image piece you need
 @param resouecePath full file path to original image on disk
 @return YES if file exists at path defined with piecePathAtIndex:forResource:. Other way returns NO.
 */
+ (BOOL) pieceExistsAtIndex:(int)index forResource:(NSString*)resource;

/**
 @brief Full path to image file which is piece at specified index of original image
 @param index index of piece
 @param resouecePath full file path to image on disk
 @return (NSString*) full paht to image pice file
 */
+ (NSString*) piecePathAtIndex:(int)index forResource:(NSString*)resource;

@end
