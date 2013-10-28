//
//  ImagesBank.m
//  ClosetSwap
//
//  Created by Martyniuk.M on 10/25/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import "ImagesBank.h"
#import "ImagesBank+Networking.h"
#import "ImagesBank+Storage.h"

#import "ImagesBankImage.h"

#import "NSObject+Block.h"

#define ItemsCashSize 30

//@interface StoredImage : NSObject <NSCoding>
//@property UIImage* rootImage;
//@property NSDate* lastModifiedDate;
//@end

@interface ImagesBank ()
{
    NSMutableDictionary* _loadedImages;
    NSMutableArray* _imagesNames;
}

@end

@implementation ImagesBank

static ImagesBank* bank = nil;

+ (void) initialize
{
    bank = [[ImagesBank alloc]init];
}

+ (ImagesBank*) sharedBank
{
    return bank;
}

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

- (void) getImageWithName:(NSString*)fileName path:(NSString*)imagePath toBlock:(void(^)(UIImage* image, NSError* error))completionBlock
{
    ImagesBankImage* image = [_loadedImages objectForKey:fileName];
    
    void(^updateImage)() = ^{
        
        [self downloadImageFromPath:imagePath completion:^(UIImage *image, NSDate *lastModifiedDate, NSError *error) {
            
            ImagesBankImage* newImage = [[ImagesBankImage alloc]init];
            newImage.rootImage = image;
            newImage.lastModifiedDate = lastModifiedDate;
            [_loadedImages setObject:newImage forKey:fileName];
            [self performInBackground:^{
                [self writeImage:newImage toDiscWithName:fileName];
            }];
            if(completionBlock) completionBlock(newImage.rootImage, nil);
        }];
    };
    
    if(image)
    {
        if(completionBlock) completionBlock(image.rootImage, nil);
    }
    else
    {
        if([self existsFileWithName:fileName])
        {
            image = [self storedImageWithName:fileName];
            
            if(image)
            {
                [self findImageInNetworkWithPath:imagePath completion:^(NSDate *lastModifiedDate, NSError *error) {
                    
                    if(error)
                    {
                        [_loadedImages setObject:image forKey:fileName];
                        if(completionBlock) completionBlock(image.rootImage, nil);
                    }
                    else
                    {
                        if([image.lastModifiedDate compare:lastModifiedDate] == NSOrderedAscending)
                        {
                            updateImage();
                        }
                        else
                        {
                            [_loadedImages setObject:image forKey:fileName];
                            if(completionBlock) completionBlock(image.rootImage, nil);
                        }
                    }
                }];
            }
            else
            {
                updateImage();
            }
        }
        else
        {
            updateImage();
        }
    }
}



- (void) getImageNamed:(NSString*)imageName toBlock:(void(^)(UIImage* image, NSError* error, BOOL isThumbForVideo))completionBlock
{
/*    [AwsS3Api findImageWithName:imageName completionBlock:^(NSDate *lastModifDate, NSError *error, BOOL isVideoType) {
        
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
        
    }];*/
}



- (void) performRequest:(NSURLRequest*)request inBackgroun:(BOOL)inBackground withCompletionHandler:(void(^)(id receivedData, NSError * error))block
{
    void(^resultBlock)(NSData * receivedData, NSDictionary* headers, NSError * error) = ^(NSData * receivedData, NSDictionary* headers, NSError * error){
        
        NSLog(@"headers : %@", headers.debugDescription);
        NSLog(@"error : %@", error.localizedDescription);
        NSLog(@"data : %@\n\n\n", [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding]);
        /*
        if(error)
        {
            NSLog(@"Connection error : %@", error.localizedDescription);
            block(nil, error);
        }
        else
        {
            NSString* content = [headers objectForKey:@"Content-Length"];
            if(content)
            {
                int length = [content intValue];
                if(length)
                {
                    //NSLog(@"%@", headers.debugDescription);
                    block([NSDictionary dictionaryWithObjectsAndKeys:receivedData, @"data", headers, @"headers", nil], nil);
                    return;
                }
            }
            
            NSArray* result = [PicabaParser arrayByParseFromData:receivedData];
            if(result)
            {
                result = [result arrayByAddingObject:headers];
            }
            else
            {
                //NSLog(@"%@", [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding]);
                result = [NSArray arrayWithObject:headers];
            }
            
            if(result.count > 0)
            {
                //NSLog(@"Response result : %@", result.debugDescription);
                
                NSDictionary* resultDictionary = [result objectAtIndex:0];
                NSString* messageString = [resultDictionary objectForKey:@"Message"];
                if(messageString)
                {
                    NSError * amazonError = [NSError errorWithDomain:kAmazonServerErrorKey code:0001 userInfo:[NSDictionary dictionaryWithObject:messageString forKey:NSLocalizedDescriptionKey]];
                    NSLog(@"Amazon server error : %@", amazonError.localizedDescription);
                    block(nil, amazonError);
                }
                else
                {
                    block(result, nil);
                }
            }
            else
            {
                NSError * amazonError = [NSError errorWithDomain:kAmazonServerErrorKey code:0000 userInfo:[NSDictionary dictionaryWithObject:@"No responce from server." forKey:NSLocalizedDescriptionKey]];
                NSLog(@"%@", amazonError.localizedDescription);
                block(nil, amazonError);
            }
        }
        */
    };
    
    if(inBackground)
    {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * receivedData, NSError * error) {
            
            resultBlock(receivedData, ((NSHTTPURLResponse*)response).allHeaderFields, error);
        }];
    }
    else
    {
        NSError* error = nil;
        NSURLResponse* response = nil;
        NSData* receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        resultBlock(receivedData, ((NSHTTPURLResponse*)response).allHeaderFields, error);
    }
}

/*- (void) pushImage:(UIImage*)image named:(NSString*)imageName completionBlock:(void (^)(NSError* error))completionBlock
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
}*/

/*- (void) removeImageNamed:(NSString*)imageName completionBlock:(void(^)(NSError *error))completionBlock
{
//    [AwsS3Api removeImageWithName:imageName completion:^(NSError *error) {
//        
//        if(error)
//        {
//            completionBlock(error);
//        }
//        else
//        {
            [_loadedImages removeObjectForKey:imageName];
            [[NSFileManager defaultManager]removeItemAtPath:[[self imagesLocalDirectory]stringByAppendingPathComponent:imageName] error:nil];
            completionBlock(nil);
//        }
//        
//    }];
}*/

//- (void) writeImage:(StoredImage*)image toDiscWithName:(NSString*)fileName
//{
//    NSMutableData* storingData = [[NSMutableData alloc]init];
//    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:storingData];
//    [archiver encodeObject:image];
//    [archiver finishEncoding];
//    
//    if(storingData)
//    {
//        NSString* filePath = [[self imagesLocalDirectory]stringByAppendingPathComponent:fileName];
//        
//        if([storingData writeToFile:filePath atomically:YES])
//        {
//            //NSLog(@"saved to %@ successful", filePath);
//        }
//        else NSLog(@"Saving to %@ failed", filePath);
//    }
//    else
//    {
//        NSLog(@"Encoding of image named %@ failed", fileName);
//    }
//}

//- (NSString*) imagesLocalDirectory
//{
//    static NSString* imagesDir = nil;
//    
//    if(!imagesDir)
//    {
//        NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
//        NSString *libraryPath = [libraryPaths objectAtIndex:0];
//        
//        NSString * privatPath = [libraryPath stringByAppendingPathComponent:@"PrivateDocuments"];
//        
//        imagesDir = [privatPath stringByAppendingPathComponent:@"CoverImages"];
//        
//        [[NSFileManager defaultManager]createDirectoryAtPath:imagesDir withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    return imagesDir;
//}

- (void) didReceiveMemoryWarningWithNotification:(NSNotification*)notification
{
    _loadedImages = [[NSMutableDictionary alloc]init];
    NSLog(@"Images bank was cleaned");
}

@end

//@implementation StoredImage
//
//#pragma mark - NSCoding protocol
//
//- (void) encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:UIImagePNGRepresentation(self.rootImage) forKey:@"imageData"];
//    [aCoder encodeObject:self.lastModifiedDate forKey:@"date"];
//}
//
//- (id) initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if(self)
//    {
//        _rootImage = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"imageData"]];
//        _lastModifiedDate = [aDecoder decodeObjectForKey:@"date"];
//    }
//    return self;
//}
//
//@end
