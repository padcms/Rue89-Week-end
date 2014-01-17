//
//  RueResourceView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/4/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "RueResourceView.h"
#import "PCResourceCache.h"
#import "RueResourceShredder.h"
#import "MBProgressHUD.h"

@interface RueResourceView ()
{
    MBProgressHUD* _HUD;
    
    NSString* _resourceName;
    BOOL _loaded;
    NSString* _piecePath;
}
@end

@implementation RueResourceView

- (void) setResourceName:(NSString *)resourceName
{
    if (resourceName == nil)
    {
        _resourceName = nil;
        self.image = nil;
    }
    else if (_resourceName != resourceName)
    {
        _resourceName = [resourceName copy];
        self.image = nil;
    }
}

- (void) load
{
    if(_resourceName == nil)
    {
        return;
    }
    
    _loaded = YES;
    
    if(_piecePath)
    {
        //[self hideHUD];
        
        id resource = [[PCResourceCache defaultResourceCache] objectForKey:_piecePath];
        
        if (resource != nil && [resource isKindOfClass:UIImage.class])
        {
            [self showImage:(UIImage *)resource];
        }
        else
        {
            [self performSelectorInBackground:@selector(loadResource) withObject:nil];
        }
    }
    else
    {
        //[self showHUD];
        [RueResourceShredder preparePieceAtIndex:self.indexOfPiece ofResource:_resourceName completion:^(NSString *piecePath) {
            
            _piecePath = piecePath;
            if(_loaded)
            {
                [self load];
            }
        }];
    }
}

- (void) unload
{
    //[self hideHUD];
    _loaded = NO;
    self.image = nil;
}

- (void) resourceLoaded:(UIImage*)image
{
    _loaded = YES;
    [[PCResourceCache defaultResourceCache] setObject:image forKey:_piecePath];
    [self showImage:image];
}

- (void) loadResource
{
    @autoreleasepool {
        
        id resource = [UIImage imageWithContentsOfFile:_piecePath];
        
        if (resource != nil && [resource isKindOfClass:UIImage.class])
        {
            self.image = resource;
            
            [self performSelectorOnMainThread:@selector(resourceLoaded:) withObject:resource waitUntilDone:YES];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(showImage:) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void) showImage:(UIImage *)image
{
    self.image = image;
    if (self.resourceViewDidLoadBlock != nil)
    {
        self.resourceViewDidLoadBlock();
    }
    if(image == nil)
    {
        _loaded = NO;
    }
}

- (BOOL) isLoaded
{
    return _loaded;
}

- (void) showHUD
{
	if (_HUD)
	{
		[_HUD removeFromSuperview];
		_HUD = nil;
	}
	_HUD = [[MBProgressHUD alloc] initWithView:self];
	[self addSubview:_HUD];
	_HUD.mode = MBProgressHUDModeIndeterminate;
//	_element.progressDelegate = _HUD;
	[_HUD show:YES];
	
}

- (void) hideHUD
{
	if (_HUD)
	{
		[_HUD hide:YES];
//		_element.progressDelegate = nil;
		[_HUD removeFromSuperview];
		_HUD = nil;
	}
}

@end
