//
//  RueSubscriptionManager.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueSubscriptionManager.h"
#import "MKStoreManager.h"
#import "PCKioskSubscribeButton.h"
#import "PCIssue.h"
#import "SubscriptionScheme.h"

@interface RueSubscriptionManager () <MKStoreManagerDataSource>

@end

@implementation RueSubscriptionManager

static RueSubscriptionManager* _sharedManager = nil;

+ (RueSubscriptionManager*) sharedManager
{
    if(_sharedManager == nil)
    {
        _sharedManager = [[self alloc]init];
    }
    return _sharedManager;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        [[MKStoreManager sharedManager] setDataSource:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsFetched:) name:kProductFetchedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscriptionsPurchased:) name:kSubscriptionsPurchasedNotification object:nil];
        
    }
    return self;
}

- (NSArray*) avaliableSubscriptions
{
    return @[[SubscriptionScheme schemeWithIdentifier:@"com.mobile.rue89.3months"],
             [SubscriptionScheme schemeWithIdentifier:@"com.mobile.rue89.1months"],
             [SubscriptionScheme schemeWithIdentifier:@"com.mobile.rue89.6months"],
             [SubscriptionScheme schemeWithIdentifier:@"com.mobile.rue89.666months"]];
}

- (void) subscribeForScheme:(SubscriptionScheme*)subscrScheme completion:(void(^)(NSError* error))completion
{
    //NSString * featureId = [[PCConfig subscriptions] lastObject];
    NSString * featureId = subscrScheme.identifier;
    
    NSLog(@"IS %@ PURCHASED: %d", featureId, [MKStoreManager isFeaturePurchased:featureId]);
    
    NSLog(@"IS %@ SUBSCRIBED: %d", featureId, [[MKStoreManager sharedManager] isSubscriptionActive:featureId]);
    
#warning harcode
    featureId = @"com.mobile.rue89.3months";
    
    if ([[MKStoreManager sharedManager] isSubscriptionActive:featureId] == NO)
    {
        [[MKStoreManager sharedManager] buyFeature:featureId onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
            
            NSLog(@"Purchase completed.");
            
            if(completion) completion(nil);
            
        } onCancelled:^{
            
            NSLog(@"Purchase cancelled.");
            
        }];
    }
    else
    {
        if(completion)
        {
            NSError* error = [NSError errorWithDomain:@"SubscribtionManager" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Subscription is already active"}];
            completion(error);
        }
    }
}

- (void) purchaseRevision:(PCRevision*)revision completion:(void(^)())completion
{
    [[MKStoreManager sharedManager] buyFeature:revision.issue.productIdentifier onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
        
        NSLog(@"Successfully bought product with id %@!", revision.issue.productIdentifier);
        
        if(completion) completion();
        
    } onCancelled:^{
        
        NSLog(@"Failed to buy product with id %@!", revision.issue.productIdentifier);
    }];
}

- (void) restorePurchasesCompletion:(void (^)(NSError *error))completion
{
    [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{
        
        if(completion) completion(nil);
        
    } onError:^(NSError *error) {
        
        if(completion) completion(error);
    }];
}

- (BOOL) isRevisionPaid:(PCRevision*)revision
{
    if (revision.issue)
    {
        
        //BOOL isIssuePaid = revision.issue.paid;
        
        BOOL isIssuePaid = NO;
        if (revision.issue.productIdentifier.length < 1) {
            isIssuePaid = YES;
        } else {
            isIssuePaid = [MKStoreManager isFeaturePurchased:revision.issue.productIdentifier];
        }
        
        
#warning Check here for individual payment
        
#warning HARDCODE!
        BOOL isRevisionIndividuallyPaid = NO;
#warning HARDCODE!
        
        if (isRevisionIndividuallyPaid) {
            return  isIssuePaid;
        }
        
        //REturn that PAID when we are already subscribed to whole magazine
        
        NSString * featureId = [[PCConfig subscriptions] lastObject];
        BOOL subscriptionActive = [[MKStoreManager sharedManager] isSubscriptionActive:featureId];
        
        if (subscriptionActive) {
            return YES;
        }
        
        return isIssuePaid;
    }
    
    return NO;
}

#pragma mark - Notifications

- (void)productsFetched:(NSNotification *)notification
{
    NSLog(@"product fetched : %@", notification);
    
//
//    NSString * featureId = [[PCConfig subscriptions] lastObject];
//
//    BOOL isSubscriptionActive = [[MKStoreManager sharedManager] isSubscriptionActive:featureId];
//
//    NSLog(@"IS SUBSCRIBED productsFetched: %d", isSubscriptionActive);
//
//    self.kioskHeaderView.subscribeButton.isSubscribedState = isSubscriptionActive;
}

- (void)subscriptionsPurchased:(NSNotification *)notification
{
    NSLog(@"subscriptions purchased : %@", notification);
    
    
//    NSString * featureId = [[PCConfig subscriptions] lastObject];
//
//    BOOL isSubscriptionActive = [[MKStoreManager sharedManager] isSubscriptionActive:featureId];
//
//    NSLog(@"IS SUBSCRIBED subscriptionsPurchasedNotification: %d", isSubscriptionActive);
//
//    self.kioskHeaderView.subscribeButton.isSubscribedState = isSubscriptionActive;
}

#pragma mark - MKStoreManagerDataSource

- (NSArray *)serverProductIdsForMKStoreManager:(MKStoreManager *)manager
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

@end
