//
//  RueSubscriptionManager.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCRevision, PCKioskSubscribeButton, SubscriptionScheme;

@protocol RueSubscriptionManagerDelegate <NSObject>

- (NSArray*) allIssues;

@end


@interface RueSubscriptionManager : NSObject

+ (RueSubscriptionManager*) sharedManager;

@property (nonatomic, weak) id<RueSubscriptionManagerDelegate> delegate;

- (NSArray*) avaliableSubscriptions;

- (void) subscribeForScheme:(SubscriptionScheme*)subscrScheme completion:(void(^)(NSError* error))completion;

- (void) purchaseRevision:(PCRevision*)revision completion:(void(^)())completion;

- (void) restorePurchasesCompletion:(void(^)(NSError *error))completion;

- (BOOL) isRevisionPaid:(PCRevision*)revision;


@end
