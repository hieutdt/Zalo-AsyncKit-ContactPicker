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

@interface IGLKPickerCollectionSectionController ()

@property (nonatomic, strong) PickerViewModel *currentModel;

@end

@implementation IGLKPickerCollectionSectionController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataSource = self;
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
    return cell;
}

- (CGSize)sectionController:(IGListBindingSectionController *)sectionController
           sizeForViewModel:(id)viewModel
                    atIndex:(NSInteger)index {
    return CGSizeMake(AVATAR_COLLECTION_IMAGE_HEIGHT + 5, AVATAR_COLLECTION_IMAGE_HEIGHT + 10);
}

@end
