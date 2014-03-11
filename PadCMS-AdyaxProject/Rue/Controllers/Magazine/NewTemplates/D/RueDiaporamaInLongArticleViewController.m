//
//  RueDiaporamaInLongArticleViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueDiaporamaInLongArticleViewController.h"
#import "PCScrollView.h"
#import "PCPageControllersManager.h"
#import "RueSlideViewController.h"
#import "PCPDFActiveZones.h"
#import "PCPageElemetTypes.h"

@interface RueDiaporamaInLongArticleViewController ()

@property (nonatomic, strong) PCScrollView* slidersView;
@property (nonatomic, strong) NSArray* slideViewControllers;
@property (nonatomic, assign) CGRect sliderRect;

@property (nonatomic, strong) UIButton* leftButton;
@property (nonatomic, strong) UIButton* rightButton;

@property (nonatomic, assign) int currentSlideIndex;

@end

@implementation RueDiaporamaInLongArticleViewController

+ (void) load
{
    PCPageTemplate* newTemplate = [PCPageTemplate templateWithIdentifier:25
                                                                   title:@"Diaporama in a long article"
                                                             description:@""
                                                              connectors:PCTemplateAllConnectors
                                                           engineVersion:1];
    [[PCPageTemplatesPool templatesPool] registerPageTemplate:newTemplate];
    
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:newTemplate];
}

- (void)loadView
{
    [super loadView];
    
    self.slidersView = [[PCScrollView alloc] initWithFrame:self.view.frame];
    //self.slidersView.delegate = self;
    self.slidersView.contentSize = CGSizeZero;
    self.slidersView.bounces = NO;
    self.slidersView.showsVerticalScrollIndicator = NO;
    self.slidersView.showsHorizontalScrollIndicator = NO;
    self.slidersView.clipsToBounds = YES;
    self.slidersView.alwaysBounceVertical = NO;
    self.slidersView.alwaysBounceHorizontal = NO;
    self.slidersView.pagingEnabled = YES;
    self.slidersView.delaysContentTouches = NO;
    self.slidersView.autoresizesSubviews = NO;
    self.slidersView.autoresizingMask = UIViewAutoresizingNone;
    
    self.slidersView.scrollEnabled = NO;
    
    self.mainScrollView.scrollEnabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sliderRect = [self activeZoneRectForType:PCPDFActiveZoneScroller];
    self.slidersView.frame = self.sliderRect;
    [self.mainScrollView addSubview:self.slidersView];
    [[self mainScrollView] bringSubviewToFront:self.slidersView];
    
    [self createAndPlaceButtons];
    
    NSArray* slideElements = [self sortetByWeightPageElementsOfType:PCPageElementTypeSlide];
    self.slideViewControllers = [self createSlideViewControllersForElements:slideElements];
    
    self.slidersView.backgroundColor = [UIColor clearColor];
}

- (void) loadFullView
{
    [super loadFullView];
    
    //change slidersView contentSize and frame here for avoid subviews frame random changes
    if (!CGRectEqualToRect(self.sliderRect, CGRectZero))
    {
        [self.slidersView setFrame:self.sliderRect];
        
        [self.slidersView setContentSize:CGSizeMake([self.slideViewControllers count] * self.slidersView.frame.size.width,
                                                    self.slidersView.frame.size.height)];
        //decrease height for avoid vertical bounce
    }
    
    for (unsigned i = 0; i < [self.slideViewControllers count]; i++)
    {
        UIViewController *slideController = [self.slideViewControllers objectAtIndex:i];
        
//        CGRect newSlideRect = CGRectMake(self.view.frame.size.width * i, /*self.slidersView.frame.size.height - self.view.frame.size.height*/-self.sliderRect.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        
                CGRect newSlideRect = CGRectMake(self.slidersView.frame.size.width * i,
                                                0,
                                                self.slidersView.frame.size.width,
                                               self.slidersView.frame.size.height);
        
        [slideController.view setFrame:newSlideRect];
        
    }
    
    [self updateViewsForCurrentIndex];
}

- (void) unloadFullView
{
    [super unloadFullView];
    
    for(PCPageElementViewController *slideViewController in self.slideViewControllers)
    {
        [slideViewController unloadView];
    }
}

- (void) updateViewsForCurrentIndex
{
    if (self.slideViewControllers.count == 0) {
        return;
    }
    
    self.leftButton.hidden = (self.currentSlideIndex == 0);
    self.rightButton.hidden = (self.currentSlideIndex == self.slideViewControllers.count - 1);
    
    for(int i = 0; i < [self.slideViewControllers count]; ++i)
    {
        if(ABS(self.currentSlideIndex - i) > 1)
        {
            [[self.slideViewControllers objectAtIndex:i] unloadView];
        }
        else
        {
            [[self.slideViewControllers objectAtIndex:i] loadFullViewImmediate];
        }
    }
}

- (NSArray*) sortetByWeightPageElementsOfType:(NSString*)elementType
{
    NSArray* elementsOfType = [page elementsForType:elementType];
    elementsOfType = [elementsOfType sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES], nil]];
    return elementsOfType;
}

- (void) scrollSliderToIndex:(int)index
{
    CGPoint offset = {0, 0};
    offset.x = index * self.slidersView.frame.size.width;
    [self.slidersView setContentOffset:offset animated:YES];
}

- (NSArray*) createSlideViewControllersForElements:(NSArray*)slideElements
{
    NSMutableArray* slideControllers = [[NSMutableArray alloc]initWithCapacity:slideElements.count];
    
    if (slideElements && [slideElements count] > 0)
    {
        for (unsigned i = 0; i < [slideElements count]; i++)
        {
            PCPageElementSlide* element = [slideElements objectAtIndex:i];
//            float scale = self.slidersView.frame.size.width / element.size.width;
//            CGSize elementSize = element.size;
//            if (element.size.width*element.size.height) {
//                elementSize.height *= scale;
//                elementSize.width *= scale;
//            } else {
//                elementSize.height = self.slidersView.frame.size.height;
//                elementSize.width = self.slidersView.frame.size.width;
//            }
            
            
//            CGRect newSlideRect = CGRectMake(self.slidersView.frame.size.width*i, /*0+(self.slidersView.frame.size.height-elementSize.height)*/-self.sliderRect.origin.y, elementSize.width, elementSize.height);
            
            NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:element.resource];
            
//            PCPageElementViewController *slideViewController = [[PCPageElementViewController alloc] initWithResource:fullResource];
            RueSlideViewController *slideViewController = [[RueSlideViewController alloc] initWithResource:fullResource];
            
//            [slideViewController.view setFrame:newSlideRect];
//            slideViewController.element = element;
            
//            slideViewController.view.clipsToBounds = YES;
//            slideViewController.view.contentMode = UIViewContentModeScaleAspectFit;
            
            [slideControllers addObject:slideViewController];
            
            [self.slidersView addSubview:slideViewController.view];
            
        }
    }
    return [NSArray arrayWithArray:slideControllers];
}

#pragma mark - Buttons

- (void) createAndPlaceButtons
{
    NSArray* buttonElements = [self sortetByWeightPageElementsOfType:PCPageElementTypeMiniArticle];
    
    if(buttonElements.count > 0)
    {
        self.leftButton = [self createButtonWithLeftZoneForElement:[buttonElements objectAtIndex:0]];
        [self.mainScrollView addSubview:self.leftButton];
    }
    if(buttonElements.count > 1)
    {
        self.rightButton = [self createButtonWithRightZoneForElement:[buttonElements objectAtIndex:1]];
        [self.mainScrollView addSubview:self.rightButton];
    }
}

- (void) leftButtonPresed:(UIButton*)button
{
    [self scrollSliderToIndex:--self.currentSlideIndex];
    [self updateViewsForCurrentIndex];
}

- (void) rightButtonPresed:(UIButton*)button
{
    [self scrollSliderToIndex:++self.currentSlideIndex];
    [self updateViewsForCurrentIndex];
}

- (UIButton*) createButtonWithLeftZoneForElement:(PCPageElement*)element
{
    UIButton* leftButton = [self createButtonForElement:element];
    CGRect activeZoneRectForButton1 = [self activeZoneRectForType:@"local://button/1"];
    leftButton.frame = activeZoneRectForButton1;
    [leftButton addTarget:self action:@selector(leftButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
    return leftButton;
}

- (UIButton*) createButtonWithRightZoneForElement:(PCPageElement*)element
{
    UIButton* rightButton = [self createButtonForElement:element];
    CGRect activeZoneRectForButton2 = [self activeZoneRectForType:@"local://button/2"];
    rightButton.frame = activeZoneRectForButton2;
    [rightButton addTarget:self action:@selector(rightButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
    return rightButton;
}

- (UIButton*) createButtonForElement:(PCPageElement*)element
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.adjustsImageWhenHighlighted = NO;
    
    NSString *fullResourcePath = [self.page.revision.contentDirectory stringByAppendingPathComponent:element.resource];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [button setImage:image forState:UIControlStateNormal];
        });
    });
    button.exclusiveTouch = YES;
    return button;
}

@end
