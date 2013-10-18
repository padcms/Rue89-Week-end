//
//  RueFacebookController
//  padCMS
//
//  Created by Martyniuk.M on 10/16/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RueFacebookController : NSObject

+ (void) postEmbeddedText:(NSString*)postText url:(NSURL*)postUrl image:(UIImage*)postImage inController:(UIViewController*)controller completionHandler:(void(^)(BOOL success, NSError* error))completionBlock;

+ (BOOL) canPostEmbedded;

@property (nonatomic, assign) BOOL needToConfirmPost; //default is YES

- (id) initWithMessage:(NSString*)message url:(NSURL*)url;

- (void) shareWithDialog:(void(^)(UIView*dialogView))authorizeDialog authorizationComplete:(void (^)(UIView *authorizationView, UIView* confirmPostView))confirmPostBlock postComplete:(void (^)(UIView *postView, NSError* postError))postCompleteBlock;

@end
