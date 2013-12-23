//
//  RueMainViewController+Update.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/23/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueMainViewController.h"
#import "RuePadCMSCoder.h"
#import "RueAccessManager.h"
#import "PCRueApplication.h"
#import "PCPathHelper.h"

@interface RueMainViewController ()

@property BOOL needUpdate;

- (BOOL) isNotConnectedToNetwork;
- (void) dissmissKiosk;
- (void) hideForOurReadersPopup;
- (void) syncronyzeApp:(PCRueApplication*)application fromOldApplicationParameters:(NSDictionary*)oldParametersList toNewApplicationParameters:(NSDictionary*)newParametersList;
- (void) initKiosk;
- (void)showForOurReadersPopup;
- (void)initManager;
- (BOOL) isKioskPresented;

@end

@implementation RueMainViewController (Update)

- (void) update
{
    static BOOL _isUpdating = NO;
    static NSDictionary* _previousApplicationInfo = nil;
    static NSDictionary* _actualApplicationInfo = nil;
    
    if(_isUpdating)
    {
        return;
    }
    else
    {
        if(_actualApplicationInfo)
        {
            [self updateKioskFrom:_previousApplicationInfo to:_actualApplicationInfo];
            _previousApplicationInfo = _actualApplicationInfo = nil;
            self.needUpdate = NO;
            [self hideUpdateAnimation];
        }
        else if([self isNotConnectedToNetwork] == NO)
        {
            
            [self showUpdateAnimation];
            _isUpdating = YES;
            
            _previousApplicationInfo = [RuePadCMSCoder applicationParametersFromCuurentPlistContent];
            
            RuePadCMSCoder* padCMSCoder = [[RuePadCMSCoder alloc] initWithDelegate:self];
            [padCMSCoder syncServerPlistDownloadAsynchronouslyWithPassword:[RueAccessManager publisherPassword] completion:^(NSError *error) {
                
                _isUpdating = NO;
                if(error == nil)
                {
                    _actualApplicationInfo = [RuePadCMSCoder applicationParametersFromCuurentPlistContent];
                    
                    if([self isKioskPresented])
                    {
                        [self updateKioskFrom:_previousApplicationInfo to:_actualApplicationInfo];
                        _previousApplicationInfo = _actualApplicationInfo = nil;
                        self.needUpdate = NO;
                        [self hideUpdateAnimation];
                    }
                }
                else
                {
                    if([self isKioskPresented])
                    {
                        self.needUpdate = NO;
                        [self hideUpdateAnimation];
                    }
                    NSLog(@"Update issues list error : %@", error);
                }
            }];
        }
    }
}

- (void) updateKioskFrom:(NSDictionary*)oldParams to:(NSDictionary*)newParsms
{
    self.revisionViewController.mainViewController = nil;
    self.revisionViewController = nil;
    currentApplication = nil;
    [self dissmissKiosk];
    [self hideForOurReadersPopup];
    
    if(newParsms)
    {
        currentApplication = [[PCRueApplication alloc] initWithParameters:newParsms rootDirectory:[PCPathHelper pathForPrivateDocuments]];
        
        if(oldParams)
        {
            [self syncronyzeApp:[self getApplication] fromOldApplicationParameters:oldParams toNewApplicationParameters:newParsms];
        }
    }
    
    [self initKiosk];
    [self showForOurReadersPopup];
}

- (void) showUpdateAnimation
{
    
}

- (void) hideUpdateAnimation
{
    
}

- (void) destroyKiosk
{
    self.revisionViewController.mainViewController = nil;
    self.revisionViewController = nil;
    currentApplication = nil;
    [self dissmissKiosk];
    [self hideForOurReadersPopup];
}

- (void) createKiosk
{
    [self initManager];
    [self initKiosk];
    
    [self showForOurReadersPopup];
    
    self.needUpdate = NO;
    
}

@end
