//
//  CKPickerTableCellComponent.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/24/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "CKPickerTableCellComponent.h"
#import "CKPickerTableView.h"
#import "AppConsts.h"
#import "StringHelper.h"
#import "ImageCache.h"

#import <ComponentKit/CKComponentSubclass.h>

@interface CKPickerTableCellComponent ()

@property (nonatomic, strong) CKImageComponent *checkerImageComponent;
@property (nonatomic, strong) CKImageComponent *avatarImageComponent;
@property (nonatomic, strong) PickerViewModel *viewModel;
@property (nonatomic, assign) CKPickerTableView *context;

@end

@implementation CKPickerTableCellComponent

+ (instancetype)newWithPickerViewModel:(PickerViewModel *)viewModel
                               context:(CKPickerTableView *)context {
    CKComponentScope scope(self);
    if (viewModel.isChosen) {
        scope.replaceState(scope, @YES);
    } else {
        scope.replaceState(scope, @NO);
    }
    
    UIImage *avatarImage = [[ImageCache instance] imageForKey:viewModel.identifier];
    BOOL hasAvatar = NO;
    
    if (!avatarImage) {
        switch (viewModel.gradientColorCode) {
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
    } else {
        hasAvatar = YES;
    }
    
    UIImage *checkImage = [[UIImage alloc] init];
    if (viewModel.isChosen) {
        checkImage = [UIImage imageNamed:@"checked"];
    } else {
        checkImage = [UIImage imageNamed:@"uncheck"];
    }
    
    CKImageComponent *checkerImageComponent =
    [CKImageComponent
       newWithImage:checkImage
       attributes:{}
       size:{
        .height = 30, .width = 30
    }];
    
    CKLabelComponent *shortNameLabel =
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
    CKCenterLayoutComponent *centerTextComponent = nil;
    if (!hasAvatar) {
        centerTextComponent =
        [CKCenterLayoutComponent
         newWithCenteringOptions:CKCenterLayoutComponentCenteringXY
         sizingOptions:CKCenterLayoutComponentSizingOptionDefault
         child:shortNameLabel
         size:{
            .width = 60, .height = 60
        }];
    }
    
    CKImageComponent *avatarComponent =
    [CKImageComponent
    newWithImage:avatarImage
    attributes:{
        {@selector(setClipsToBounds:), @YES},
        {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 30}
    }
    size:{
        .height = 60, .width = 60
    }];
    
    CKFlexboxComponent *flexBoxComponent =
    [CKFlexboxComponent
     newWithView:{
        [UIView class],
        { CKComponentTapGestureAttribute(@selector(didTap)) }
    }
     size:{}
     style:{
        .direction = CKFlexboxDirectionRow,
        .justifyContent = CKFlexboxJustifyContentStart,
        .alignItems = CKFlexboxAlignItemsCenter,
        .padding = 10,
        .spacing = 15
    }
     children:{
        {checkerImageComponent},
        {[CKOverlayLayoutComponent
          newWithComponent:avatarComponent
          overlay:centerTextComponent]},
        { [CKLabelComponent
            newWithLabelAttributes:{
                .string = viewModel.name,
                .color = [UIColor darkTextColor],
                .font = [UIFont systemFontOfSize:18]
            }
            viewAttributes:{
                {@selector(setBackgroundColor:), [UIColor clearColor]},
                {@selector(setUserInteractionEnabled:), NO}
            }
            size:{}] }
    }];
    
    CKPickerTableCellComponent *c = [super newWithComponent:
                                     [CKInsetComponent newWithInsets:UIEdgeInsetsMake(10, 15, 15, 10)
                                                           component:flexBoxComponent]];
    
    if (c) {
        c.checkerImageComponent = checkerImageComponent;
        c.avatarImageComponent = avatarComponent;
        c.viewModel = viewModel;
        c.context = context;
    }
    
    return c;
}

+ (id)initialState {
    return @NO;
}

- (void)didTap {
    if (!self.viewModel.isChosen && self.context.selectedCount == MAX_PICK)
        return;
    
    [self updateState:^(id *oldState) {
        self.viewModel.isChosen = !self.viewModel.isChosen;
        if (self.viewModel.isChosen) {
            return @YES;
        } else {
            return @NO;
        }
    } mode:CKUpdateModeSynchronous];
    
    if (!self.viewModel.isChosen) {
        if (self.context && [self.context respondsToSelector:@selector(didSelectCellOfElement:)]) {
            [self.context didSelectCellOfElement:self.viewModel];
        }
    } else {
        if (self.context && [self.context respondsToSelector:@selector(didUnSelectCellOfElement:)]) {
            [self.context didUnSelectCellOfElement:self.viewModel];
        }
    }
}

- (UIImage *)getAvatarImage:(PickerViewModel *)viewModel {
    UIImage *avatarImage = [[ImageCache instance] imageForKey:viewModel.identifier];
    if (avatarImage)
        return avatarImage;
    
    switch (viewModel.gradientColorCode) {
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

- (void)setAvatar:(UIImage *)avatar {
    [self updateState:^(id *oldState) {
        self.viewModel.isChosen = !self.viewModel.isChosen;
        if (self.viewModel.isChosen) {
            return @YES;
        } else {
            return @NO;
        }
    } mode:CKUpdateModeSynchronous];
}

@end
