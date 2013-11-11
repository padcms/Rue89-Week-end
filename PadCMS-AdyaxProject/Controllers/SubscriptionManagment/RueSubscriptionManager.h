//
//  RueSubscriptionManager.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKStoreManager.h"

@class PCRevision, PCKioskSubscribeButton, SubscriptionScheme;

@protocol RueSubscriptionManagerDelegate <NSObject>

- (NSArray*) allIssues;

@optional
- (void) subscriptionIsActive:(SubscriptionScheme*)activeSubscriptionScheme;

@end


@interface RueSubscriptionManager : NSObject

+ (RueSubscriptionManager*) sharedManager;

@property (nonatomic, weak) id<RueSubscriptionManagerDelegate> delegate;

@property (nonatomic ,readonly) BOOL isSubscribed;

@property (nonatomic, readonly) BOOL isRestoringPurchases;
@property (nonatomic, readonly) BOOL isPurchasingRevision;

- (void) subscribeForScheme:(SubscriptionScheme*)subscrScheme completion:(void(^)(NSError* error))completion;

- (void) purchaseRevision:(PCRevision*)revision completion:(void(^)(NSError*))completion;

- (void) restorePurchasesCompletion:(void(^)(NSError *error))completion;

- (BOOL) isRevisionPaid:(PCRevision*)revision;


@end

@interface RueSubscriptionManager (MKStoreManagerDataSource) <MKStoreManagerDataSource>

- (void) getAvalialeSubscriptionsToBlock:(void(^)(NSArray* avaliableSubscriptions, NSError* error))completionBlock; //return those subscriptions from "predefinedSubscriptions" which come from iTunes

- (void) updateProductsDataInStoreManager:(MKStoreManager*)storeManager onComplete:(void(^)(NSArray* purchasableObjects))completionBlock onError:(void(^)(NSError*))errorBlock;

@end