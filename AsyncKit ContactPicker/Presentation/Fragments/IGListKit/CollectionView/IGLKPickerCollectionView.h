//
//  IGLKPickerCollectionView.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IGListKit/IGListKit.h>
#import "PickerViewModel.h"
#import "IGLKPickerCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@class IGLKPickerCollectionView;

@protocol IGLKPickerCollectionViewDelegate <NSObject>

@required
- (void)collectionView:(IGLKPickerCollectionView *)collectionView
            removeItem:(PickerViewModel *)item;

@end

@interface IGLKPickerCollectionView : UIView

@property (nonatomic, strong) id<IGLKPickerCollectionViewDelegate> delegate;

- (void)addElement:(PickerViewModel *)element;

- (void)removeElement:(PickerViewModel *)element;

- (void)setViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
