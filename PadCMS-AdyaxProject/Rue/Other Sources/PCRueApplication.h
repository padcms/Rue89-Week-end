//
//  PCRueApplication.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/2/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCApplication.h"

#define PCGoogleNotificationType @"google"
#define PCApplicationContactUsSubjectKey @"subject"

@interface PCRueApplication : PCApplication

@property (nonatomic, strong) NSString  *shareUrl;

@property (nonatomic, strong) NSString *subscribeButtonTitle;
@property (nonatomic, strong) NSString *subscriptionsListTitle;

@property (nonatomic, strong, readonly) NSArray *subscriptionsSchemes;

@property (nonatomic, strong) NSString *wellcomeMessage;
@property (nonatomic, strong) NSString *welcomeMessageUnderButton;

@property (nonatomic, strong) NSString *contactEmail;
@property (nonatomic, strong) NSString *contactEmailText;
@property (nonatomic, strong) NSString *contactEmailSubject;

/// @brief All tags collected from all issues
@property (nonatomic, strong) NSMutableArray *tags;

/// @brief Message that appears in bottom popup
@property (nonatomic, strong) NSString *messageForReaders;
/// @brief Message that will appear on sharing popup
@property (nonatomic, strong) NSString *shareMessage;

@property (nonatomic, strong) NSString *emailShareMessage;
@property (nonatomic, strong) NSString *emailShareTitle;

@end
