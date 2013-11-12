//
//  PCPageViewController+IsPresented.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCPageViewController+IsPresented.h"
#import "objc/runtime.h"

@implementation PCPageViewController (IsPresented)

+ (void) load
{
    Method prevMethod = class_getInstanceMethod([PCPageViewController class], @selector(viewDidLoad));
    Method newMethod = class_getInstanceMethod([PCPageViewController class], @selector(viewDidLoadAdvanced));
    
    method_exchangeImplementations(prevMethod, newMethod);
}

- (BOOL) isPresentedPage
{
    if([self magazineViewController])
    {
        if([[self magazineViewController]respondsToSelector:@selector(navigationController)] && self.magazineViewController.navigationController != nil)
        {
            if(self.columnViewController == self.magazineViewController.currentColumnViewController)
            {
                if(self == self.columnViewController.currentPageViewController)
                {
                    return YES;
                }
            }
        }
    }
    return NO;
    //return ([self magazineViewController] && [[self magazineViewController]navigationController] && self.columnViewController == self.magazineViewController.currentColumnViewController && self == self.columnViewController.currentPageViewController);
}

- (void) viewDidLoadAdvanced
{
    [self viewDidLoadAdvanced];
    if([self magazineViewController] && [self columnViewController])
    {
        [self.magazineViewController addObserver:self forKeyPath:@"currentColumnViewController" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentColumnViewController"])
    {
        
    }
}

@end
