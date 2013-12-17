//
//  PCRueTwitterController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/16/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueTwitterController.h"

@implementation PCRueTwitterController

- (void) showTwitterController
{
    TWTweetComposeViewControllerCompletionHandler completionHandler = ^(TWTweetComposeViewControllerResult result)
    {
        switch (result)
        {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: canceled");
                break;
            case TWTweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: sent");
                break;
            default:
                NSLog(@"Twitter Result: default");
                break;
        }
        [self.delegate dismissPCNewTwitterController:self.tweetViewController];
    };
    [self.tweetViewController setCompletionHandler:completionHandler];
    
    [self.tweetViewController setInitialText:self.twitterMessage];
    [self.tweetViewController addImage:nil];
    [self.tweetViewController addURL:self.postUrl];
    if (self.delegate)
    {
        [self.delegate showPCNewTwitterController:self.tweetViewController];
    }
    else
    {
        NSLog(@"PCTwitterNewController.delegate is not defined");
    }
}

@end
