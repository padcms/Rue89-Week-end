//
//  RuePadCMSCoder.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PadCMSCoder.h"

@interface RuePadCMSCoder : PadCMSCoder

+ (NSDictionary*) applicationParametersFromCuurentPlistContent;

- (BOOL) syncServerPlistDownloadWithPassword:(NSString*)password;

- (void) syncServerPlistDownloadAsynchronouslyWithPassword:(NSString*)password completion:(void(^)(NSError*))complBlock;

@end
