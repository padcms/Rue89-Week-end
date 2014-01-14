//
//  RueResourceShredder.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/8/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "RueResourceShredder.h"
#import "Helper.h"

#define kPieceHeight 1024

typedef void(^PreperePieceCompleteBlock)(NSString* piecePath);

@interface RueResourceShredder ()

@property (nonatomic, copy) NSString* resourcePath;
@property (nonatomic, assign) CGSize sizeForResource;

@property (nonatomic, strong) NSMutableArray* pieceCompleteBlocks;
@property (nonatomic, assign) BOOL processing;

- (BOOL) pieceAtIndexExists:(int)index;

@end

@implementation RueResourceShredder

static NSMutableDictionary* activeShredders = nil;
static NSMutableArray* shredersQueue = nil;

+ (void) load
{
    activeShredders = [[NSMutableDictionary alloc]init];
    shredersQueue = [[NSMutableArray alloc]init];
}

+ (void) preparePieceAtIndex:(int)index ofResource:(NSString*)resourcePath completion:(void(^)(NSString* piecePath))completionBlock
{
    RueResourceShredder* shredder = [RueResourceShredder shredderForResource:resourcePath];
    
    if([shredder pieceAtIndexExists:index])
    {
        if(completionBlock)
        {
            completionBlock([shredder pathForPieceWithIndex:index]);
        }
    }
    else
    {
        [shredder.pieceCompleteBlocks replaceObjectAtIndex:index withObject:[completionBlock copy]];
        
        if([shredersQueue indexOfObject:shredder] == NSNotFound)
        {
            [shredersQueue addObject:shredder];
            [(RueResourceShredder*)[shredersQueue objectAtIndex:0] start];
        }
    }
}

+ (int) piecesCountForResource:(NSString*)resourcePath
{
    RueResourceShredder* shredder = [RueResourceShredder shredderForResource:resourcePath];
    return [shredder countOfPieces];
}

+ (CGSize) sizeOfPieceAtIndex:(int)index forResours:(NSString*)resourcePath
{
    RueResourceShredder* shredder = [RueResourceShredder shredderForResource:resourcePath];
    int piecesCount = [shredder countOfPieces];
    float height = kPieceHeight;
    
    if(index == piecesCount - 1)
    {
        height = shredder.sizeForResource.height - index * kPieceHeight;
    }
    
    CGSize returnSize = CGSizeMake(shredder.sizeForResource.width, height);
    return returnSize;
}

+ (RueResourceShredder*) shredderForResource:(NSString*)resource
{
    RueResourceShredder* shredder = [activeShredders objectForKey:resource];
    if(shredder == nil)
    {
        shredder = [[RueResourceShredder alloc]initWithResource:resource];
        [activeShredders setObject:shredder forKey:resource];
    }
    return shredder;
}

- (id) initWithResource:(NSString*)resource
{
    self = [super init];
    if(self)
    {
        _resourcePath = resource;
        self.sizeForResource = [Helper getSizeForImage:resource];
        
        int contOfPieces = [self countOfPieces];
        _pieceCompleteBlocks = [[NSMutableArray alloc]initWithCapacity:contOfPieces];
        for (int i = 0; i < contOfPieces; ++i)
        {
            [_pieceCompleteBlocks addObject:[NSNull null]];
        }
    }
    return self;
}

- (int) countOfPieces
{
    int resultCount = ceilf(self.sizeForResource.height / kPieceHeight);
    return resultCount;
}

- (void) start
{
    if (self.processing == NO)
    {
        self.processing = YES;
        [self performSelectorInBackground:@selector(shredResource) withObject:nil];
    }
}

- (void) shredResource
{
    @autoreleasepool {
    
        int startIndex = 0;
        int countOfPieces = [self countOfPieces];
        
        NSString* folderPath = [self pathToPiecesFolder];
        BOOL isDirrectiry = NO;
        BOOL dirrectoryExists = [[NSFileManager defaultManager]fileExistsAtPath:folderPath isDirectory:&isDirrectiry];
        if(dirrectoryExists && isDirrectiry)
        {
            for (int i = 0; i < countOfPieces; ++i)
            {
                if([[NSFileManager defaultManager]fileExistsAtPath:[self pathForPieceWithIndex:i]])
                {
                    startIndex = i + 1;
                }
                else
                {
                    break;
                }
            }
        }
        else
        {
            NSError* error = nil;
            [[NSFileManager defaultManager]createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
            if(error)
                NSLog(@"create dirrectory error : %@", error.debugDescription);
        }
        
        
        UIImage* resource = [UIImage imageWithContentsOfFile:self.resourcePath];
        float screenScale = [UIScreen mainScreen].scale;
        
        for (int i = startIndex; i < countOfPieces; ++i)
        {
            @autoreleasepool {
               
                CGRect imageRect = CGRectMake(0, i * kPieceHeight * screenScale, self.sizeForResource.width * screenScale, kPieceHeight * screenScale);
                
                CGImageRef resourceCGImage = resource.CGImage;
                
                CGImageRef cgImage = CGImageCreateWithImageInRect(resourceCGImage, imageRect);
                
                [self writeToDiskImage:[[UIImage alloc]initWithCGImage:cgImage] asPieceWithIndex:i];
                
                [self performSelectorOnMainThread:@selector(peaceCompleteAtIndex:) withObject:[NSNumber numberWithInt:i] waitUntilDone:YES];
                
                CGImageRelease(cgImage);
            }
        }
        
        [self performSelectorOnMainThread:@selector(shreddingComplete) withObject:nil waitUntilDone:NO];
    }
}

- (void) shreddingComplete
{
    NSLog(@"image was shredded");
    
    self.processing = NO;
    [shredersQueue removeObject:self];
    if([shredersQueue count])
    {
        [(RueResourceShredder*)[shredersQueue objectAtIndex:0] start];
    }
}

- (void) peaceCompleteAtIndex:(NSNumber*)indexNumber
{
    int index = [indexNumber intValue];
    id completeBlock = [self.pieceCompleteBlocks objectAtIndex:index];
    if(completeBlock != [NSNull null])
    {
        ((PreperePieceCompleteBlock)completeBlock)([self pathForPieceWithIndex:index]);
    }
}

#pragma mark - file management

- (BOOL) isShreddingComplete
{
    NSError* error = nil;
    NSArray* contents = nil;
    contents = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[self pathToPiecesFolder] error:&error];
    if(error)
    {
        NSLog(@"Dirrectoru contents file manager error : %@", error.debugDescription);
    }
    if(contents && contents.count == [self countOfPieces])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL) pieceAtIndexExists:(int)index
{
    NSString* piecePath = [self pathForPieceWithIndex:index];
    return [[NSFileManager defaultManager] fileExistsAtPath:piecePath];
}

- (NSString*) pathForPieceWithIndex:(int)index
{
    NSString* fileName = [[self.resourcePath lastPathComponent] stringByDeletingPathExtension];
    
    NSString* folderPath = [self pathToPiecesFolder];
    
    NSString* piecePath = [[[folderPath stringByAppendingPathComponent:fileName] stringByAppendingFormat:@"%i", index] stringByAppendingPathExtension:@"png"];
    
    return piecePath;
}

- (NSString*) pathToPiecesFolder
{
    return [self.resourcePath stringByDeletingPathExtension];
}

- (void) writeToDiskImage:(UIImage*)image asPieceWithIndex:(int)index
{
    NSData* imageData = UIImagePNGRepresentation(image);
    
    [imageData writeToFile:[self pathForPieceWithIndex:index] atomically:NO];
    NSLog(@"image piece was writed to disk : %i", index);
}

@end
