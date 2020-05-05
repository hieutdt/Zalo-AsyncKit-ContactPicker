//
//  IGLKPickerTableView.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerViewModel.h"
#import "IGLKPickerTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@class IGLKPickerTableView;

@protocol IGLKPickerTableViewDelegate <NSObject>

- (void)pickerTableView:(IGLKPickerTableView *)tableView
     checkedCellOfModel:(PickerViewModel *)model;

- (void)pickerTableView:(IGLKPickerTableView *)tableView
   uncheckedCellOfModel:(PickerViewModel *)model;

- (void)pickerTableView:(IGLKPickerTableView *)tableView
        loadImageToCell:(IGLKPickerTableCell *)cell
                ofModel:(PickerViewModel *)model;

@end

@interface IGLKPickerTableView : UIView

@property (nonatomic, assign) id<IGLKPickerTableViewDelegate> delegate;

- (void)setViewModels:(NSMutableArray<PickerViewModel *> *)viewModels;

- (void)reloadData;

- (void)reloadModel:(PickerViewModel *)model;

- (void)setViewController:(UIViewController *)vc;

- (void)uncheckModel:(PickerViewModel *)model;

@end

NS_ASSUME_NONNULL_END
