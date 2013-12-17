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
NSString* PCJSONIssueShortIntroKey                         = @"issue_short_intro";

NSString* PCJSONIssueCategoryKey                           = @"issue_category";
NSString* PCJSONIssueTagsKey                               = @"tags";
NSString* PCJSONIssueTagTitleKey                           = @"title";
NSString* PCJSONIssueTagIdKey                              = @"id";

NSString* PCJSONApplicationMessageForReadersKey            = @"application_message_for_readers";
NSString* PCJSONApplicationShareMessageKey                 = @"application_share_message";

NSString* PCJSONIssueAuthorKey                             = @"issue_author";
NSString* PCJSONIssueExcerptKey                            = @"issue_excerpt";
NSString* PCJSONIssueImageLargeURLKey                      = @"issue_image_large";
NSString* PCJSONIssueImageSmallURLKey                      = @"issue_image_small";
NSString* PCJSONIssueWordsCountKey                         = @"issue_words";

@interface PCJSONKeys : NSObject
@end

@implementation PCJSONKeys

+ (void) load
{
    PCJSONIssueProductIDKey     = @"issue_itunes_id";
    PCJSONIssueShortIntroKey    = @"issue_excerpt_short";
}

@end