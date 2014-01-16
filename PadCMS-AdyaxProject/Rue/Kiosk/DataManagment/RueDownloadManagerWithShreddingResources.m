//
//  RueDownloadManagerWithShreddingResources.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/16/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "RueDownloadManagerWithShreddingResources.h"
#import "PCPageElemetTypes.h"
#import "RueResourceShredder.h"
#import "PCPageTemplatesPool.h"
#import "PCPageElementMiniArticle.h"
#import "PCPageElementGallery.h"
#import "PCDownloadOperation.h"

@class PCDownloadOperation;

@interface PCDownloadManager ()
{
@public
    AFHTTPClient *_httpClient;
}

- (NSString*) getUrlForResource:(NSString*)resource withType:(ItemType)type withHorizontalOrientation:(BOOL)horizontalOrientation;
- (AFHTTPRequestOperation*) operationWithURL:(NSString*)url
                              successBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             progressBlock:(void (^)(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) progressBlock
                              itemLocation:(NSString*)locationPath;
- (void) moveItemWithPath:(NSString*)filePath;

@end

@interface RueDownloadManager ()

- (int) currentOperationsCount;

@end

@interface RueDownloadManagerWithShreddingResources ()

@property (strong) NSMutableDictionary* shredOperations;

@end

@implementation RueDownloadManagerWithShreddingResources

- (id) init
{
    self = [super init];
    if(self)
    {
        self.shredOperations = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void) addOperationForResourcePath:(NSString*)path element:(PCPageElement*)element inPage:(PCPage*)page isPrimary:(BOOL)isPrimary isThumbnail:(BOOL) isThumbnail resumeOperation:(PCDownloadOperation*)canceledOperation
{
    NSNumber* pageIdentifier = [NSNumber numberWithInteger:page.identifier];
    NSNumber* elementIdentifier = [NSNumber numberWithInteger:element.identifier];
    ItemType type = isThumbnail? THUMBNAIL : PAGE;
    
    if ((element.page.pageTemplate.identifier == PCHorizontalScrollingPageTemplate) && ([element.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])) type = HORIZONTAL_SCROLLING_PANE;
    
    NSString* url = [self getUrlForResource:path withType:type withHorizontalOrientation:page.revision.horizontalOrientation];
    
    //*************************************************************************************************************************************
    BOOL needShredResource = NO;
    if([element.fieldTypeName isEqualToString:PCPageElementTypeBody] && element.size.height > [RueResourceShredder heightNoNeededToShred])
    {
        needShredResource = YES;
        [self addShredOperationForElement:element];
    }
    //*************************************************************************************************************************************
    
    AFHTTPRequestOperation* elementOperation = [self operationWithURL:url successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Element %d downloaded:isPrimary %@, isThumb %@, page - %@ ", element.identifier, isPrimary?@"YES":@"NO", isThumbnail?@"YES":@"NO", pageIdentifier);
        [self moveItemWithPath:[self.revision.contentDirectory stringByAppendingPathComponent:path]];
        
        //*********************************************************************************************
        if(needShredResource)
        {
            [self startShredOperationForResource:element.resource];
        }
        //*********************************************************************************************
        
        if (!isThumbnail) element.isComplete = YES;
        
        if (isPrimary)
        {
            [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:primaryKey] removeObject:operation];
        }
        else {
            [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:secondaryKey]  removeObjectForKey:elementIdentifier];
        }
        
        if (![[[self.operationsDic objectForKey:pageIdentifier] objectForKey:primaryKey] lastObject] && isPrimary) {
            //NSLog(@"VERTICAL PAGE DOWNLOADED - %@ - %@", pageIdentifier, path);
            dispatch_async(dispatch_get_main_queue(), ^{
                [page stopRepeatingTimer];
                page.isComplete = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:endOfDownloadingPageNotification object:page];
                
            });
            
        }
        
        if ([element.fieldTypeName isEqualToString:PCPageElementTypeGallery])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary* dic = [NSDictionary dictionaryWithObject:element forKey:@"element"];
                [[NSNotificationCenter defaultCenter] postNotificationName:PCGalleryElementDidDownloadNotification object:page userInfo:dic];
            });
            
        }
        if (!isPrimary && ( [element.fieldTypeName isEqualToString:PCPageElementTypeMiniArticle] ||  [element.fieldTypeName isEqualToString:PCPageElementTypeSlide]))
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary* dic = [NSDictionary dictionaryWithObject:element forKey:@"element"];
                [[NSNotificationCenter defaultCenter] postNotificationName:PCMiniArticleElementDidDownloadNotification object:page userInfo:dic];
            });
            
        }
        
    } progressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        dispatch_queue_t progressQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(progressQueue, ^{
            float progress = (float)totalBytesRead/(float)totalBytesExpectedToRead;
            if ([element isKindOfClass:[PCPageElementMiniArticle class]])
            {
                if (isThumbnail)
                {
                    PCPageElementMiniArticle* miniArticle = (PCPageElementMiniArticle*)element;
                    if ([miniArticle.thumbnail isEqualToString:path]) miniArticle.thumbnailProgress = progress;
                    else if ([miniArticle.thumbnailSelected isEqualToString:path])  miniArticle.thumbnailSelectedProgress = progress;
                    else abort();
                }
                else {
                    element.downloadProgress = progress;
                }
            } else
                if([element isKindOfClass:[PCPageElementGallery class]])
                {
                    element.downloadProgress = progress;
                }
                else {
                    element.downloadProgress = progress;
                }
        });
        
    } itemLocation:path];
    
    if (!elementOperation)
    {
        //*******************************************************
        [self startShredOperationForResource:element.resource];
        //*******************************************************
        return;
    }
    element.isComplete = NO;
    
    ((PCDownloadOperation*)elementOperation).page =page;
    ((PCDownloadOperation*)elementOperation).element =element;
    ((PCDownloadOperation*)elementOperation).resource = path;
    ((PCDownloadOperation*)elementOperation).isPrimary =isPrimary;
    ((PCDownloadOperation*)elementOperation).isThumbnail =isThumbnail;
    
    if (isPrimary)
    {
        [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:primaryKey] addObject:elementOperation];
    }
    else {
        [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:secondaryKey] setObject:elementOperation forKey:elementIdentifier];
    }
    
    if (canceledOperation) {
        [elementOperation setQueuePriority:NSOperationQueuePriorityHigh];
        [_httpClient enqueueHTTPRequestOperation:elementOperation];
    }
}

- (void) addShredOperationForElement:(PCPageElement*)element
{
    NSString* fullResource = [self.revision.contentDirectory stringByAppendingPathComponent:element.resource];
    
    int piecesCount = [RueResourceShredder piecesCountForElement:element];
    
    NSMutableArray* suboperations = [[NSMutableArray alloc]initWithCapacity:piecesCount];
    
    for (int i = 0; i < piecesCount; ++i)
    {
        if([RueResourceShredder pieceExistsAtIndex:i forResource:fullResource])
        {
            [suboperations addObject:[NSNumber numberWithBool:NO]];
        }
        else
        {
            [suboperations addObject:[NSNumber numberWithBool:YES]];
        }
    }
    
    [self.shredOperations setObject:suboperations forKey:element.resource];
    
    //NSLog(@"was added shred operation for resource : %@", element.resource);
}

- (void) startShredOperationForResource:(NSString*)resource
{
    NSMutableArray* suboperations = [self.shredOperations objectForKey:resource];
    
    if(suboperations)
    {
        if(suboperations.count)
        {
            int currOperations = 0;
            for (int i = 0; i < suboperations.count; ++i)
            {
                BOOL needShred = [[suboperations objectAtIndex:i]boolValue];
                if(needShred)
                {
                    currOperations ++;
                    
                    NSString* fullResource = [self.revision.contentDirectory stringByAppendingPathComponent:resource];
                    
                    [RueResourceShredder preparePieceAtIndex:i ofResource:fullResource completion:^(NSString *piecePath) {
                        
                        [self pieceCompletedAtIndex:i ofResource:resource];
                    }];
                    
                    //NSLog(@"was started shred operation %i for resource : %@", i, resource);
                }
            }
            if(currOperations == 0)
            {
                [self removeShredOperationForResorce:resource];
            }
        }
        else
        {
            [self removeShredOperationForResorce:resource];
        }
    }
}

- (void) pieceCompletedAtIndex:(int)index ofResource:(NSString*)resource
{
    NSMutableArray* suboperations = [self.shredOperations objectForKey:resource];
    if(suboperations && suboperations.count > index)
    {
        [suboperations replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];
    }
}

- (void) removeShredOperationForResorce:(NSString*)resource
{
    [self.shredOperations removeObjectForKey:resource];
    //NSLog(@"was removed shred operation for resource : %@", resource);
}

- (int) shredOperationsCount
{
    __block int count = 0;
    
    if(self.shredOperations && self.shredOperations.count)
    {
        [self.shredOperations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            int suboperationsCount = 0;
            NSMutableArray* suboperations = obj;
            
            for (NSNumber* suboperation in suboperations)
            {
                BOOL exists = [suboperation boolValue];
                
                if(exists)
                {
                    suboperationsCount ++;
                }
            }
            count += suboperationsCount;
        }];
    }
    
    return count;
}

- (int) currentOperationsCount
{
    int count = [super currentOperationsCount];
    count += [self shredOperationsCount];
    return count;
}

@end
