//
//  PCRueApplication.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/2/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueApplication.h"
#import "PCJSONKeys.h"
#import "PCConfig.h"
#import "PCPathHelper.h"
#import "NSString+HTML.h"
#import "RueIssue.h"
#import "PCTag.h"
#import "SubscriptionScheme.h"

#define GOOGLE_MESSAGE_KEY @"application_notification_google"
#define SHARE_URL_KEY @"application_share_url"

#define kApplicationSubscribeButtonKey @"application_subscribe_button"
#define kApplicationSubscribeTitleKey @"application_subscribe_title"
#define kApplicationWellcomeMessageKey @"application_welcome_message"
#define kApplicationWellcomeMessagePart2Key @"application_welcome_message_part2"

#define kApplicationContactEmailTextKey @"application_contact_email_text"
#define kApplicationContactEmailSubjectKey @"application_contact_email_subject"

@implementation PCRueApplication

- (id)initWithParameters:(NSDictionary *)parameters
           rootDirectory:(NSString *)rootDirectory
              backEndURL:(NSURL *)backEndURL
{
    if (parameters == nil) {
        return nil;
    }
    
    self = [super init];
    
    if (self != nil)
    {
        // Set up application parameters
        
        NSString *identifierString = [parameters objectForKey:PCJSONApplicationIDKey];
        
        if (backEndURL != nil)
        {
            self.backEndURL = backEndURL;
        }
        else
        {
            self.backEndURL = [PCConfig serverURL];
        }
        
        self.contentDirectory = [[rootDirectory stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"application-%@", identifierString]] copy];
        
        [PCPathHelper createDirectoryIfNotExists:self.contentDirectory];
        
        self.identifier = [identifierString integerValue];
        
        self.title = [parameters objectForKey:PCJSONApplicationTitleKey];
        self.applicationDescription = [parameters objectForKey:PCJSONApplicationDescriptionKey];
        self.productIdentifier = [parameters objectForKey:PCJSONApplicationProductIDKey];
        self.messageForReaders = [NSString stringWithFormat:@"%@", [parameters objectForKey:PCJSONApplicationMessageForReadersKey]];
        self.shareMessage = [NSString stringWithFormat:@"%@", [parameters objectForKey:PCJSONApplicationShareMessageKey]];
        self.contactEmail = [NSString stringWithFormat:@"%@", [parameters objectForKey:PCJSONApplicationContactEmailKey]];
        // Set up notifications
        if(self.notifications == nil)
        {
            self.notifications = [[NSMutableDictionary alloc] init];
        }
        
        if ([parameters objectForKey:PCJSONApplicationNotificationEmailKey]
            && [parameters objectForKey:PCJSONApplicationNotificationEmailTitleKey])
        {
            NSString *emailKey = [parameters objectForKey:PCJSONApplicationNotificationEmailKey];
            NSString *emailTitle = [parameters objectForKey:PCJSONApplicationNotificationEmailTitleKey];
            NSDictionary *emailNotificationType = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   emailKey, PCApplicationNotificationMessageKey,
                                                   emailTitle, PCApplicationNotificationTitleKey,
                                                   nil];
            self.emailShareMessage = emailKey;
            self.emailShareTitle = emailTitle;
            
            [self.notifications setObject:emailNotificationType forKey:PCEmailNotificationType];
        }
        
//        if ([parameters objectForKey:PCJSONApplicationNotificationTwitterKey])
//        {
//            NSString *twitterKey = [parameters objectForKey:PCJSONApplicationNotificationTwitterKey];
//            NSDictionary *twitterNotificationType = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                     twitterKey, PCApplicationNotificationMessageKey,
//                                                     nil];
//            
//            [self.notifications setObject:twitterNotificationType forKey:PCTwitterNotificationType];
//        }
//        
//        if ([parameters objectForKey:PCJSONApplicationNotificationFacebookKey])
//        {
//            NSString *facebookKey = [parameters objectForKey:PCJSONApplicationNotificationFacebookKey];
//            NSDictionary *facebookNotificationType = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                      facebookKey, PCApplicationNotificationMessageKey,
//                                                      nil] ;
//            
//            [self.notifications setObject:facebookNotificationType forKey:PCFacebookNotificationType];
//        }
        
        id previewObject = [parameters objectForKey:PCJSONApplicationPreviewKey];
        if (previewObject != nil)
        {
            self.previewColumnsNumber = [previewObject integerValue];
        }
        else
        {
            self.previewColumnsNumber = 0;
        }
        
        // Set up issues
        
        if(self.issues == nil)
        {
            self.issues = [[NSMutableArray alloc] init];
        }
            
        NSDictionary *issuesList = [parameters objectForKey:PCJSONIssuesKey];
        
        if (issuesList != nil && [issuesList count] != 0)
        {
            NSArray *keys = [issuesList allKeys];
            for (NSString* key in keys)
            {
                NSDictionary *issueParameters = [issuesList objectForKey:key];
                RueIssue *issue = [[RueIssue alloc] initWithParameters:issueParameters
                                                       rootDirectory:self.contentDirectory
                                                          backEndURL:self.backEndURL];
                if (issue != nil)
                {
                    [self.issues addObject:issue];
                }
                
                issue.application = self;
            }
        }
        
		[self.issues sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            PCIssue *issue1 = (PCIssue *)obj1;
            NSNumber *number1 = [NSNumber numberWithInteger:issue1.number.integerValue];
            PCIssue *issue2 = (PCIssue *)obj2;
            NSNumber *number2 = [NSNumber numberWithInteger:issue2.number.integerValue];
			return [number1 compare:number2];
		}];
        
        if(self.tags == nil)
        {
            self.tags = [NSMutableArray new];
        }
        
        NSArray* appTags = parameters[@"application_tags"];
        
        if(appTags && [appTags isKindOfClass:[NSArray class]] && appTags.count)
        {
            for (NSDictionary* tagDic in appTags)
            {
                BOOL exists = NO;
                
                PCTag* tag = [[PCTag alloc]initWithDictionary:tagDic];
                
                for (PCTag * addedTag in self.tags)
                {
                    if (addedTag.tagId == tag.tagId)
                    {
                        exists = YES;
                        break;
                    }
                }
                
                if (!exists)
                {
                    [self.tags addObject:tag];
                }
            }
        }
        else
        {
            for (RueIssue * issue in self.issues)
            {
                for (PCTag * tag in issue.tags)
                {
                    BOOL exists = NO;
                    for (PCTag * addedTag in self.tags)
                    {
                        if (addedTag.tagId == tag.tagId)
                        {
                            exists = YES;
                            break;
                        }
                    }
                    
                    if (!exists)
                    {
                        [self.tags addObject:tag];
                    }
                }
            }
        }
		
        //ADDITIONAL
        
        if ([parameters objectForKey:GOOGLE_MESSAGE_KEY])
        {
            NSString *googleMessage = [parameters objectForKey:GOOGLE_MESSAGE_KEY];
            NSDictionary *googleNotificationType = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    googleMessage, PCApplicationNotificationMessageKey,
                                                    nil] ;
            
            [self.notifications setObject:googleNotificationType forKey:PCGoogleNotificationType];
        }
        
        NSString* shareUrl = [parameters objectForKey:SHARE_URL_KEY];
        if(shareUrl != nil && [shareUrl isKindOfClass:[NSString class]] && shareUrl.length)
        {
            self.shareUrl = shareUrl;
        }
        else
        {
            self.shareUrl = @"http://weekend.rue89.com";
        }
        
        self.messageForReaders = [[parameters objectForKey:PCJSONApplicationMessageForReadersKey]stringByDecodingHTMLEntities];
        
        NSString* subscribeByttonTitle = [[parameters objectForKey:kApplicationSubscribeButtonKey]stringByDecodingHTMLEntities];
        if(subscribeByttonTitle && [subscribeByttonTitle isKindOfClass:[NSString class]] && subscribeByttonTitle.length)
        {
            self.subscribeButtonTitle = subscribeByttonTitle;
        }
        
        NSString* subscriptionListTitle = [[parameters objectForKey:kApplicationSubscribeTitleKey]stringByDecodingHTMLEntities];
        if(subscriptionListTitle && [subscriptionListTitle isKindOfClass:[NSString class]] && subscriptionListTitle.length)
        {
            self.subscriptionsListTitle = subscriptionListTitle;
        }
        else
        {
            self.subscriptionsListTitle = @"Choisissez votre formule d'abonnement. Les quinze premiers jours sont gratuits!";
        }
        
        self.wellcomeMessage = [[[parameters objectForKey:kApplicationWellcomeMessageKey] stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"] stringByDecodingHTMLEntities];
        self.welcomeMessageUnderButton = [[parameters objectForKey:kApplicationWellcomeMessagePart2Key]stringByDecodingHTMLEntities];
        
        self.contactEmailText = [parameters objectForKey:kApplicationContactEmailTextKey];
        self.contactEmailSubject = [parameters objectForKey:kApplicationContactEmailSubjectKey];
        
        
        //---------------------------------- Subscriptions --------------------------------------------------------
        NSMutableArray* schemes = [[NSMutableArray alloc]init];
        
        NSDictionary* schemesDictionary = [parameters objectForKey:@"application_subscriptions"];
        if(schemesDictionary && [schemesDictionary isKindOfClass:[NSDictionary class]] && schemesDictionary.count)
        {
            NSLog(@"%@", schemesDictionary);
            
            NSArray* keys = [schemesDictionary allKeys];
            keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                int first = [obj1 intValue];
                int second = [obj2 intValue];
                if(first > second)
                    return NSOrderedDescending;
                else if(first < second)
                    return NSOrderedAscending;
                else return NSOrderedSame;
            }];
            
            for (int i = 0; i < keys.count; ++i)
            {
                NSString* key = keys[i];
                NSDictionary* entyty = schemesDictionary[key];
                if(entyty && [entyty isKindOfClass:[NSDictionary class]] && entyty.count)
                {
                    SubscriptionScheme * aScheme = [[SubscriptionScheme alloc]initWithDictionary:entyty];
                    if(aScheme)
                    {
                        [schemes addObject:aScheme];
                    }
                }
            }
        }
        
        _subscriptionsSchemes = [NSArray arrayWithArray:schemes];
        //---------------------------------------------------------------------------------------------------------
    }
    return self;
}

@end
