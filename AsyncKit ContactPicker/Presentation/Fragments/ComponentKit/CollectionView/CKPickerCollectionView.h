//
//  CKPickerCollectionView.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/28/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class CKPickerCollectionView;

@protocol CKPickerCollectionViewDelegate <NSObject>

- (void)collectionView:(CKPickerCollectionView *)collectionView
         removeElement:(PickerViewModel *)element;

- (void)nextButtonTappedFromCKPickerCollectionView:(CKPickerCollectionView *)collectionView;

@end

@interface CKPickerCollectionView : UIView

@property (nonatomic, assign) id<CKPickerCollectionViewDelegate> delegate;

- (void)addElement:(PickerViewModel *)pickerModel withImage:(UIImage * _Nullable)image;

- (void)removeElement:(PickerViewModel *)pickerModel;

- (void)removeAllElements;

@end

NS_ASSUME_NONNULL_END
