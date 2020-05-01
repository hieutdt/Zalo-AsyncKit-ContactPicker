//
//  CKPickerCollectionCellComponent.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "PickerViewModel.h"
#import "ImageCache.h"

@class CKPickerCollectionView;

NS_ASSUME_NONNULL_BEGIN

@interface CKPickerCollectionCellComponent : CKCompositeComponent

+ (instancetype)newWithPickerViewModel:(PickerViewModel *)viewModel
                               context:(CKPickerCollectionView *)context;

@end

NS_ASSUME_NONNULL_END
