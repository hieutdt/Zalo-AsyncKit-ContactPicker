//
//  PickerTableNode.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "PickerTableCellNode.h"
#import "PickerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PickerTableNode;

@protocol PickerTableNodeDelegate <NSObject>

- (void)pickerTableNode:(PickerTableNode *)tableNode loadImageToCellNode:(PickerTableCellNode *)cellNode
                                                             atIndexPath:(NSIndexPath *)indexPath;

- (void)pickerTableNode:(PickerTableNode *)tableNode checkedCellOfElement:(PickerViewModel *)element;

- (void)pickerTableNode:(PickerTableNode *)tableNode uncheckedCellOfElement:(PickerViewModel *)element;

@end

@interface PickerTableNode : ASDisplayNode

@property (nonatomic, strong) id<PickerTableNodeDelegate> delegate;

- (void)reloadData;

- (void)setViewModels:(NSArray<PickerViewModel *> *)pickerModels;

@end

NS_ASSUME_NONNULL_END
