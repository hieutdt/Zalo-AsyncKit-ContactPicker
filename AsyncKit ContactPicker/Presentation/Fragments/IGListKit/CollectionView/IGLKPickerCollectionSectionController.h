//
//  IGLKPickerCollectionSectionController.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <IGListKit/IGListKit.h>

#import "PickerViewModel.h"
#import "IGLKPickerCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@class IGLKPickerCollectionSectionController;

@protocol IGLKPickerCollectionSectionControllerDelegate <NSObject>

- (void)sectionController:(IGLKPickerCollectionSectionController *)sectionController
               removeItem:(PickerViewModel *)model;

@end

@interface IGLKPickerCollectionSectionController : IGListBindingSectionController <IGListBindingSectionControllerDataSource>

@property (nonatomic, assign) id<IGLKPickerCollectionSectionControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
