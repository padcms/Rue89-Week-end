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

+ (id) schemeWithIdentifier:(NSString*)identifier days:(int)days
{
    SubscriptionScheme * scheme = [[SubscriptionScheme alloc]initWithIdentifier:identifier];
    scheme.days = days;
    return scheme;
}

- (id) initWithDictionary:(NSDictionary*)dictionary
{
    NSString* identifier = [dictionary objectForKey:@"itunes_id"];
    if(identifier && [identifier isKindOfClass:[NSString class]] && identifier.length)
    {
        self = [super init];
        if(self)
        {
            _identifier = identifier;
            
            NSString* title = [dictionary objectForKey:@"button_title"];
            if(title && [title isKindOfClass:[NSString class]] && title.length)
            {
                _title = title;
            }
            else
            {
                title = identifier;
            }
            
            _days = days_from_identifier(identifier);
        }
        return self;
    }
    else
    {
        return nil;
    }
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

int days_from_identifier(NSString* identifier)
{
    NSArray* strings = [identifier componentsSeparatedByString:@"."];
    
    NSString* durationString = [strings lastObject];
    if(durationString && durationString.length)
    {
        if([durationString isEqualToString:@"7days"])
        {
            return 7;
        }
        if([durationString isEqualToString:@"1month"])
        {
            return 30;
        }
        if([durationString isEqualToString:@"3month"])
        {
            return 90;
        }
        if([durationString isEqualToString:@"6month"])
        {
            return 180;
        }
        if([durationString isEqualToString:@"oneyear"])
        {
            return 360;
        }
    }
    return 0;
}

@end
