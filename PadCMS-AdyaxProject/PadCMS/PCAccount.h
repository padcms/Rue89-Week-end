//
//  PCAccount.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCUserInfo;

/**
 @brief Enumeration of states describing PCAccount 
 */
typedef enum
{
    PCAccountStateInvalid = -1,
    PCAccountStateNotConnected = 0,
    PCAccountStateConnected = 1,
    PCAccountStateError = 2,
    
} PCAccountState;


/**
 @brief class for loading account data from server
 */
@interface PCAccount : NSObject

/**
 @brief current instance state
 */
@property (readonly) PCAccountState state;

/**
 @brief current user name, nil if current instance is not logged in
 */
@property (readonly) NSString *userName;

/**
 @brief current password, nil if current instance is not logged in
 */
@property (readonly) NSString *password;

/**
 @brief current back end server address, nil if current instance is not logged in
 */
@property (readonly) NSString *serverAddress;

/**
 @brief applications list, nil if current instance is not logged in
 */
@property (readonly) NSArray *applications;

/**
 @brief information about user logged in, nil if instance is not logged in
 */
@property (readonly) PCUserInfo *userInfo;

/**
 @brief try to log in with supplied credentials and server address
 @param userName - user name
 @param password - password
 @param serverAddress - back end server address
 */
- (void)logInWithUserName:(NSString *)userName password:(NSString *)password 
serverAddress:(NSString *)serverAddress;

/**
 @brief log out current instance
 */
- (void)logOut;

@end
