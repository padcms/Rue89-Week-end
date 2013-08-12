//
//  main.m
//  the_reader
//
//  Created by Mac OS on 7/23/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) 
{    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

#ifdef PADCMS
    int retVal = UIApplicationMain(argc, argv, nil, @"PCAppDelegate");
#else
    int retVal = UIApplicationMain(argc, argv, nil, nil);
#endif
	
    [pool release];
    return retVal;
}
