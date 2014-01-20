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

@interface ImagesBank ()
{
    NSMutableDictionary* _loadedImages;
    NSMutableArray* _imagesNames;
}

@property (nonatomic, assign) int itemsCacheSize;

@end

@implementation ImagesBank

static ImagesBank* bank = nil;
static CGSize fixedSize = {533, 300};

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
        _itemsCacheSize = 20;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveMemoryWarningWithNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void) addToLoadedImages:(ImagesBankImage*)image forKey:(NSString*)key
{
    [_loadedImages setObject:image forKey:key];
    [_imagesNames addObject:key];
    
    if(_imagesNames.count > _loadedImages.count)
    {
        NSRange rangeToRemove = {0,  _imagesNames.count - _loadedImages.count};
        [_imagesNames removeObjectsInRange:rangeToRemove];
    }
    
    if(_loadedImages.count > _itemsCacheSize)
    {
        NSString* keyToDelete = [_imagesNames objectAtIndex:0];
        [_imagesNames removeObjectAtIndex:0];
        [_loadedImages removeObjectForKey:keyToDelete];
    }
}

- (void) getImageWithName:(NSString*)fileName path:(NSString*)imagePath toBlock:(void(^)(UIImage* image, NSError* error))completionBlock
{
    void(^updateImage)() = ^{
        
        [self downloadImageFromPath:imagePath completion:^(UIImage *image, NSDate *lastModifiedDate, NSError *error) {
            
            if(error)
            {
                //NSLog(@"error downloadin image %@ : %@", fileName, error.debugDescription);
                if(completionBlock) completionBlock(nil, error);
            }
            else
            {
                [self scaleImageIfNeeded:image completion:^(UIImage *resultImage) {
                    
                    ImagesBankImage* newImage = [[ImagesBankImage alloc]init];
                    newImage.rootImage = resultImage;
                    newImage.lastModifiedDate = lastModifiedDate;
                    [self addToLoadedImages:newImage forKey:fileName];
                    [self performInBackground:^{
                        [self writeImage:newImage toDiscWithName:fileName];
                    }];
                    if(completionBlock) completionBlock(newImage.rootImage, nil);
                }];
            }
        }];
    };
    
    ImagesBankImage* image = [_loadedImages objectForKey:fileName];
    
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
                        [self addToLoadedImages:image forKey:fileName];
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
                            [self addToLoadedImages:image forKey:fileName];
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

- (void) scaleImageIfNeeded:(UIImage*)image completion:(void(^)(UIImage* resultImage))completion
{
    if([UIScreen mainScreen].scale == 1 && image.size.width >= fixedSize.width * 2)
    {
        UIGraphicsBeginImageContext(fixedSize);
        [image drawInRect:CGRectMake(0, 0, fixedSize.width, fixedSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    completion(image);
}

- (void) didReceiveMemoryWarningWithNotification:(NSNotification*)notification
{
    _loadedImages = [[NSMutableDictionary alloc]init];
    NSLog(@"Images bank was cleaned");
}

@end

