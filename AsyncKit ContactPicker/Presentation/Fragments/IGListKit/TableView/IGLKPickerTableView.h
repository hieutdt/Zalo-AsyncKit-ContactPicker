//
//  IGLKPickerTableView.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface IGLKPickerTableView : UIView

- (void)setViewModels:(NSMutableArray<PickerViewModel *> *)viewModels;

- (void)reloadData;

- (void)setViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
