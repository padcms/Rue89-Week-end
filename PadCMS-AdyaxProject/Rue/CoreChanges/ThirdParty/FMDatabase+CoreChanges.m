//
//  FMDatabase+CoreChanges.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/16/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "FMDatabase.h"

@implementation FMStatement (CoreChanges)

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ %ld hit(s) for query %@", [super description], useCount, query];
}

@end