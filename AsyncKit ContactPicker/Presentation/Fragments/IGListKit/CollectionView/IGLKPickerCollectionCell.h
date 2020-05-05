//
//  IGLKPickerCollectionCell.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IGListKit/IGListKit.h>

#import "PickerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IGLKPickerCollectionCellDelegate <NSObject>

@required
- (void)removeButtonTappedAtModel:(PickerViewModel *)model;

@end

@interface IGLKPickerCollectionCell : UICollectionViewCell <IGListBindable>

@property (nonatomic, assign) id<IGLKPickerCollectionCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
