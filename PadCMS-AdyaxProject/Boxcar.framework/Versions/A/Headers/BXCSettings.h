//
//  BXCSettings.h
//
//  Copyright (c) 2012-2013 ProcessOne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BXCSettings : NSObject <NSCoding>

@property(nonatomic, copy) NSString *dataVersion;
@property(nonatomic, copy) NSString *deviceToken;
@property(nonatomic, copy) NSString *alias;
@property(nonatomic, copy) NSString *udid;
@property(nonatomic, copy) NSString *mode;
@property(nonatomic, copy) NSString *appVersion;
@property(nonatomic, copy) NSString *osVersion;
@property(nonatomic)       BOOL pushState;
@property(nonatomic, copy) NSArray *tags;
@property(nonatomic)       BOOL needUpdate;
@property(nonatomic, copy) NSDate *lastServerUpdate;

- (BOOL) tryUpdate;
- (void) updatePushState;

@end
