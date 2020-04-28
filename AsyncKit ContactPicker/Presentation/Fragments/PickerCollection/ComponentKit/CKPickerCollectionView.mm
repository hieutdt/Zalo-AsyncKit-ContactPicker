//
//  CKPickerCollectionView.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/28/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "CKPickerCollectionView.h"
#import "CKPickerCollectionCellComponent.h"
#import <ComponentKit/ComponentKit.h>

#import "PickerViewModel.h"
#import "ImageCache.h"

static NSString * const kReuseIdentifier = @"componentKitPickerCollectionCell";
static const int kMaxPick = 5;

@interface CKPickerCollectionView () <CKComponentProvider, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CKCollectionViewDataSource *dataSource;
@property (nonatomic, strong) CKComponentFlexibleSizeRangeProvider *sizeRangeProvider;

@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *viewModels;
@property (nonatomic, strong) NSCache<NSString *, UIImage *> *imageCache;

@end

@implementation CKPickerCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    _viewModels = [[NSMutableArray alloc] init];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                         collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    
    [self addSubview:_collectionView];
    
    _sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider
                          providerWithFlexibility:CKComponentSizeRangeFlexibleWidthAndHeight];
    
    const CKSizeRange sizeRange = [_sizeRangeProvider sizeRangeForBoundingSize:self.bounds.size];
    
    CKDataSourceConfiguration *configuration = [[CKDataSourceConfiguration<PickerViewModel *, ImageCache *> alloc]
                                                initWithComponentProviderFunc:pickerCollectionComponentProvider
                                                context:[ImageCache instance]
                                                sizeRange:sizeRange];
    
    _dataSource = [[CKCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                 supplementaryViewDataSource:nil
                                                               configuration:configuration];
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
    CKDataSourceChangeset *initialChangeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                                withInsertedSections:indexSet]
                                               build];
    
    [_dataSource applyChangeset:initialChangeset mode:CKUpdateModeAsynchronous userInfo:nil];
}

- (void)enqueue:(NSArray<PickerViewModel *> *)models {
    NSMutableDictionary<NSIndexPath *, PickerViewModel *> *items = [NSMutableDictionary new];
    for (NSInteger i = 0; i < models.count; i++) {
        [items setObject:models[i] forKey:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    
    CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                         withInsertedItems:items]
                                        build];
    
    [_dataSource applyChangeset:changeset mode:CKUpdateModeSynchronous userInfo:nil];
}

- (void)dequeue:(NSArray<PickerViewModel *> *)models {
    NSMutableArray *removeItems = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < models.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [removeItems addObject:@{indexPath : models[i]}];
    }
    
    CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                         withRemovedItems:[NSSet setWithArray:removeItems]]
                                        build];
    
    [_dataSource applyChangeset:changeset mode:CKUpdateModeSynchronous userInfo:nil];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - PublicMethods

- (void)addElement:(PickerViewModel *)pickerModel withImage:(UIImage *)image {
    if (self.viewModels.count == kMaxPick)
        return;
    
    if (!pickerModel)
        return;
    
    self.hidden = NO;
    
    [self.collectionView performBatchUpdates:^{
        [self.viewModels addObject:pickerModel];
        [self enqueue:@[pickerModel]];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.viewModels.count - 1
                                                     inSection:0];
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        [self scrollToBottom:self.collectionView];
        [self layoutIfNeeded];
    }];
}

- (void)removeElement:(PickerViewModel *)pickerModel {
    if (!pickerModel)
        return;
    
    [self.collectionView performBatchUpdates:^{
        long index = [self.viewModels indexOfObject:pickerModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [self.viewModels removeObject:pickerModel];
        [self dequeue:@[pickerModel]];
        
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        [self layoutIfNeeded];
    }];
}

#pragma mark - CKComponentProvider

static CKComponent *pickerCollectionComponentProvider(PickerViewModel *model, ImageCache *context) {
    return [CKPickerCollectionCellComponent newWithPickerViewModel:model
                                                           context:context];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource sizeForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_dataSource announceWillDisplayCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_dataSource announceDidEndDisplayingCell:cell];
}

#pragma mark - Action

- (void)scrollToBottom:(UICollectionView *)collectionView {
    [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.viewModels.count - 1 inSection:0]
                           atScrollPosition:UICollectionViewScrollPositionNone
                                   animated:true];
}

@end
