//
//  PCJSONKeys+iTunesKey.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/13/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCJSONKeys.h"

NSString* PCJSONApplicationContactEmailKey                 = @"application_email";
NSString* PCJSONIssuePublishDateKey                        = @"issue_publish_date";
NSString* PCJSONIssueTitleShortKey                         = @"issue_title_short";

@interface PCJSONKeys : NSObject
@end

@implementation PCJSONKeys

+ (void) load
{
    PCJSONIssueProductIDKey     = @"issue_itunes_id";
    PCJSONIssueShortIntroKey    = @"issue_excerpt_short";
    PCJSONIssueShortIntroKey    = @"issue_short_intro";
}

@end