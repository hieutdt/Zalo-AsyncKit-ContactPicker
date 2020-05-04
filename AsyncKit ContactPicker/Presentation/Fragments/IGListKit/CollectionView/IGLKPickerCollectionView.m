//
//  IGLKPickerCollectionView.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "IGLKPickerCollectionView.h"

#import "PickerViewModel.h"
#import "IGLKPickerCollectionSectionController.h"
#import "AppConsts.h"

@interface IGLKPickerCollectionView () <IGListAdapterDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *viewModels;

@end

@implementation IGLKPickerCollectionView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    self.backgroundColor = [UIColor whiteColor];
    
    _viewModels = [[NSMutableArray alloc] init];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                         collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:_collectionView];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_collectionView.heightAnchor constraintEqualToConstant:AVATAR_COLLECTION_IMAGE_HEIGHT + 20].active = YES;
    
    IGListAdapterUpdater *updater = [[IGListAdapterUpdater alloc] init];
    _adapter = [[IGListAdapter alloc] initWithUpdater:updater
                                       viewController:nil];
    _adapter.dataSource = self;
    _adapter.collectionView = _collectionView;
}

#pragma mark - PublicMethods

- (void)reloadData {
    [_adapter reloadDataWithCompletion:nil];
}

- (void)addElement:(PickerViewModel *)element {
    if (!element)
        return;
    
    [self.viewModels addObject:element];
    [self.adapter performUpdatesAnimated:YES completion:nil];
}

- (void)removeElement:(PickerViewModel *)element {
    if (!element)
        return;
    
    [self.viewModels removeObject:element];
    [self.adapter performUpdatesAnimated:YES completion:nil];
}

- (void)setViewController:(UIViewController *)vc {
    if (vc) {
        [_adapter setViewController:vc];
    }
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.viewModels;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter
              sectionControllerForObject:(id)object {
    IGLKPickerCollectionSectionController *sectionController = [[IGLKPickerCollectionSectionController alloc] init];
    return sectionController;
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
