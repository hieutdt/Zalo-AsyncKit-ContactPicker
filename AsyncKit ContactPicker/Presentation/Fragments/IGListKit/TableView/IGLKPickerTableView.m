//
//  IGLKPickerTableView.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "IGLKPickerTableView.h"
#import <IGListKit/IGListKit.h>

#import "PickerViewModel.h"
#import "IGLKPickerTableSectionController.h"

@interface IGLKPickerTableView () <IGListAdapterDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *viewModels;

@end

@implementation IGLKPickerTableView

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
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                         collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor systemRedColor];
    [self addSubview:_collectionView];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    IGListAdapterUpdater *updater = [[IGListAdapterUpdater alloc] init];
    _adapter = [[IGListAdapter alloc] initWithUpdater:updater
                                       viewController:nil];
    _adapter.dataSource = self;
    [_adapter setCollectionView:self.collectionView];
    
    _viewModels = [[NSMutableArray alloc] init];
}

#pragma mark - PublicMethods

- (void)setViewModels:(NSMutableArray<PickerViewModel *> *)viewModels {
    _viewModels = viewModels;
}

- (void)reloadData {
    [_adapter reloadDataWithCompletion:^(BOOL finished) {
        
    }];
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
    return [[IGLKPickerTableSectionController alloc] init];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
