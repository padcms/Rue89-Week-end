//
//  ImagesBank+Storage.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/28/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "ImagesBank+Storage.h"
#import "ImagesBankImage.h"

@implementation ImagesBank (Storage)

- (ImagesBankImage*) storedImageWithName:(NSString*)fileName
{
    NSString* filePath = [[self imagesLocalDirectory]stringByAppendingPathComponent:fileName];
    
    ImagesBankImage* restoredImage = nil;
    
    NSData* restoringData = [NSData dataWithContentsOfFile:filePath];
    if(restoringData)
    {
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:restoringData];
        restoredImage = [unarchiver decodeObject];
        [unarchiver finishDecoding];
    }
    return restoredImage;
}

- (void) writeImage:(ImagesBankImage*)image toDiscWithName:(NSString*)fileName
{
    NSMutableData* storingData = [[NSMutableData alloc]init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:storingData];
    [archiver encodeObject:image];
    [archiver finishEncoding];
    
    if(storingData)
    {
        NSString* filePath = [[self imagesLocalDirectory]stringByAppendingPathComponent:fileName];
        
        if([storingData writeToFile:filePath atomically:YES])
        {
            //NSLog(@"saved to %@ successful", filePath);
        }
        else NSLog(@"Saving to %@ failed", filePath);
    }
    else
    {
        NSLog(@"Encoding of image named %@ failed", fileName);
    }
}

- (BOOL) existsFileWithName:(NSString*)fileName
{
    NSString* filePath = [[self imagesLocalDirectory]stringByAppendingPathComponent:fileName];
    return [[NSFileManager defaultManager]fileExistsAtPath:filePath];
}

- (NSString*) imagesLocalDirectory
{
    static NSString* imagesDir = nil;
    
    if(!imagesDir)
    {
        NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryPath = [libraryPaths objectAtIndex:0];
        
        NSString * privatPath = [libraryPath stringByAppendingPathComponent:@"PrivateDocuments"];
        
        imagesDir = [privatPath stringByAppendingPathComponent:@"CoverImages"];
        
        [[NSFileManager defaultManager]createDirectoryAtPath:imagesDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return imagesDir;
}

@end
