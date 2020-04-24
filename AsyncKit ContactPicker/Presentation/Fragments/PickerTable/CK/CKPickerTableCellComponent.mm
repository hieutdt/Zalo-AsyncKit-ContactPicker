//
//  CKPickerTableCellComponent.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/24/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "CKPickerTableCellComponent.h"
#import "AppConsts.h"
#import "ImageHelper.h"

@interface CKPickerTableCellComponent ()

@end

@implementation CKPickerTableCellComponent

+ (instancetype)newWithPickerViewModel:(PickerViewModel *)viewModel
                               context:(ImageCache *)context {
    CKComponentScope scope(self);
    
    UIImage *avatarImage = [[UIImage alloc] init];
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
    
    avatarImage = [ImageHelper makeRoundedImage:avatarImage radius:30.f];
    
    CKPickerTableCellComponent *c = [super newWithComponent:
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
        { [CKImageComponent
           newWithImage:[UIImage imageNamed:@"uncheck"]
           attributes:{}
           size:{
            .height = 25, .width = 25
        }] },
        { [CKImageComponent
           newWithImage:avatarImage
           attributes:{}
           size:{
            .height = 60, .width = 60
        }] },
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
    }]];
    
    return c;
}

- (void)didTap {
    NSLog(@"Did tappppppppppp");
}

@end
