//
//  CKPickerCollectionCellComponent.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "CKPickerCollectionCellComponent.h"
#import "AppConsts.h"
#import "StringHelper.h"
#import "CKPickerCollectionView.h"
#import "ImageCache.h"

#define IMAGE_SIZE 60

@interface CKPickerCollectionCellComponent ()

@property (nonatomic, strong) CKImageComponent *avatarImageComponent;
@property (nonatomic, strong) CKLabelComponent *nameLabelComponent;
@property (nonatomic, strong) CKButtonComponent *removeButtonComponent;

@property (nonatomic, assign) CKPickerCollectionView *context;
@property (nonatomic, assign) PickerViewModel *model;

@end

@implementation CKPickerCollectionCellComponent

+ (instancetype)newWithPickerViewModel:(PickerViewModel *)viewModel
                               context:(CKPickerCollectionView *)context {
    CKComponentScope scope(self);
    
    UIImage *avatarImage = [[ImageCache instance] imageForKey:viewModel.identifier];
    if (!avatarImage) {
        avatarImage = [CKPickerCollectionCellComponent
                       imageByColorCode:viewModel.gradientColorCode];
    }
    
    CKButtonComponent *removeButtonComponent =
    [CKButtonComponent
     newWithAction:{scope, @selector(removeButtonTapped)}
     options:{
        .titles = @"X",
        .titleFont = [UIFont boldSystemFontOfSize:15],
        .titleColors = [UIColor blackColor],
        .attributes = {
            {@selector(setBackgroundColor:), [UIColor colorWithRed:240/255.f
                                                             green:241/255.f
                                                              blue:242/255.f
                                                             alpha:1]},
            {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 20 / 2.f}
        },
        .size = {
            .width = 20, .height = 20
        }
    }];
    
    CKLabelComponent *shortNameComponent =
    [CKLabelComponent
     newWithLabelAttributes:{
        .string = [StringHelper getShortName:viewModel.name],
        .color = [UIColor whiteColor],
        .font = [UIFont boldSystemFontOfSize:20],
        .alignment = NSTextAlignmentCenter
    }
     viewAttributes:{
        {@selector(setBackgroundColor:), [UIColor clearColor]},
        {@selector(setContentMode:), UIViewContentModeScaleToFill},
        {@selector(setUserInteractionEnabled:), NO}
    }
     size:{}];
    
    CKCenterLayoutComponent *centerTextComponent =
    [CKCenterLayoutComponent
     newWithCenteringOptions:CKCenterLayoutComponentCenteringXY
     sizingOptions:CKCenterLayoutComponentSizingOptionDefault
     child:shortNameComponent
     size:{
        .width = IMAGE_SIZE, .height = IMAGE_SIZE
    }];
    
    CKImageComponent *avatarComponent =
    [CKImageComponent
     newWithImage:avatarImage
     attributes:{
        {@selector(setClipsToBounds:), @YES},
        {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), IMAGE_SIZE / 2.f}
    }
     size:{
        .width = IMAGE_SIZE, .height = IMAGE_SIZE
    }];
    
    CKOverlayLayoutComponent *overlayComponent =
    [CKOverlayLayoutComponent
     newWithComponent:avatarComponent
     overlay:centerTextComponent];
    
    CKInsetComponent *insetRemoveButton =
    [CKInsetComponent
     newWithInsets:UIEdgeInsetsMake(0, INFINITY, INFINITY, 0)
     component:removeButtonComponent];
    
    CKOverlayLayoutComponent *overlayRemoveButtonComponent = nil;
    if (![[ImageCache instance] imageForKey:viewModel.identifier]) {
        overlayRemoveButtonComponent =
        [CKOverlayLayoutComponent
         newWithComponent:overlayComponent
         overlay:insetRemoveButton];
    } else {
        overlayRemoveButtonComponent =
        [CKOverlayLayoutComponent
         newWithComponent:avatarComponent
         overlay:insetRemoveButton];
    }
    
    CKPickerCollectionCellComponent *c = [super newWithComponent:overlayRemoveButtonComponent];
    [super newWithComponent:[CKCenterLayoutComponent
                             newWithCenteringOptions:CKCenterLayoutComponentCenteringXY
                             sizingOptions:CKCenterLayoutComponentSizingOptionDefault
                             child:overlayRemoveButtonComponent
                             size:{ .width = IMAGE_SIZE, .height = IMAGE_SIZE + 10 }]];
    
    if (c) {
        c.avatarImageComponent = avatarComponent;
        c.nameLabelComponent = shortNameComponent;
        c.removeButtonComponent = removeButtonComponent;
        c.model = viewModel;
        c.context = context;
    }
    
    return c;
}

+ (id)initialState {
    return @NO;
}

+ (UIImage *)imageByColorCode:(int)colorCode {
    UIImage *avatarImage = [[UIImage alloc] init];
    switch (colorCode) {
        case GRADIENT_COLOR_BLUE:
            avatarImage = [UIImage imageNamed:@"gradientBlue"];
            break;
        case GRADIENT_COLOR_RED:
            avatarImage = [UIImage imageNamed:@"gradientRed"];
            break;
        case GRADIENT_COLOR_ORANGE:
            avatarImage = [UIImage imageNamed:@"gradientOrange"];
            break;
        case GRADIENT_COLOR_GREEN:
            avatarImage = [UIImage imageNamed:@"gradientGreen"];
            break;
    }
    return avatarImage;
}

- (void)removeButtonTapped {
    if (self.context && self.context.delegate &&
        [self.context.delegate respondsToSelector:@selector(collectionView:removeElement:)]) {
        [self.context.delegate collectionView:self.context
                                removeElement:self.model];
        
        [self.context removeElement:self.model];
    }
}

@end
