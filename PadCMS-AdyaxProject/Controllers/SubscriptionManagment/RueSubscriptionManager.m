//
//  RueSubscriptionManager.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueSubscriptionManager.h"
#import "PCKioskSubscribeButton.h"
#import "PCIssue.h"
#import "SubscriptionScheme.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsFetched:) name:kProductFetchedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscriptionsPurchased:) name:kSubscriptionsPurchasedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscriptionsInvalid:) name:kSubscriptionsInvalidNotification object:nil];
        
        [[MKStoreManager sharedManager] setDataSource:self];
    }
    return self;
}

- (NSArray*) predefinedSubscriptions
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
    NSLog(@"subscr products : %@", [[MKStoreManager sharedManager]subscriptionProducts].description);
    NSLog(@"purchasable objects : %@ , %@", [[MKStoreManager sharedManager]purchasableObjects].description, [[MKStoreManager sharedManager]purchasableObjectsDescription].debugDescription);
    NSLog(@"IS %@ SUBSCRIBED: %d", featureId, [[MKStoreManager sharedManager] isSubscriptionActive:featureId]);
    
    
    if ([[MKStoreManager sharedManager] isSubscriptionActive:featureId] == NO)
    {
        [[MKStoreManager sharedManager] buyFeature:featureId onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
            
            NSLog(@"Purchase completed.");
            
            if(completion) completion(nil);
            
        } onCancelled:^(NSError* error){
            
            NSLog(@"Purchase cancelled.");
            if(error == nil)
            {
                error = [NSError errorWithDomain:@"SubscribtionManager" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Subscription cancelled."}];
            }
            completion(error);
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

- (void) purchaseRevision:(PCRevision*)revision completion:(void(^)(NSError*))completion
{
    [[MKStoreManager sharedManager] buyFeature:revision.issue.productIdentifier onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
        
        NSLog(@"Successfully bought product with id %@!", revision.issue.productIdentifier);
        
        if(completion) completion(nil);
        
    } onCancelled:^(NSError* error){
        
        if(completion) completion(error);
        NSLog(@"Failed to buy product with id %@!", revision.issue.productIdentifier);
    }];
}

- (void) restorePurchasesCompletion:(void (^)(NSError *error))completion
{
    _isRestoringPurchases = YES;
    [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{
        
        _isRestoringPurchases = NO;
        if(completion) completion(nil);
        
    } onError:^(NSError *error) {
        
        _isRestoringPurchases = NO;
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

- (void) subscriptionsInvalid:(NSNotification *)notification
{
    NSLog(@"subscriptions invalid : %@", notification.description);
}

- (void)productsFetched:(NSNotification *)notification
{
    NSLog(@"product fetched : %@", notification);
    NSLog(@"purchasable objects : %@, %@", [[MKStoreManager sharedManager]purchasableObjects].description, [[MKStoreManager sharedManager]purchasableObjectsDescription].debugDescription);
    NSLog(@"subscription products : %@", [[MKStoreManager sharedManager]subscriptionProducts].description);
    
    [self checkForActiveSubscriptionAndNotifyDelegate];
}

- (void)subscriptionsPurchased:(NSNotification *)notification
{
    NSLog(@"subscriptions purchased : %@", notification);

    [self checkForActiveSubscriptionAndNotifyDelegate];
}

- (SubscriptionScheme*) checkForActiveSubscription
{
    SubscriptionScheme* activeScheme = nil;
    
    NSArray* allSubscriptions = [self predefinedSubscriptions];
    
    for (SubscriptionScheme* scheme in allSubscriptions)
    {
        if([[MKStoreManager sharedManager] isSubscriptionActive: scheme.identifier])
        {
            activeScheme = scheme;
        }
    }
    
    return activeScheme;
}

- (void) checkForActiveSubscriptionAndNotifyDelegate
{
    SubscriptionScheme* activeScheme = [self checkForActiveSubscription];
    
    if(activeScheme)
    {
        NSLog(@"Subscription is active : %@", activeScheme.identifier);
        
        if([self.delegate respondsToSelector:@selector(subscriptionIsActive:)])
        {
            [self.delegate subscriptionIsActive:activeScheme];
        }
    }
}

@end
