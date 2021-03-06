//
//  RueSubscriptionManager+MKStoreManagerDataSource.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/4/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueSubscriptionManager.h"
#import "SubscriptionScheme.h"
#import "PCIssue.h"

@implementation RueSubscriptionManager (MKStoreManagerDataSource)

- (void) getAvalialeSubscriptionsToBlock:(void(^)(NSArray* avaliableSubscriptions, NSError* error))completionBlock
{
    NSArray* existingPurchasebleObjects = [MKStoreManager sharedManager].purchasableObjects;
    
    if(existingPurchasebleObjects && existingPurchasebleObjects.count)
    {
        if(completionBlock)
        {
            
            completionBlock([self subscriptionsFromPurchasableObjects:existingPurchasebleObjects], nil);
        }
        else
        {
            NSException* ex = [NSException exceptionWithName:@"NilArgument" reason:@"Parametr \"completionBlock\" must by specified." userInfo:nil];
            [ex raise];
        }
    }
    else
    {
        void(^loadingProductComplete)(NSArray*) = ^(NSArray* purchasableObjects){
            
            if(completionBlock)
            {
                self.isSubscribing = NO;
                completionBlock([self subscriptionsFromPurchasableObjects:existingPurchasebleObjects], nil);
            }
            else
            {
                NSException* ex = [NSException exceptionWithName:@"NilArgument" reason:@"Parametr \"completionBlock\" must by specified." userInfo:nil];
                [ex raise];
            }
        };
        
        void(^loadinProductsFailed)(NSError*) = ^(NSError* error){
            
            if(completionBlock)
            {
                self.isSubscribing = NO;
                completionBlock(nil, error);
            }
            else
            {
                NSException* ex = [NSException exceptionWithName:@"NilArgument" reason:@"Parametr \"completionBlock\" must by specified." userInfo:nil];
                [ex raise];
            }
        };
        
        self.isSubscribing = YES;
        MKStoreManager* storeManager = [MKStoreManager sharedManager];
        if(storeManager.isLoadindProducts)
        {
            storeManager.completeLoadProductDataHendler = loadingProductComplete;
            storeManager.failLoadProductDataHendler = loadinProductsFailed;
        }
        else
        {
            [self updateProductsDataInStoreManager:storeManager onComplete:loadingProductComplete onError:loadinProductsFailed];
        }
    }
}

- (NSArray*) subscriptionsFromPurchasableObjects:(NSArray*)objects
{
    NSArray* predefinedSubscriptions = [self predefinedSubscriptions];
    
    NSMutableArray* avaliableSubscriptions = [[NSMutableArray alloc]init];
    for (SubscriptionScheme* scheme in predefinedSubscriptions)
    {
        if([scheme isIncludedIntoPurchasableObjects:objects])
        {
            [avaliableSubscriptions addObject:scheme];
        }
    }
    return [NSArray arrayWithArray:avaliableSubscriptions];
}

- (void) updateProductsDataInStoreManager:(MKStoreManager*)storeManager onComplete:(void(^)(NSArray* purchasableObjects))completionBlock onError:(void(^)(NSError*))errorBlock
{
    storeManager.completeLoadProductDataHendler = completionBlock;
    storeManager.failLoadProductDataHendler = errorBlock;
    
    storeManager.dataSource = self;
}

#pragma mark - MKStoreManagerDataSource

- (NSArray*) predefinedSubscriptions
{
    return [self.delegate subscriptionSchemes];
}

- (NSArray *)serverProductIdsForMKStoreManager:(MKStoreManager *)manager
{
    NSMutableArray * allIdentifiers = [NSMutableArray new];
    
    [allIdentifiers addObjectsFromArray:[self productIdsFromAllIssues]];
    
    [allIdentifiers addObjectsFromArray:[self productIdsFromPredefinedSubscriptions]];
    
    return [NSArray arrayWithArray:allIdentifiers];
}

- (NSArray*) productIdsFromAllIssues
{
    NSMutableArray * allIdentifiers = [NSMutableArray new];
    
    NSArray * issues = [self.delegate allIssues];
    
    for (PCIssue * issue in issues)
    {
        if (issue.productIdentifier.length > 0)
        {
            [allIdentifiers addObject:issue.productIdentifier];
        }
    }
    return [NSArray arrayWithArray:allIdentifiers];
}

- (NSArray*) productIdsFromPredefinedSubscriptions
{
    NSMutableArray * allIdentifiers = [NSMutableArray new];
    
    NSArray* subscriptions = [self predefinedSubscriptions];
    
    for (SubscriptionScheme* scheme in subscriptions)
    {
        [allIdentifiers addObject:scheme.identifier];
    }
    return [NSArray arrayWithArray:allIdentifiers];
}

@end
