//
//  IGLKPickerTableSectionController.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <IGListKit/IGListKit.h>

#import "PickerViewModel.h"
#import "IGLKPickerTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@class IGLKPickerTableSectionController;

@protocol IGLKPickerTableSectionControllerDelegate <NSObject>

@required
- (void)sectionController:(IGLKPickerTableSectionController *)sectionController
     didSelectItemAtModel:(PickerViewModel *)model;

- (void)sectionController:(IGLKPickerTableSectionController *)sectionController
          loadImageToCell:(IGLKPickerTableCell *)cell
                  atIndex:(NSInteger)index;

@end

@interface IGLKPickerTableSectionController : IGListBindingSectionController<PickerViewModel *> 

@property (nonatomic, assign) id<IGLKPickerTableSectionControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
