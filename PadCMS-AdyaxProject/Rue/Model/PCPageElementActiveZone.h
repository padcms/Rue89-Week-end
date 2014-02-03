//
//  PCPageElementActiveZone.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/3/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "PCPageActiveZone.h"

@class PCPageElement;

@interface PCPageElementActiveZone : PCPageActiveZone

@property (nonatomic, weak) PCPageElement* pageElement;

@end
