//
//  PCRueApplication.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/2/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCApplication.h"

#define PCGoogleNotificationType @"google"

@interface PCRueApplication : PCApplication

@property (nonatomic, copy) NSString* shareUrl;

@property (nonatomic, copy) NSString* subscribeButtonTitle;
@property (nonatomic, copy) NSString* subscriptionsListTitle;

@property (nonatomic, readonly) NSArray* subscriptionsSchemes;

@property (nonatomic, copy) NSString* wellcomeMessage;

@end
