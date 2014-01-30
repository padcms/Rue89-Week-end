//
//  RueFacebookController
//  padCMS
//
//  Created by Martyniuk.M on 10/16/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RueFacebookController : NSObject

/**
 @brief Post message on Facebook wall with embedded system instruments.
 @availability iOS (6.0 and later)
 */
+ (void) postEmbeddedText:(NSString*)postText url:(NSURL*)postUrl image:(UIImage*)postImage inController:(UIViewController*)controller completionHandler:(void(^)(BOOL success, NSError* error))completionBlock;

/**
 @brief Return YES if can post via system instruments.
 @return YES if is ability to post to Facebook via system embedded instruments, otherwise NO.
 */
+ (BOOL) canPostEmbedded;

/**
 @brief Show or not post conformation view. Default is YES.
 */
@property (nonatomic, assign) BOOL needToConfirmPost;

- (id) initWithMessage:(NSString*)message url:(NSURL*)url;
- (id) initWithMessage:(NSString*)message url:(NSURL*)url pictureLink:(NSURL*)pictureLink;
- (id) initWithMessage:(NSString*)message url:(NSURL*)url pictureLink:(NSURL*)pictureLink description:(NSString*)description;

/**
 @brief Post message to Facebook wall.
 @param authorizeDialog calls with UIWebView that presents authorization page
 @param confirmPostBlock calls when authorization successful with authorizationView which is the same as in authorizeDialog and confirmPostView that is IUView with post details for conformation by user.
 @param postCompleteBlock calls when post request is complete. If post successful error is nil and postView is previous presented view (if needToConfirmPost is YES then view is the same as confirmPostView in confirmPostBlock, else dialogView in authorizeDialog).
 @warning confirmPostBlock is not calling if needToConfirmPost is NO.
 */
- (void) shareWithDialog:(void(^)(UIView*dialogView))authorizeDialog authorizationComplete:(void (^)(UIView *authorizationView, UIView* confirmPostView))confirmPostBlock postComplete:(void (^)(UIView *postView, NSError* postError))postCompleteBlock;

@end
