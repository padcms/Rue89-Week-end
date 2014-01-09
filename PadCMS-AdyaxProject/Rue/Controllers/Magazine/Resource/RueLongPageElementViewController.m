//
//  RueLongPageElementViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/4/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "RueLongPageElementViewController.h"
#import "RueResourceView.h"
#import "Helper.h"
#import "UIView+EasyFrame.h"
#import "RueResourceShredder.h"

@interface PCPageElementViewController()
{
@protected
    MBProgressHUD* _HUD;
    CGFloat _targetWidth;
    NSString *_resource;
	BOOL _loaded;
}

- (void)hideHUD;
- (void)applicationDidChangeStatusBarOrientationNotification;

@end

@interface RueLongPageElementViewController ()
{
    int _currentIndex;
}

@property (nonatomic, strong) NSArray* resourceViews;

@end

@implementation RueLongPageElementViewController

- (BOOL) isEqual:(id)object
{
    if([super isEqual:object])
        return YES;
    
    if([object class] != [RueLongPageElementViewController class])
        return NO;
    
    RueLongPageElementViewController *anotherObject = (RueLongPageElementViewController *)object;
    
    return [self.resource isEqualToString:anotherObject.resource];
}

- (void) setYOffset:(float)yOffset
{
    _yOffset = yOffset;
    [self updateForCurrentResourceViewIndex];
}

- (int) indexForOffset:(float)offset
{
    float koeff = offset / 1024;
    int index =  (int)koeff;
    if(koeff - index >= 0.5)
    {
        ++index;
    }
    return index;
}

- (void) updateForCurrentResourceViewIndex
{
    if (_resourceViews == nil)
    {
        return;
    }
    
    int index = [self indexForOffset:self.yOffset];
    
    _currentIndex = index;
    
    [self unloadViewAtIndex:_currentIndex - 2];
    [self unloadViewAtIndex:_currentIndex + 2];
    [self loadViewAtIndex:_currentIndex];
    [self loadViewAtIndex:_currentIndex + 1];
    [self loadViewAtIndex:_currentIndex - 1];
}

- (void) loadViewAtIndex:(int)index
{
    if(index >= 0 && index < _resourceViews.count)
    {
        RueResourceView* resourceView = [_resourceViews objectAtIndex:index];
        if(resourceView.isLoaded == NO)
        {
            [resourceView load];
        }
    }
}

- (void) unloadViewAtIndex:(int)index
{
    if(index > 0 && index < _resourceViews.count)
    {
        RueResourceView* resourceView = [_resourceViews objectAtIndex:index];
        if(resourceView.isLoaded == YES)
        {
            [resourceView unload];
        }
    }
}

- (void) loadFullView
{
    [self correctSize];
    
    if (_resourceView != nil || _resourceViews != nil)
    {
        _loaded = YES;
        return;
    }
    
    [self initResourceViews];
    
    for (int i = 0; i < _resourceViews.count; ++i)
    {
        RueResourceView* view = [_resourceViews objectAtIndex:i];
        [self.view addSubview:view];
    }
    
    [self updateForCurrentResourceViewIndex];
    
    _loaded = YES;
}

- (void) loadFullViewImmediate
{
    [self correctSize];
    
    if (_resourceView != nil || _resourceViews != nil)
    {
        _loaded = YES;
        return;
    }
    
    [self initResourceViews];
    
    _loaded = YES;
    
    for (int i = 0; i < _resourceViews.count; ++i)
    {
        RueResourceView* view = [_resourceViews objectAtIndex:i];
        [self.view addSubview:view];
    }
    
    [self updateForCurrentResourceViewIndex];
}

- (void) initResourceViews
{
    int piecesCount = [RueResourceShredder piecesCountForResource:self.resource];
    
    NSMutableArray* resourcesViews = [NSMutableArray arrayWithCapacity:piecesCount];
    
    float resourceViewY = 0;
    for (int i = 0; i < piecesCount; ++i)
    {
        CGSize viewSize = [self sizeForResourceViewAtIndex:i];
        CGRect viewRect = CGRectMake(0, resourceViewY, viewSize.width, viewSize.height);
        resourceViewY += viewSize.height;
        
        RueResourceView* resourceView = [[RueResourceView alloc] initWithFrame:viewRect];
        resourceView.resourceName = self.resource;
        resourceView.indexOfPiece = i;
        
        [resourcesViews addObject:resourceView];
    }
    
    _resourceViews = [NSArray arrayWithArray:resourcesViews];
}


- (void) unloadView
{
	_loaded = NO;
	[self hideHUD];
    if (_resourceView != nil)
    {
        _resourceView.resourceName = nil;
        [_resourceView removeFromSuperview];
        _resourceView = nil;
    }
    if (_resourceViews)
    {
        for (PCResourceView* resourceView in _resourceViews)
        {
            resourceView.resourceName = nil;
            [resourceView removeFromSuperview];
        }
        _resourceViews = nil;
    }
}

- (CGSize) sizeForResourceViewAtIndex:(int)index
{
    return [RueResourceShredder sizeOfPieceAtIndex:index forResours:self.resource];
}

- (void) correctSize
{
    CGSize imageSize = [Helper getSizeForImage:self.resource];
    
    if(!CGSizeEqualToSize(imageSize, CGSizeZero))
    {
        CGFloat scale = _targetWidth / imageSize.width;
        
        CGSize newSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       self.view.frame.origin.y,
                                       newSize.width,
                                       newSize.height)];
        
        if(_resourceView != nil)
        {
            [_resourceView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
        }
        
        if(_resourceViews != nil)
        {
            for (int i = 0; i < _resourceViews.count; ++i)
            {
                PCResourceView* cellResourceView = [_resourceViews objectAtIndex:i];
                float scale = _targetWidth / cellResourceView.frame.size.width;
                float y = 0;
                if(i > 0)
                {
                    PCResourceView* prevResourceView = [_resourceViews objectAtIndex:i-1];
                    y = prevResourceView.frameY + prevResourceView.frameHeight;
                }
                [cellResourceView setFrame:CGRectMake(0, y, cellResourceView.frame.size.width * scale, cellResourceView.frame.size.height * scale)];
            }
        }
    }
}

@end
