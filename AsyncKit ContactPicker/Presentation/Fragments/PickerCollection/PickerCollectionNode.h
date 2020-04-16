//
//  PickerCollectionNode.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/16/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "PickerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PickerCollectionNode;

@protocol PickerCollectionNodeDelegate <NSObject>

- (void)collectionNode:(PickerCollectionNode *)collectionNode removeElement:(PickerViewModel *)element;

- (void)nextButtonTappedFromPickerCollectionNode:(PickerCollectionNode *)collectionNode;

@end

@interface PickerCollectionNode : ASDisplayNode

@property (nonatomic, assign) id<PickerCollectionNodeDelegate> delegate;

- (void)addElement:(PickerViewModel *)pickerModel withImage:(UIImage *)image;
- (void)removeElement:(PickerViewModel *)pickerModel;
- (void)removeAllElements;

@end

NS_ASSUME_NONNULL_END
