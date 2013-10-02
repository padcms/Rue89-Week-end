//
//  PCAppDelegate.m
//  PadCMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCAppDelegate.h"

#import "PCAccount.h"
#import "PCApplicationsListViewController.h"
#import "PCAuthorizationViewController.h"
#import "PCGoogleAnalytics.h"
#import "PCIssuesListViewController.h"
#import "PCMSMainSplitViewController.h"
#import "PCPopupView.h"
#import "PCUserInfo.h"

@interface PCAppDelegate ()
{
    PCAuthorizationViewController *_authorizationViewController;
}

- (UIViewController *)rootViewController;

@end

@implementation PCAppDelegate

@synthesize account = _account;
@synthesize window = _window;

- (void)dealloc
{
    [self disconnectAccountKVO];
    [_account release];
    [_window release];
    [_authorizationViewController release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PCGoogleAnalytics start];
    [PCGoogleAnalytics trackAction:@"PadCMS Application launch" category:@"General"];
    
    _account = [[PCAccount alloc] init];
    [self connectAccountKVO];
    
    _authorizationViewController = [[PCAuthorizationViewController alloc] init];
    _authorizationViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    _authorizationViewController.account = _account;
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = [self rootViewController];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];

    if (YES) // [_account isLoggedIn] // account credentials could be saved
    {
        [self.window.rootViewController presentViewController:_authorizationViewController 
                                                     animated:YES 
                                                   completion:nil];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [PCGoogleAnalytics stop];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (UIViewController *)rootViewController
{
    PCMSMainSplitViewController *splitViewController = [[PCMSMainSplitViewController alloc] init];

    PCIssuesListViewController *issuesListViewController = [[PCIssuesListViewController alloc] init]; 
    issuesListViewController.mainSplitViewController = splitViewController;
    splitViewController.detailViewController = issuesListViewController;
    [issuesListViewController release];

    PCApplicationsListViewController *applicationsListViewController = [[PCApplicationsListViewController alloc] init];
    applicationsListViewController.issuesListViewController = issuesListViewController;
    applicationsListViewController.mainSplitViewController = splitViewController;
    
    [_account addObserver:applicationsListViewController forKeyPath:@"applications" 
                  options:NSKeyValueObservingOptionNew context:NULL];
    
    splitViewController.masterViewController = applicationsListViewController;
    [applicationsListViewController release];
    
    return [splitViewController autorelease];
}

#pragma mark KVO

- (void)connectAccountKVO
{
    if (_account == nil) return;
    
    [_account addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew 
                  context:NULL];
}

- (void)disconnectAccountKVO
{
    if (_account == nil) return;
    
    [_account removeObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                        change:(NSDictionary *)change context:(void *)context
{
    if (object == _account && [keyPath isEqualToString:@"state"])
    {
        PCAccountState accountState = [[change objectForKey:@"new"] intValue];
        
        switch (accountState) {
            case PCAccountStateInvalid:
                NSLog(@"ERROR. PCAuthorizationViewController. Recieved PCAccountStateInvalid");
                break;
                
            case PCAccountStateNotConnected: {
                PCMSMainSplitViewController *splitViewController = (PCMSMainSplitViewController *)self.window.rootViewController; 
                [splitViewController setTopBarTitle:@""];
                [splitViewController setTopBarAccountName:@""];
                [self.window.rootViewController presentViewController:_authorizationViewController 
                                                             animated:YES 
                                                           completion:nil];
            } 
                break;
                
            case PCAccountStateConnected: {
                PCMSMainSplitViewController *splitViewController = (PCMSMainSplitViewController *)self.window.rootViewController; 
                [splitViewController setTopBarTitle:@""];
                [splitViewController setTopBarAccountName:_authorizationViewController.account.userName];

                [PCPopupView showPopupViewInView:splitViewController.view 
                                           title:NSLocalizedString(@"Ok, You are log", nil) 
                                         message:[NSString stringWithFormat:@"%@ %@", 
                                                  _authorizationViewController.account.userInfo.firstName,
                                                  _authorizationViewController.account.userInfo.lastName]];
                
                [_authorizationViewController dismissViewControllerAnimated:YES completion:nil];
            }
                break;
                
            case PCAccountStateError:
                break;
                
            default:
                NSLog(@"ERROR. PCAuthorizationViewController. Recieved wrong PCAccountState");
                break;
        }
    }
}


@end
