//
//  RueSubscriptionManager.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCRevision, PCKioskSubscribeButton;

@protocol RueSubscriptionManagerDelegate <NSObject>

- (NSArray*) allIssues;

@end


@interface RueSubscriptionManager : NSObject

+ (RueSubscriptionManager*) sharedManager;

@property (nonatomic, assign) id<RueSubscriptionManagerDelegate> delegate;

- (NSArray*) avaliableSubscriptions;

- (void) subscribeCompletion:(void(^)(NSError* error))completion;

- (void) purchaseRevision:(PCRevision*)revision completion:(void(^)())completion;

- (void) restorePurchasesCompletion:(void(^)(NSError *error))completion;

- (BOOL) isRevisionPaid:(PCRevision*)revision;


@end
