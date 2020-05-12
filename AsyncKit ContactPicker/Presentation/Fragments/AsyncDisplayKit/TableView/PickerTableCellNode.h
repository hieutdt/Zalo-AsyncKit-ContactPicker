//
//  PickerTableCellNode.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PickerTableCellNode;

@protocol PickerTableCellNodeDelegate <NSObject>

- (void)didSelectPickerCellNode:(PickerTableCellNode *)node;

@end

@interface PickerTableCellNode : ASCellNode

@property (nonatomic, assign) id<PickerTableCellNodeDelegate> delegate;

- (void)setName:(NSString *)name;
- (void)setAvatar:(UIImage *)avatarImage;
- (void)setGradientColorBackground:(int)colorCode;
- (void)setChecked:(BOOL)isChecked;

@end

NS_ASSUME_NONNULL_END
