//
//  BXCEventStream.h
//  Boxcar
//
//  Copyright (c) 2012-2013 ProcessOne. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BXCEventStreamDelegate <NSObject>
- (void) didReceiveEvent:(NSString *)event;
@end

@interface BXCEventStream : NSObject <NSURLConnectionDelegate>

@property(nonatomic, copy) NSString *streamId;
@property(nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskID;
@property(nonatomic) NSURLConnection *connection;
@property(nonatomic, unsafe_unretained) id <BXCEventStreamDelegate> delegate;

- (id) initWithStreamId:(NSString *)streamId;
- (void) connect;

@end
