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
    }
    return self;
}

- (void) setDelegate:(id<RueSubscriptionManagerDelegate>)delegate
{
    if(_delegate != delegate && delegate != nil)
    {
        _delegate = delegate;
        [[MKStoreManager sharedManager] setDataSource:self];
    }
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
        _isSubscribing = YES;
        
        [[MKStoreManager sharedManager] buyFeature:featureId onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
            
            NSLog(@"Purchase completed.");
            _isSubscribing = NO;
            
            if(completion) completion(nil);
            
        } onCancelled:^(NSError* error){
            
            _isSubscribing = NO;
            NSLog(@"Purchase cancelled.");
            if(error == nil)
            {
                error = [NSError errorWithDomain:@"SubscribtionManager" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Subscription cancelled."}];
            }
            completion(error);
            [self checkForActiveSubscriptionAndNotifyDelegate];
        }];
    }
    else
    {
        if(completion)
        {
            NSError* error = [NSError errorWithDomain:@"SubscribtionManager" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Subscription is already active"}];
            completion(error);
            [self checkForActiveSubscriptionAndNotifyDelegate];
        }
    }
}

- (void) purchaseRevision:(PCRevision*)revision completion:(void(^)(NSError*))completion
{
    _isPurchasingRevision = YES;
    
    void(^buyFeature)() = ^{
        
        [[MKStoreManager sharedManager] buyFeature:revision.issue.productIdentifier onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
            
            NSLog(@"Successfully bought product with id %@!", revision.issue.productIdentifier);
            _isPurchasingRevision = NO;
            if(completion) completion(nil);
            
        } onCancelled:^(NSError* error){
            
            _isPurchasingRevision = NO;
            if(completion) completion(error);
            NSLog(@"Failed to buy product with id %@!", revision.issue.productIdentifier);
        }];
    };
    
    NSArray* avaliableObjects = [MKStoreManager sharedManager].purchasableObjects;
    if(avaliableObjects && avaliableObjects.count)
    {
        buyFeature();
    }
    else
    {
        [self updateProductsDataInStoreManager:[MKStoreManager sharedManager] onComplete:^(NSArray *purchasableObjects) {
            
            buyFeature();
            
        } onError:^(NSError *error) {
            
            _isPurchasingRevision = NO;
            if(completion) completion(error);
            NSLog(@"Failed to buy product with id %@!", revision.issue.productIdentifier);
        }];
    }
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
    if (revision.issue && revision.issue.productIdentifier && revision.issue.productIdentifier.length)
    {
        return [MKStoreManager isFeaturePurchased:revision.issue.productIdentifier];
    }
    else
    {
        return NO;
    }
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

- (BOOL) isSubscribed
{
    if([self checkForActiveSubscription])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
