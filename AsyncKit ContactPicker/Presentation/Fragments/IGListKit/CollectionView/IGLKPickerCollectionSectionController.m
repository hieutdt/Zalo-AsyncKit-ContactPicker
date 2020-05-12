//
//  IGLKPickerCollectionSectionController.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "IGLKPickerCollectionSectionController.h"

#import "PickerViewModel.h"
#import "IGLKPickerCollectionCell.h"
#import "AppConsts.h"

@interface IGLKPickerCollectionSectionController () <IGLKPickerCollectionCellDelegate>

@property (nonatomic, strong) PickerViewModel *currentModel;
@property (nonatomic, assign) float avatarImageHeight;

@end

@implementation IGLKPickerCollectionSectionController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataSource = self;
        self.inset = UIEdgeInsetsMake(0, 5, 0, 5);
        _avatarImageHeight = [UIScreen mainScreen].bounds.size.width / 7.f;
    }
    return self;
}

#pragma mark - IGListBindingSectionControllerDataSource

- (NSArray<id<IGListDiffable>> *)sectionController:(IGListBindingSectionController *)sectionController
                               viewModelsForObject:(id)object {
    if (!object)
        return nil;
    
    if ([object isKindOfClass:[PickerViewModel class]]) {
        _currentModel = (PickerViewModel *)object;
        return @[_currentModel];
    }
    
    return nil;
}

- (UICollectionViewCell<IGListBindable> *)sectionController:(IGListBindingSectionController *)sectionController
                                           cellForViewModel:(id)viewModel
                                                    atIndex:(NSInteger)index {
    IGLKPickerCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGLKPickerCollectionCell class]
                                                                   forSectionController:sectionController
                                                                                atIndex:index];
    cell.delegate = self;
    return cell;
}

- (CGSize)sectionController:(IGListBindingSectionController *)sectionController
           sizeForViewModel:(id)viewModel
                    atIndex:(NSInteger)index {
    return CGSizeMake(_avatarImageHeight, _avatarImageHeight);
}

#pragma mark - IGLKPickerCollectionCellDelegate

- (void)removeButtonTappedAtModel:(PickerViewModel *)model {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sectionController:removeItem:)]) {
        [self.delegate sectionController:self
                              removeItem:model];
    }
}

@end
