//
//  RueScrollingPageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/22/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueScrollingPageViewController.h"
#import "PCScrollView.h"
#import "RuePageElementBackground.h"
#import "PCPageElemetTypes.h"
#import "PCPageElementActiveZone.h"

@interface PCScrollingPageViewController ()

- (NSArray*) sortActiveZonesByPriority:(NSArray*)array;

@end

@interface RueScrollingPageViewController ()

@end

@implementation RueScrollingPageViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    BOOL shouldBringBackgroundViewToFront = [self shouldBackgroundBeOnTop];
    
    if(shouldBringBackgroundViewToFront)
    {
        [self.mainScrollView bringSubviewToFront:self.backgroundViewController.view];
        self.backgroundViewController.view.userInteractionEnabled = NO;
    }
}

- (NSArray*) sortActiveZonesByPriority:(NSArray*)array
{
    if([self shouldBackgroundBeOnTop])
    {
        return [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            PCPageElementActiveZone* activeZone1 = obj1;
            PCPageElementActiveZone* activeZone2 = obj2;
            
            if([activeZone1.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
            {
                if([activeZone2.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
                {
                    return NSOrderedSame;
                }
                else
                {
                    return NSOrderedDescending;
                }
            }
            else if([activeZone2.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
            {
                return NSOrderedAscending;
            }
            else
            {
                return NSOrderedSame;
            }
        }];
    }
    else
    {
        return [super sortActiveZonesByPriority:array];
    }
}

- (BOOL) shouldBackgroundBeOnTop
{
    RuePageElementBackground* backgroundElement = (RuePageElementBackground*)[self.page firstElementForType:PCPageElementTypeBackground];
    return backgroundElement.showOnTop;
}

@end
