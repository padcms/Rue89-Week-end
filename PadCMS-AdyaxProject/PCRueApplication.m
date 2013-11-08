//
//  PCRueApplication.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/2/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueApplication.h"
#import "PCJSONKeys.h"
#import "NSString+HTML.h"

#define GOOGLE_MESSAGE_KEY @"application_notification_google"
#define SHARE_URL_KEY @"application_share_url"

#define kApplicationSubscribeButtonKey @"application_subscribe_button"
#define kApplicationSubscribeTitleKey @"application_subscribe_title"

@implementation PCRueApplication

- (id)initWithParameters:(NSDictionary *)parameters
           rootDirectory:(NSString *)rootDirectory
              backEndURL:(NSURL *)backEndURL
{
    self = [super initWithParameters:parameters rootDirectory:rootDirectory backEndURL:backEndURL];
    if(self)
    {
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
        
        self.messageForReaders = [[[parameters objectForKey:PCJSONApplicationMessageForReadersKey]stringByDecodingHTMLEntities] copy];
        
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
        
    }
    return self;
}

@end
