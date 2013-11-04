//
//  SubscriptionScheme.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/1/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "SubscriptionScheme.h"
#import <StoreKit/StoreKit.h>

@interface SubscriptionScheme ()
{
    NSString* _identifier;
}
@end

@implementation SubscriptionScheme

+ (id) schemeWithIdentifier:(NSString*)identifier
{
    return [[SubscriptionScheme alloc]initWithIdentifier:identifier];
}

- (id) initWithIdentifier:(NSString*)identifier
{
    self = [super init];
    if(self)
    {
        _identifier = identifier;
    }
    return self;
}

- (NSString*) identifier
{
    return _identifier;
}

- (NSString*) description
{
    NSString* descr = [super description];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    [dict setObject:_identifier forKey:@"identifier"];
    
    descr = [descr stringByAppendingString:dict.debugDescription];
    
    return descr;
}

- (BOOL) isIncludedIntoPurchasableObjects:(NSArray*)objects
{
    for (SKProduct* product in objects)
    {
        if([product.productIdentifier isEqualToString:self.identifier])
        {
            return YES;
        }
    }
    return NO;
}

@end
