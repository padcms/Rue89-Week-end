//
//  PCJSONKeys+iTunesKey.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/13/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCJSONKeys.h"

//NSString* PCJSONIssueProductIDKey = @"issue_itunes_id";

@interface PCJSONKeys : NSObject
@end

@implementation PCJSONKeys

+ (void) load
{
    PCJSONIssueProductIDKey = @"issue_itunes_id";
}

@end