//
//  PCRueKioskViewController.h
//  Pad CMS
//
//  Created by tar on 11.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskViewController.h"

@class PCRevision;

@interface PCRueKioskViewController : PCKioskViewController

- (void) downloadingContentStartedWithRevisionIndex:(NSInteger)index;
- (void) downloadingContentFinishedWithRevisionIndex:(NSInteger)index;

- (void) subscribeButtonTaped:(UIButton*)button fromRevision:(PCRevision*)revision;

@end
