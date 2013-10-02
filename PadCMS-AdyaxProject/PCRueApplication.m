//
//  PCRueApplication.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/2/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueApplication.h"

#define GOOGLE_MESSAGE_KEY @"application_notification_google"

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
    }
    return self;
}

@end
