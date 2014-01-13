//
//  PCKioskViewController+RemoveMemoryLeak.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/10/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "PCKioskViewController.h"

@interface PCKioskViewController (RemoveMemoryLeak)

- (void) unloadView;

@end
