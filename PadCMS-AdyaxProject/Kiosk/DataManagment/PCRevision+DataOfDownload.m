//
//  PCRevision+DataOfDownload.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/3/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevision+DataOfDownload.h"

@implementation PCRevision (DataOfDownload)

- (NSDate*) dateOfDownload
{
    //NSString *databasePath = [self.contentDirectory stringByAppendingPathComponent:@"sqlite.db"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath])
    {
        NSError *error = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.contentDirectory error:&error];
        
        if (error != nil)
        {
            NSLog(@"ERROR ([PCRevision dateOfDownload]): %@", error.localizedDescription);
            return nil;
        }
        else
        {
            //NSLog(@"attr : %@", fileAttributes.debugDescription);
            NSDate *fileModificationDate = [fileAttributes objectForKey:NSFileCreationDate];
            return fileModificationDate;
        }
    }
    else
    {
        return nil;
    }
}

@end
