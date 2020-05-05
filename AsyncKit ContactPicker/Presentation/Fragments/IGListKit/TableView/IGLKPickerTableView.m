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
#import "AppConsts.h"

@interface IGLKPickerTableView () <IGListAdapterDataSource, IGLKPickerTableSectionControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *viewModels;
@property (nonatomic, assign) int selectedCount;

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
    
    _selectedCount = 0;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                         collectionViewLayout:flowLayout];
    [self addSubview:_collectionView];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
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

- (void)uncheckModel:(PickerViewModel *)model {
    if (!model)
        return;
    self.selectedCount--;
    model.isChosen = NO;
    [_adapter reloadObjects:@[model]];
}


#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.viewModels;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter
              sectionControllerForObject:(id)object {
    IGLKPickerTableSectionController *sectionController =  [[IGLKPickerTableSectionController alloc] init];
    sectionController.delegate = self;
    return sectionController;
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}


#pragma mark - IGLKPickerTableSectionControllerDelegate

- (void)didSelectItemAtModel:(PickerViewModel *)model {
    if (!model)
        return;
    
    if (![self.viewModels containsObject:model])
        return;
    
    long index = [self.viewModels indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                inSection:0];
    if (!model)
        return;
    
    if (model.isChosen) {
        self.selectedCount--;
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(pickerTableView:uncheckedCellAtIndexPath:)]) {
            [self.delegate pickerTableView:self
                  uncheckedCellAtIndexPath:indexPath];
        }
    } else if (self.selectedCount < MAX_PICK) {
        self.selectedCount++;
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(pickerTableView:checkedCellAtIndexPath:)]) {
            [self.delegate pickerTableView:self
                    checkedCellAtIndexPath:indexPath];
        }
    } else {
        return;
    }
    
    model.isChosen = !model.isChosen;
    [self.adapter reloadObjects:@[model]];
}

@end
