//
//  RueDownloadManager.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 9/30/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueDownloadManager.h"
#import "PCRevision.h"

@interface RueDownloadManager ()
{
    int _startOperationsCount;
    NSTimer* _progressTimer;
}
@property (nonatomic, assign) BOOL isDownloadComplete;
@property (nonatomic, strong) NSMutableArray* progressBlocks;

@end

@implementation RueDownloadManager

static NSMutableDictionary* active_dovnloaders;

+ (void) initialize
{
    active_dovnloaders = [[NSMutableDictionary alloc]init];
}

+ (void) startDownloadingRevision:(PCRevision*)revision progressBlock:(RueDownloadManagerProgressBlock)progressBlock
{
    RueDownloadManager* manager = nil;
    manager = [active_dovnloaders valueForKey:[NSString stringWithFormat:@"%i", revision.identifier]];
    if(manager == nil)
    {
        manager = [[self alloc]init];
        manager.isDownloadComplete = NO;
        manager.revision = revision;
        [active_dovnloaders setObject:manager forKey:[NSString stringWithFormat:@"%i", revision.identifier]];
    }
    
    if(manager.progressBlocks == nil)
    {
        manager.progressBlocks = [[NSMutableArray alloc]init];
    }
    
    [manager.progressBlocks addObject:[progressBlock copy]];
    
    [manager startDownloading];
}

+ (BOOL) isRevisionContentDownloading:(PCRevision*)revision
{
    RueDownloadManager* manager = [active_dovnloaders valueForKey:[NSString stringWithFormat:@"%i", revision.identifier]];
    
    if(manager && manager.isDownloadComplete == NO)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (void) removeRevision:(PCRevision*)revision
{
    [active_dovnloaders removeObjectForKey:[NSString stringWithFormat:@"%i", revision.identifier]];
}

- (void) startDownloading
{
    if(_progressTimer)
    {
        [_progressTimer invalidate];
    }
    
    _startOperationsCount = 0;
    [super startDownloading];
    _startOperationsCount = [self currentOperationsCount];
    
    if(_startOperationsCount)
    {
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(progressTimerTick:) userInfo:nil repeats:YES];
    }
    else
    {
        [self startProgressBlocksWithProgress:1];
    }
}

- (int) currentOperationsCount
{
    __block int count = 0;
    
    [self.operationsDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSArray* operationsArray = obj[@"primaryKey"];
        if(operationsArray)
        {
            count += operationsArray.count;
        }
        NSDictionary* secondaryOperations = obj[@"secondaryKey"];
        if(secondaryOperations)
        {
            count += secondaryOperations.count;
        }
        
    }];
    
    if(self.portraiteTocOperations)
    {
        count += self.portraiteTocOperations.count;
    }
    if(self.helpOperations)
    {
        count += self.helpOperations.count;
    }
    if(self.horizontalPageOperations)
    {
        count += self.horizontalPageOperations.count;
    }
    if(self.horizontalTocOperations)
    {
        count += self.horizontalTocOperations.count;
    }
    
    return count;
}

- (void) progressTimerTick:(NSTimer*)timer
{
    int currentOpCount = [self currentOperationsCount];
    float progress = (float)(_startOperationsCount - currentOpCount) / (float)_startOperationsCount;
    if(progress == 1)
    {
        [timer invalidate];
    }
    [self startProgressBlocksWithProgress:progress];
}

- (void) startProgressBlocksWithProgress:(float)progress
{
    NSLog(@"Revision : %i downloaded : %.2f%%", self.revision.identifier, progress * 100);
    
    if(progress == 1)
    {
        _isDownloadComplete = YES;
    }
    
    for (RueDownloadManagerProgressBlock block in self.progressBlocks)
    {
        BOOL shouldContinue = block(progress);
        if(shouldContinue == NO || progress == 1)
        {
            [self.progressBlocks removeObject:block];
        }
    }
}

@end
