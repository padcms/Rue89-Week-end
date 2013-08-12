//
//  PCUserInfo.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/2/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 @brief class for storing information about user
 */
@interface PCUserInfo : NSObject

/**
 @brief user's first name
 */
@property (copy, nonatomic) NSString *firstName;

/**
 @brief user's last name
 */
@property (copy, nonatomic) NSString *lastName;

/**
 @brief user's login
 */
@property (copy, nonatomic) NSString *login;

/**
 @brief user's email address
 */
@property (copy, nonatomic) NSString *email;

@end
