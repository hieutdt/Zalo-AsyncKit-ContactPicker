//
//  PickerCollectionCellNode.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/16/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "PickerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PickerCollectionCellNode;

@protocol PickerCollectionCellNodeDelegate <NSObject>

- (void)collectionCellNode:(PickerCollectionCellNode *)node removeButtonTappedAtElement:(PickerViewModel *)element;

@end

@interface PickerCollectionCellNode : ASCellNode

@property (nonatomic, assign) id<PickerCollectionCellNodeDelegate> delegate;

- (void)setUpPickerModelForCell:(PickerViewModel *)pickerModel;

- (void)setUpImageForCell:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
