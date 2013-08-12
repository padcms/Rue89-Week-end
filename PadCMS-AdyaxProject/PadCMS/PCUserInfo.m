//
//  PCUserInfo.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/2/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCUserInfo.h"

@implementation PCUserInfo

@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize login = _login;
@synthesize email = _email;

- (void)dealloc
{
    [_firstName release];
    [_lastName release];
    [_login release];
    [_email release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        _firstName = nil;
        _lastName = nil;
        _login = nil;
        _email = nil;
    }
    
    return self;
}

@end
