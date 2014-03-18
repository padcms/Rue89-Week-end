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

@property (nonatomic, copy) NSString* shareUrl;

@property (nonatomic, copy) NSString* subscribeButtonTitle;
@property (nonatomic, copy) NSString* subscriptionsListTitle;

@property (nonatomic, readonly) NSArray* subscriptionsSchemes;

@property (nonatomic, copy) NSString* wellcomeMessage;
@property (nonatomic, copy) NSString * welcomeMessageUnderButton;

@property (nonatomic, retain) NSString * contactEmail;
@property (nonatomic, copy) NSString * contactEmailText;
@property (nonatomic, copy) NSString * contactEmailSubject;

/// @brief All tags collected from all issues
@property (nonatomic, retain) NSMutableArray * tags;

/// @brief Message that appears in bottom popup
@property (nonatomic, retain) NSString * messageForReaders;
/// @brief Message that will appear on sharing popup
@property (nonatomic, retain) NSString * shareMessage;

@property (nonatomic, strong) NSString *emailShareMessage;
@property (nonatomic, strong) NSString *emailShareTitle;

@end
