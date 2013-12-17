//
//  PCLocalizationManager+AdditionalInitialization.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/13/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCLocalizationManager.h"

@interface PCLocalizationManager ()
- (void) additionalInitialization;
@end

static PCLocalizationManager *sharedLocalizationManager;

@implementation PCLocalizationManager (AdditionalInitialization)

+ (PCLocalizationManager *)sharedManager
{
    if (sharedLocalizationManager == nil) {
        sharedLocalizationManager = [[super allocWithZone:NULL] init];
        [sharedLocalizationManager additionalInitialization];
    }
    return sharedLocalizationManager;
}

- (NSBundle *)bundleForLanguage:(NSString*)language
{
    NSBundle *bundle = [NSBundle mainBundle];//[self coreResourcesBundle];
    
    if(bundle)
    {
        NSString *path = [bundle pathForResource:language
                                              ofType:@"lproj"];
        
        return [NSBundle bundleWithPath:path];
    }
    return nil;
}

@end
