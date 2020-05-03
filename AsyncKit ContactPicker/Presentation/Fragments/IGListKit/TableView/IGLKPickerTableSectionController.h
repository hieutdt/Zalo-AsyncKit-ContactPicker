//
//  IGLKPickerTableSectionController.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <IGListKit/IGListKit.h>

#import "PickerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IGLKPickerTableSectionControllerDelegate <NSObject>

@required
- (void)didSelectItemAtModel:(PickerViewModel *)model;

@end

@interface IGLKPickerTableSectionController : IGListBindingSectionController<PickerViewModel *> <IGListBindingSectionControllerDataSource>

@property (nonatomic, assign) id<IGLKPickerTableSectionControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
