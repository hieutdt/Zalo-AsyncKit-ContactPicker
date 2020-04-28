//
//  CKPickerTableView.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/24/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class CKPickerTableView;

@protocol CKPickerTableViewDelegate <NSObject>

- (void)CKPickerTableView:(CKPickerTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CKPickerTableView : UIView

@property (nonatomic, assign) id<CKPickerTableViewDelegate> delegate;

- (void)setViewModels:(NSMutableArray<PickerViewModel *> *)viewModels;

- (void)reloadData;

- (void)didSelectCellOfElement:(PickerViewModel *)element;

@end

NS_ASSUME_NONNULL_END
