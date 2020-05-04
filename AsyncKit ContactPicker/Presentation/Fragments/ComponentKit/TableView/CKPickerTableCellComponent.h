//
//  CKPickerTableCellComponent.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/24/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "PickerViewModel.h"
#import "ImageCache.h"

NS_ASSUME_NONNULL_BEGIN

@class CKPickerTableView;

@interface CKPickerTableCellComponent : CKCompositeComponent

+ (instancetype)newWithPickerViewModel:(PickerViewModel *)viewModel
                               context:(CKPickerTableView *)context;

- (void)setAvatar:(UIImage * _Nonnull)avatar;

@end

NS_ASSUME_NONNULL_END
