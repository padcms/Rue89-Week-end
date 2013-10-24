//
//  ImagesBank.m
//  ClosetSwap
//
//  Created by Martyniuk.M on 7/22/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import "ImagesBank.h"
#import "NSObject+Block.h"

#define ItemsCashSize 30

@interface StoredImage : NSObject <NSCoding>
@property UIImage* rootImage;
@property NSDate* lastModifiedDate;
@end

@interface ImagesBank ()
{
    NSMutableDictionary* _loadedImages;
    NSMutableArray* _imagesNames;
}

@end

@implementation ImagesBank

- (id) init
{
    self = [super init];
    if(self)
    {
        _loadedImages = [[NSMutableDictionary alloc]init];
        _imagesNames = [[NSMutableArray alloc]init];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveMemoryWarningWithNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void) getImageNamed:(NSString*)imageName toBlock:(void(^)(UIImage* image, NSError* error, BOOL isThumbForVideo))completionBlock
{
    [AwsS3Api findImageWithName:imageName completionBlock:^(NSDate *lastModifDate, NSError *error, BOOL isVideoType) {
        
        if(error)
        {
            completionBlock(nil, error, NO);
        }
        else
        {
            __block StoredImage* stImage = [_loadedImages objectForKey:imageName];
            
            void(^updateImage)() = ^{
                [AwsS3Api getImageWithName:imageName completion:^(UIImage *image, NSError* error) {
                    if(error)
                    {
                        completionBlock(nil, error, isVideoType);
                    }
                    else
                    {
                        stImage = [[StoredImage alloc]init];
                        stImage.rootImage = image;
                        stImage.lastModifiedDate = lastModifDate;
                        [_loadedImages setObject:stImage forKey:imageName];
                        [self performInBackground:^{
                            [self writeImage:stImage toDiscWithName:imageName];
                        }];
                        completionBlock(image, nil, isVideoType);
                    }
                }];
            };
            void(^compare)() = ^{
                switch ([stImage.lastModifiedDate compare:lastModifDate])
                {
                    case NSOrderedSame:
                        completionBlock(stImage.rootImage, nil, isVideoType);
                        break;
                    case NSOrderedAscending:
                        updateImage();
                    default:
                        break;
                }
            };
            
            if(stImage == nil)
            {
                [self performInBackground:^{
                    
                    NSString* filePath = [[self imagesLocalDirectory]stringByAppendingPathComponent:imageName];
                    if([[NSFileManager defaultManager]fileExistsAtPath:filePath])
                    {
                        StoredImage* restoredImage = nil;
                        
                        NSData* restoringData = [NSData dataWithContentsOfFile:filePath];
                        if(restoringData)
                        {
                            NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:restoringData];
                            restoredImage = [unarchiver decodeObject];
                            [unarchiver finishDecoding];
                            [_loadedImages setObject:restoredImage forKey:imageName];
                            stImage = restoredImage;
                        }
                    }
                    
                } completion:^{
                    
                    if(stImage)
                    {
                        compare();
                    }
                    else
                    {
                        updateImage();
                    }
                    
                }];
            }
            else
            {
                compare();
            }
        }
        
    }];
}

- (void) pushImage:(UIImage*)image named:(NSString*)imageName completionBlock:(void (^)(NSError* error))completionBlock
{
    [AwsS3Api uploadImage:image withName:imageName completion:^(NSError *error, NSDate *modifDate) {
        
        if(!error)
        {
            StoredImage* newImage = [[StoredImage alloc]init];
            newImage.rootImage = image;
            newImage.lastModifiedDate = modifDate;
            [_loadedImages setObject:newImage forKey:imageName];
            [_imagesNames addObject:imageName];
            if(_imagesNames.count > ItemsCashSize)
            {
                NSString* nameToDelete = [_imagesNames objectAtIndex:0];
                [_imagesNames removeObjectAtIndex:0];
                [_loadedImages removeObjectForKey:nameToDelete];
            }
            
            [self performInBackground:^{
                [self writeImage:newImage toDiscWithName:imageName];
            }];
            
            completionBlock(nil);
        }
        else
        {
            completionBlock(error);
        }
     
    }];
}

- (void) removeImageNamed:(NSString*)imageName completionBlock:(void(^)(NSError *error))completionBlock
{
    [AwsS3Api removeImageWithName:imageName completion:^(NSError *error) {
        
        if(error)
        {
            completionBlock(error);
        }
        else
        {
            [_loadedImages removeObjectForKey:imageName];
            [[NSFileManager defaultManager]removeItemAtPath:[[self imagesLocalDirectory]stringByAppendingPathComponent:imageName] error:nil];
            completionBlock(nil);
        }
        
    }];
}

- (void) writeImage:(StoredImage*)image toDiscWithName:(NSString*)fileName
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

- (NSString*) imagesLocalDirectory
{
    static NSString* imagesDir = nil;
    
    if(!imagesDir)
    {
        NSString* tempDir = NSTemporaryDirectory();
        imagesDir = [tempDir stringByAppendingPathComponent:@"Images"];
        [[NSFileManager defaultManager]createDirectoryAtPath:imagesDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return imagesDir;
}

- (void) didReceiveMemoryWarningWithNotification:(NSNotification*)notification
{
    _loadedImages = [[NSMutableDictionary alloc]init];
    NSLog(@"Images bank was cleaned");
}

@end

@implementation StoredImage

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
