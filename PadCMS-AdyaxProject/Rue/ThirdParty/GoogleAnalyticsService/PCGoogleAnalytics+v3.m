//
//  PCGoogleAnalytics+v3.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCGoogleAnalytics.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "PCApplication.h"
#import "PCIssue.h"
#import "PCRevision.h"
#import "PCPage.h"
#import "PCConfig.h"

//https://developers.google.com/analytics/devguides/collection/ios/v3/

static const NSInteger GANDispatchPeriodSec = 10;
static NSString* const DefaultGoogleAnalyticsAccountId = @"UA-1535257-14";
static BOOL GoogleAnalyticsTrackerStarted = NO;

@implementation PCGoogleAnalytics (v3)

+ (void)start
{
    if (!GoogleAnalyticsTrackerStarted)
    {
        NSString* accountId = [PCConfig googleAnalyticsAccountId];
        
        if (accountId == nil)
        {
            accountId = DefaultGoogleAnalyticsAccountId;
        }
        
        //[[GANTracker sharedTracker] startTrackerWithAccountID:accountId dispatchPeriod:GANDispatchPeriodSec delegate:nil];
        
        // Optional: automatically send uncaught exceptions to Google Analytics.
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        [GAI sharedInstance].dispatchInterval = GANDispatchPeriodSec;
        
        // Optional: set Logger to VERBOSE for debug information.
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
        
        // Initialize tracker.
        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:accountId];
        
        GoogleAnalyticsTrackerStarted = YES;
        
        NSLog(@"Google Analytics Tracker Started");
    }
}

+ (void)stop
{
    if (GoogleAnalyticsTrackerStarted)
    {
        id<GAITracker> defaultTracker = [GAI sharedInstance].defaultTracker;
        [[GAI sharedInstance] removeTrackerByName:defaultTracker.name];
        
        //[[GANTracker sharedTracker] stopTracker];
        
        GoogleAnalyticsTrackerStarted = NO;
        
        NSLog(@"Google Analytics Tracker Stopped");
    }
}

+ (void)trackPageView:(PCPage *)page
{
    PCRevision *revision = page.revision;
    PCIssue *issue = revision.issue;
    PCApplication *application = issue.application;
    
    NSString *pageInfo = [NSString stringWithFormat:@"/%@ - %@ - %@",
                          application.title, issue.title, page.machineName];
    
    
    id<GAITracker> defaultTracker = [GAI sharedInstance].defaultTracker;
    
    [defaultTracker set:kGAIScreenName value:pageInfo];
    
    NSDictionary* parametersToSend = [[GAIDictionaryBuilder createAppView] build];
    
    [defaultTracker send:parametersToSend];
    
    /*if ([[GANTracker sharedTracker] trackPageview:pageInfo withError:nil])
    {
        NSLog(@"GA Track Page View: %@", pageInfo);
    }
    else
    {
        NSLog(@"ERROR: [GoogleAnalyticsTracker trackPageView:]");
    }*/
}

+ (void)trackPageNameView:(NSString *)pageName
{
    id<GAITracker> defaultTracker = [GAI sharedInstance].defaultTracker;
    
    [defaultTracker set:kGAIScreenName value:pageName];
    
    NSDictionary* parametersToSend = [[GAIDictionaryBuilder createAppView] build];
    
    [defaultTracker send:parametersToSend];
    
    /*if ([[GANTracker sharedTracker] trackPageview:pageName withError:nil])
    {
        NSLog(@"GA Track Page View: %@", pageName);
    }
    else
    {
        NSLog(@"ERROR: [GoogleAnalyticsTracker trackPageView:]");
    }*/
}

+ (void)trackAction:(NSString *)action category:(NSString *)category
{
    id<GAITracker> defaultTracker = [GAI sharedInstance].defaultTracker;
    
    NSDictionary* parametersToSend = [[GAIDictionaryBuilder createEventWithCategory:category action:action label:nil value:[NSNumber numberWithInt:-1]] build];
    
    [defaultTracker send:parametersToSend];
    
    /*if ([[GANTracker sharedTracker] trackEvent:category action:action
                                         label:nil value:-1 withError:nil])
    {
        NSLog(@"GA Track Action: %@ category: %@", action, category);
    }
    else
    {
        NSLog(@"ERROR: [GoogleAnalyticsTracker trackAction:category:]");
    }*/
}

@end
