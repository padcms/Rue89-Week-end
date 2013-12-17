//
//  SubscriptionScheme.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/1/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubscriptionScheme : NSObject

+ (id) schemeWithIdentifier:(NSString*)identifier;
+ (id) schemeWithIdentifier:(NSString*)identifier days:(int)days;

@property (nonatomic, assign) int days;
@property (nonatomic, readonly) NSString* title;

- (id) initWithIdentifier:(NSString*)identifier;

- (id) initWithDictionary:(NSDictionary*)dictionary;

- (NSString*) identifier;

- (BOOL) isIncludedIntoPurchasableObjects:(NSArray*)objects;

@end
