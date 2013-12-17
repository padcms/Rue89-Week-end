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
    [_imagesNames addObject:key];
    if(_imagesNames.count > _itemsCacheSize)
    {
        NSString* keyToDelete = [_imagesNames objectAtIndex:0];
        [_loadedImages removeObjectForKey:keyToDelete];
    }
    
    [_loadedImages setObject:image forKey:key];
}

- (void) getImageWithName:(NSString*)fileName path:(NSString*)imagePath toBlock:(void(^)(UIImage* image, NSError* error))completionBlock
{
    void(^updateImage)() = ^{
        
        [self downloadImageFromPath:imagePath completion:^(UIImage *image, NSDate *lastModifiedDate, NSError *error) {
            
            ImagesBankImage* newImage = [[ImagesBankImage alloc]init];
            newImage.rootImage = image;
            newImage.lastModifiedDate = lastModifiedDate;
            [self addToLoadedImages:newImage forKey:fileName];
            [self performInBackground:^{
                [self writeImage:newImage toDiscWithName:fileName];
            }];
            if(completionBlock) completionBlock(newImage.rootImage, nil);
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

- (void) didReceiveMemoryWarningWithNotification:(NSNotification*)notification
{
    _loadedImages = [[NSMutableDictionary alloc]init];
    NSLog(@"Images bank was cleaned");
}

@end

