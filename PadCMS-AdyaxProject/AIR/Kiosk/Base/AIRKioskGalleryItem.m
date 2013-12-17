//
//  AIRKioskGalleryItem.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/5/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "AIRKioskGalleryItem.h"

@interface AIRKioskGalleryItem ()
{
    CGPoint _nativePosition;
}

@end

@implementation AIRKioskGalleryItem

- (id) init
{
    self = [super init];
    if(self)
    {
        _nativePosition = [super position];
    }
    return self;
}

- (void) drawInContext:(CGContextRef)theContext
{
	CGRect rect = self.bounds;
	//rect.size.height = rect.size.height;
	// Draw image
	CGContextSaveGState(theContext);
	
    CGContextTranslateCTM(theContext, 0, rect.size.height);
    CGContextScaleCTM(theContext, 1.0, -1.0);
	
	UIImage     *img = self.image ? self.image : [self.dataSource revisionCoverImageWithIndex:self.revisionIndex andDelegate:self];
    
    
    
    if(img)
    {
        if(img != self.image)     // process only once
        {
            [self assignCoverImage:img];
            img = self.image;
        }
        //CGSize imageSize = img.size;
        
        rect.origin.y    = rect.size.height - IMAGE_HEIGHT - 10;
        rect.size.height = IMAGE_HEIGHT;
        
        //        rect.origin.y    = re;
        //        rect.size.height = img.size.height;
        //        rect = CGRectMake(0, rect.size.height - IMAGE_HEIGHT, img.size.width, img.size.height);
        
        CGContextDrawImage(theContext, rect, img.CGImage);
        
//        CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(theContext);
//        UIImage *result = [UIImage imageWithCGImage:mainViewContentBitmapContext];
//        NSLog(@"IMG: %.0f x %.0f", result.size.width, result.size.height);
//        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
//        NSString *path = nil;
//        if ([paths count] > 0) {
//            NSString * libPath = [paths objectAtIndex:0];
//            path = [libPath stringByAppendingPathComponent:[NSString stringWithFormat:@"fc%d.png", self.revisionIndex]];
//        }
//        if(path)
//        {
//            [UIImagePNGRepresentation(result) writeToFile:path atomically:YES];
//        }
    }
    
	
    CGContextRestoreGState(theContext);
	
	// Draw reflection
    if (self.drawReflection)
    {
        CGGradientRef glossGradient;
        CGColorSpaceRef rgbColorspace;
        
        rect.origin.y = IMAGE_HEIGHT + 10;
        CGContextDrawImage(theContext, rect, img.CGImage);
        
        size_t num_locations = 2;
        CGFloat locations[2] = { 0.0, 1.0 };
        CGFloat components[8] = { 0.0, 0.0, 0.0, 0.50,  // Start color
            0.0, 0.0, 0.0, 1.00 }; // End color
        
        rgbColorspace = CGColorSpaceCreateDeviceRGB();
        glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
        
        CGPoint topCenter = CGPointMake(self.bounds.size.width / 2, IMAGE_HEIGHT + 10);
        CGPoint midCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height);
        CGContextDrawLinearGradient(theContext, glossGradient, topCenter, midCenter, 0);
        
        CGGradientRelease(glossGradient);
        
        CGColorSpaceRelease(rgbColorspace);
    }
}

- (void) assignCoverImage:(UIImage*) coverImage
{
    if(coverImage)
    {
        CGFloat         srcWidth = coverImage.size.width,
        srcHeight = coverImage.size.height;
        
        CGFloat         scale = ((float)(IMAGE_WIDTH)) / srcWidth;
        
        CGFloat         newWidth = srcWidth * scale,
        newHeight = srcHeight * scale;
        
        CGFloat         marginLeft = 0.0, marginTop = 0.0;
        
        if(newHeight > IMAGE_HEIGHT)    // height is bigger
        {
            scale = ((float)(IMAGE_HEIGHT)) / srcHeight;
            newWidth = srcWidth * scale;
            newHeight = srcHeight * scale;
            marginLeft = (IMAGE_WIDTH - newHeight) / 2;
        } else if(newHeight < IMAGE_HEIGHT)
        {
            marginTop = IMAGE_HEIGHT - newHeight;
        }
        
        /*
         CGRect      rect = self.bounds;
         
         CGFloat scale = ((float)(IMAGE_WIDTH)) / coverImage.size.width;
         CGSize newSize = CGSizeMake(coverImage.size.width * scale, coverImage.size.height * scale);
         rect = CGRectMake(0, 0, newSize.width, newSize.height*5/3);
         self.bounds = rect;
         */
        
        //float scaleFactor = [UIScreen mainScreen].scale;
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef bitmapContext = CGBitmapContextCreate(NULL, IMAGE_WIDTH, IMAGE_HEIGHT, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
        //CGContextScaleCTM(bitmapContext, scaleFactor, scaleFactor);
        CGColorSpaceRelease(colorSpace);
        
        CGRect     imageRect = CGRectMake(marginLeft, 0, newWidth, newHeight);
        
        // fill with white color image area
        CGContextSetFillColorWithColor(bitmapContext, [UIColor whiteColor].CGColor);
        CGContextFillRect(bitmapContext, imageRect);
        
        // draw image
        CGContextDrawImage(bitmapContext, imageRect, coverImage.CGImage);
        
        CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(bitmapContext);
        UIImage *result = [UIImage imageWithCGImage:mainViewContentBitmapContext];
        CGContextRelease(bitmapContext);
        
        //////////////////
        /*
         NSLog(@"IMG: %.0f x %.0f", result.size.width, result.size.height);
         NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
         NSString *path = nil;
         if ([paths count] > 0) {
         NSString * libPath = [paths objectAtIndex:0];
         path = [libPath stringByAppendingPathComponent:[NSString stringWithFormat:@"fc%d.png", self.revisionIndex]];
         }
         if(path)
         {
         [UIImagePNGRepresentation(result) writeToFile:path atomically:YES];
         }
         */
        //////////////////
        self.image = nil;
        self.image = result;
        
    } else {
        self.image = nil;
        self.image = coverImage;
    }
}

- (CGPoint) position
{
    CGPoint superPosition = [super position];
    
    if(ABS(_nativePosition.x - superPosition.x) < 1 && ABS(_nativePosition.y - superPosition.y) < 1)
    {
        return _nativePosition;
    }
    else
    {
//        _nativePosition = superPosition;
        return superPosition;
    }
}

- (void) setPosition:(CGPoint)position
{
    _nativePosition = position;
    [super setPosition:position];
}

- (void) correctPosition
{
    float dx, dy;
    
    dx = roundf(self.frame.origin.x) - self.frame.origin.x;
    dy = roundf(self.frame.origin.y) - self.frame.origin.y;
    
    [super setPosition:CGPointMake(_nativePosition.x + dx, _nativePosition.y + dy)];
    
//    NSLog(@"frame : %@", NSStringFromCGRect(self.frame));
}

@end

@implementation PCKioskGalleryItem (CorrectPosition)

- (void) correctPosition
{
    
}

@end