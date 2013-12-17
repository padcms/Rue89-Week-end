//
//  AIRKioskGalleryView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/17/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "AIRKioskGalleryView.h"
#import "PCKioskGalleryControlElement.h"
#import "AIRKioskGalleryItem.h"

@interface PCKioskBaseGalleryView ()
- (void) onCurrentRevisionIndexChanged;
@end

@implementation AIRKioskGalleryView

- (void) createGalleryItems
{
    float   fImageHeight = IMAGE_HEIGHT;
    float   fImageWidth  = IMAGE_WIDTH;
    int     numberOfRevisions = [self.dataSource numberOfRevisions]-1;
    
    if(numberOfRevisions >= 0)
    {
        Class galleryItemClass = [AIRKioskGalleryItem class];
        
        CALayer* transformed = self.galleryView.layer;
        CATransform3D initialTransform = transformed.sublayerTransform;
        initialTransform.m34 = 1.0 / DEEP;
        transformed.sublayerTransform = initialTransform;
        transformed.anchorPoint = CGPointMake(0.5, 0.5);
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.0f] forKey:kCATransactionAnimationDuration];
        
        for (int i=0; i<numberOfRevisions; i++) {
            PCKioskGalleryItem* layer = [galleryItemClass layer];
            
            layer.dataSource = self.dataSource;
            layer.revisionIndex = i;
            
            layer.position = CGPointMake(self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X - numberOfRevisions * GAP + i * GAP, (self.galleryView.bounds.size.height - IMAGE_HEIGHT) / 2);
            layer.bounds   = CGRectMake(0, 0, fImageWidth, ((int)fImageHeight * 5 / 3) + 1);
            
            layer.anchorPoint = CGPointMake(0.0, ANCHOR_POINT_Y);
            layer.angle = RADIANS(ANGLE);
            
            CATransform3D transform = CATransform3DMakeTranslation(0, DISTANCE_FROM_CENTER_Y, -IN_FRONT); //DISTANCE_FROM_CENTER_Z);
            layer.transform = CATransform3DRotate(transform, layer.angle, 0.0f, 1.0f, 0.0);
            
            [self.galleryView.layer addSublayer:layer];
            [layer setNeedsDisplay];
        }
        
        PCKioskGalleryItem* layer = [galleryItemClass layer];
        layer.dataSource = self.dataSource;
        layer.revisionIndex = numberOfRevisions;
        
        layer.position = CGPointMake(self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X, (self.galleryView.bounds.size.height - IMAGE_HEIGHT) / 2);
        NSLog(@"layer position : %@", NSStringFromCGPoint(layer.position));
        
        layer.bounds   = CGRectMake(0, 0, fImageWidth, ((int)fImageHeight * 5 / 3) + 1);
        NSLog(@"layer bouns : %@", NSStringFromCGRect(layer.bounds));
        
        layer.anchorPoint = CGPointMake(0.5, ANCHOR_POINT_Y);
        NSLog(@"layer anchorPoint : %@", NSStringFromCGPoint(layer.anchorPoint));
        
        //layer.frame = CGRectMake(layer.frame.origin.x, (int)layer.frame.origin.y, layer.frame.size.width, layer.frame.size.height);
        NSLog(@"layer frame : %@", NSStringFromCGRect(layer.frame));
        //NSLog(@"layer position : %@", NSStringFromCGPoint(layer.position));
        
        CATransform3D transform = CATransform3DMakeTranslation(DISTANCE_FROM_CENTER_X, DISTANCE_FROM_CENTER_Y, 0); //DISTANCE_FROM_CENTER_Z + IN_FRONT);
        layer.transform = transform;
        
        [self.galleryView.layer addSublayer:layer];
        [layer setNeedsDisplay];
        
        [CATransaction commit];
    }
}

- (void)layoutSubviews
{
    UIInterfaceOrientation curOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // relayout gallery
    if(self.galleryView)
    {
        float               deltaX = 0.0f, destinationY = (self.galleryView.bounds.size.height - IMAGE_HEIGHT) / 2;
        float               centerDestinationX = self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X;
        
        if(UIInterfaceOrientationIsLandscape(curOrientation))
        {
            destinationY = (self.galleryView.bounds.size.height - IMAGE_HEIGHT) / 2 - 50;
        } else if(UIInterfaceOrientationIsPortrait(curOrientation)) {
            destinationY = (self.galleryView.bounds.size.height - IMAGE_HEIGHT) / 2;
        }
        
        for (PCKioskGalleryItem* layer in self.galleryView.layer.sublayers)
        {
            if(layer.angle==0.0)
            {
                deltaX = centerDestinationX - layer.position.x;
                break;
            }
        }
        
        for (PCKioskGalleryItem* layer in self.galleryView.layer.sublayers)
        {
            CGPoint     newPosition = layer.position;
            
            newPosition.x += deltaX;
            newPosition.y = destinationY ;//+ (layer.bounds.size.height * ANCHOR_POINT_Y - ((int)(layer.bounds.size.height * ANCHOR_POINT_Y)));
            layer.position = newPosition;
            if(layer.angle == 0.0)
            {
                [layer correctPosition];
            }
            //layer.frame = CGRectMake((int)layer.frame.origin.x, (int)layer.frame.origin.y, (int)layer.frame.size.width, (int)layer.frame.size.height);
        }
    }
}

- (void) selectIssueWithIndex:(NSInteger)index
{
    if(self.currentRevisionIndex==index) return;   // already selected
    
    PCKioskGalleryItem      *neededLayer = nil;
    
    for (PCKioskGalleryItem* layer in self.galleryView.layer.sublayers)
    {
        
        if (layer.revisionIndex==index)
        {
            neededLayer = layer;
            break;
        }
    }
    
    if(neededLayer)
    {
        float add = self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X - neededLayer.position.x;
        [self moveBy:add duration:DURATION_ANIMATE];
    }
}

-(void)handleSingleTap:(UITapGestureRecognizer*)sender
{
    if(self.disabled) return;
    [super tapInKiosk];
    
    
	CGPoint location = [sender locationInView:self.galleryView];
	PCKioskGalleryItem* touchedLayer = (PCKioskGalleryItem*)[self.galleryView.layer hitTest:location];
	
	while (touchedLayer && touchedLayer.superlayer != self.galleryView.layer)
	{
		touchedLayer = (PCKioskGalleryItem*)touchedLayer.superlayer;
	}
    
	// we won't do anything if this is not the picture layer
	if (touchedLayer)
	{
		if (touchedLayer.angle == RADIANS(0.0) || touchedLayer.angle == RADIANS(180.0)) {
            if([self.dataSource isRevisionDownloadedWithIndex:self.currentRevisionIndex])
            {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
                float duration = 0.2;
                animation.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(touchedLayer.transform, 1.3, 1.3, 1.0)];
                animation.duration = duration;
                animation.delegate = touchedLayer;
                animation.fillMode = kCAFillModeForwards;
                animation.removedOnCompletion = NO;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                
                [touchedLayer addAnimation:animation forKey:@""];
                
                [self performSelector:@selector(readMagazineAfterAnimation:) withObject:touchedLayer afterDelay:duration];
            }
            
		} else if (!self.disabled) {
			// animate this layer to center
			float add = self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X - touchedLayer.position.x;
			
			[self moveBy:add duration:DURATION_ANIMATE];
		}
	}
}

- (void)readMagazineAfterAnimation:(CALayer*)layerToInverse
{
    [self.delegate readButtonTappedWithRevisionIndex:self.currentRevisionIndex];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(layerToInverse.transform, 1, 1, 1.0)];
    animation.duration = 0;
    animation.delegate = layerToInverse;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [layerToInverse addAnimation:animation forKey:@""];
}

-(void)moveBy:(float)add duration:(float)duration {
    
    //add = (int)add;
    
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
	
	int layers = [self.galleryView.layer.sublayers count] - 1;
	int current = 0;
	
	for (PCKioskGalleryItem* layer in self.galleryView.layer.sublayers) {
		float x = layer.position.x + add;
		
		layer.position = CGPointMake(x, layer.position.y);
		
		if (x < self.galleryView.layer.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X) {
			if (layers != current) {
				if (layer.angle != RADIANS(ANGLE)) {
					layer.angle = RADIANS(ANGLE);
					
					// CENTER -> LEFT
					[CATransaction begin];
					[CATransaction setValue:[NSNumber numberWithFloat:DURATION_CHANGE] forKey:kCATransactionAnimationDuration];
					CATransform3D transform = CATransform3DMakeTranslation(0, DISTANCE_FROM_CENTER_Y, -IN_FRONT); //DISTANCE_FROM_CENTER_Z);
					
					layer.transform   = CATransform3DRotate(transform, layer.angle, 0.0f, 1.0f, 0.0);
					layer.anchorPoint = CGPointMake(0.0, ANCHOR_POINT_Y);
					
					[CATransaction commit];
				}
			}
		} else if (x >= self.galleryView.layer.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X + GAP) {
			if (0 < current) {
				if (layer.angle != RADIANS(-ANGLE)) {
					layer.angle = RADIANS(-ANGLE);
					
					// CENTER -> RIGHT
					[CATransaction begin];
					[CATransaction setValue:[NSNumber numberWithFloat:DURATION_CHANGE] forKey:kCATransactionAnimationDuration];
					
					CATransform3D transform = CATransform3DMakeTranslation(DISTANCE_FROM_CENTER_X * 2, DISTANCE_FROM_CENTER_Y, -IN_FRONT); //DISTANCE_FROM_CENTER_Z);
					
					layer.transform = CATransform3DRotate(transform, layer.angle, 0.0f, 1.0f, 0.0);
					layer.anchorPoint = CGPointMake(1.0, ANCHOR_POINT_Y);
					
					[CATransaction commit];
				}
			}
		} else if (layer.angle != 0.0) {
			// LEFT -> CENTER <- RIGHT
			layer.angle = 0.0;
			
            //[layer correctPosition];
            
			[CATransaction begin];
			[CATransaction setValue:[NSNumber numberWithFloat:DURATION_CHANGE * 2] forKey:kCATransactionAnimationDuration];
			
			layer.anchorPoint = CGPointMake(0.5, ANCHOR_POINT_Y);
			layer.transform   = CATransform3DMakeTranslation(DISTANCE_FROM_CENTER_X, DISTANCE_FROM_CENTER_Y, 0); //DISTANCE_FROM_CENTER_Z + IN_FRONT);
			
            
			[CATransaction commit];
		}
        
        if(layer.angle == 0.0)
        {
            [layer correctPosition];
        }
		
		++current;
	}
	
	[CATransaction commit];
    
    [self adjustCurrentRevisionIndex];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.disabled) {
		float add      = 0;
		float duration = 0.0;
        
		if (touches) {
			UITouch *touch = [[event allTouches] anyObject];
			CGPoint fromLocation = [touch previousLocationInView:self.galleryView];
			CGPoint toLocation = [touch locationInView:self.galleryView];
            
			add = (toLocation.x - fromLocation.x) * ANGLE_COEFF;
		} else {
			// move back to the center
			PCKioskGalleryItem* layer = [self.galleryView.layer.sublayers objectAtIndex:0];
			int layers       = [self.galleryView.layer.sublayers count];
            
			float center     = self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X;
			
			if (layer.position.x > center)
			{
				add = center - layer.position.x;
			}
			else if (layer.position.x <= center - (layers - 1) * GAP)
            {
                add = center - layer.position.x - (layers - 1) * GAP;
            }
			duration = 0.5f;
		}
        
		[self moveBy:add duration:duration];
	}
    [self adjustCurrentRevisionIndex];
}

- (void) adjustCurrentRevisionIndex
{
	for (PCKioskGalleryItem* layer in self.galleryView.layer.sublayers)
	{
		if (layer.angle == RADIANS(0))
		{
            NSInteger       newIndex = [self.galleryView.layer.sublayers indexOfObject:layer];
            
            if(newIndex != self.currentRevisionIndex)
            {
                self.currentRevisionIndex = newIndex;
                [self onCurrentRevisionIndexChanged];
            }
			return;
		}
	}
	self.currentRevisionIndex = -1;
}

@end
