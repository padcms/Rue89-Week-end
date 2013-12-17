//
//  PCPageViewController+IsPresented.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCPageViewController.h"

@interface PCPageViewController (IsPresented)

- (BOOL) isPresentedPage;

- (void) didBecamePresented;

- (void) didStopToBePresented;

@end
