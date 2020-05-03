//
//  CKPickerTableView.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/24/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "CKPickerTableView.h"
#import <ComponentKit/ComponentKit.h>

#import "PickerViewModel.h"

#import "CKPickerTableCellComponent.h"

#import "ImageCache.h"
#import "AppConsts.h"

static NSString * const kReuseIdentifier = @"componentKitPickerTableCell";

@interface CKPickerTableView () <CKComponentProvider, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CKCollectionViewDataSource *dataSource;
@property (nonatomic, strong) CKComponentFlexibleSizeRangeProvider *sizeRangeProvider;

@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *viewModels;
@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *searchModels;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *sectionsArray;
@property (nonatomic, assign) long selectedCount;
@property (nonatomic, assign) BOOL searching;

@end


@implementation CKPickerTableView

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

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    _viewModels = [[NSMutableArray alloc] init];
    _sectionsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++)
         [_sectionsArray addObject:[NSMutableArray new]];
    
    _selectedCount = 0;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                         collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    
    [self addSubview:_collectionView];
    
    _sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider
                          providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    
    const CKSizeRange sizeRange = [_sizeRangeProvider sizeRangeForBoundingSize:self.bounds.size];
    CKDataSourceConfiguration *configuration = [[CKDataSourceConfiguration<PickerViewModel *, CKPickerTableView *>
                                                 alloc]
                                                initWithComponentProviderFunc:pickerTableComponentProvider
                                                context:self
                                                sizeRange:sizeRange];
    
    _dataSource = [[CKCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                 supplementaryViewDataSource:nil
                                                               configuration:configuration];
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, ALPHABET_SECTIONS_NUMBER)];
    CKDataSourceChangeset *initialChangeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                                withInsertedSections:indexSet]
                                               build];
    
    [_dataSource applyChangeset:initialChangeset
                           mode:CKUpdateModeSynchronous
                       userInfo:nil];
}

- (void)enqueue:(NSMutableArray<NSMutableArray *> *)sections {
    NSMutableDictionary<NSIndexPath *, PickerViewModel *> *items = [NSMutableDictionary new];
    for (NSInteger i = 0; i < sections.count; i++) {
        for (NSInteger j = 0; j < sections[i].count; j++) {
            [items setObject:sections[i][j]
                      forKey:[NSIndexPath indexPathForItem:j inSection:i]];
        }
    }
    
    CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                         withInsertedItems:items]
                                        build];
    
    [_dataSource applyChangeset:changeset
                           mode:CKUpdateModeSynchronous
                       userInfo:nil];
}

- (void)setViewModels:(NSMutableArray<PickerViewModel *> *)viewModels {
    _viewModels = viewModels;
    [self fitPickerModelsData:_viewModels toSections:_sectionsArray];
    [self enqueue:self.sectionsArray];
}

- (void)fitPickerModelsData:(NSMutableArray<PickerViewModel*> *)models
                 toSections:(NSMutableArray<NSMutableArray*> *)sectionsArray {
#if DEBUG
    assert(sectionsArray);
    assert(sectionsArray.count == ALPHABET_SECTIONS_NUMBER);
#endif
    
    if (!models)
        return;
    if (!sectionsArray)
        return;
    
    for (int i = 0; i < sectionsArray.count; i++) {
        [sectionsArray[i] removeAllObjects];
    }
    
    for (int i = 0; i < models.count; i++) {
        int index = [models[i] getSectionIndex];
        
        if (index >= 0 && index < ALPHABET_SECTIONS_NUMBER - 1) {
            [sectionsArray[index] addObject:models[i]];
        } else {
            [sectionsArray[ALPHABET_SECTIONS_NUMBER - 1] addObject:models[i]];
        }
    }
}

- (long)selectedCount {
    return _selectedCount;
}

- (void)searchByString:(NSString *)searchString {
    if (!searchString) {
        self.searching = NO;
    } else if (searchString.length == 0) {
        self.searching = NO;
    } else {
        [_searchModels removeAllObjects];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@", searchString];
        _searchModels = [NSMutableArray arrayWithArray:[self.viewModels filteredArrayUsingPredicate:predicate]];
        self.searching = YES;
    }
    
    [self removeAllCells:self.sectionsArray];
    
    if (self.searching) {
        [self fitPickerModelsData:self.searchModels
                       toSections:self.sectionsArray];
    } else {
        [self fitPickerModelsData:self.viewModels
                       toSections:self.sectionsArray];
    }
    
    [self enqueue:self.sectionsArray];
}

- (void)removeAllCells:(NSMutableArray<NSMutableArray *> *)sections {
    NSMutableSet *removeSet = [[NSMutableSet alloc] init];
    for (NSInteger i = 0; i < sections.count; i++) {
        for (NSInteger j = 0; j < sections[i].count; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j
                                                        inSection:i];
            [removeSet addObject:indexPath];
        }
    }
    
    CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                         withRemovedItems:removeSet]
                                        build];
    
    [_dataSource applyChangeset:changeset
                           mode:CKUpdateModeSynchronous
                       userInfo:nil];
}

#pragma mark - CallBackFromCKPickerTableCellComponent

- (void)didSelectCellOfElement:(PickerViewModel *)element {
    if (!element)
        return;
    
    long index = [self.viewModels indexOfObject:element];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(CKPickerTableView:didSelectRowAtIndexPath:)]) {
        [self.delegate CKPickerTableView:self
                 didSelectRowAtIndexPath:indexPath];
    }
    
    _selectedCount++;
}

- (void)didUnSelectCellOfElement:(PickerViewModel *)element {
    if (!element)
        return;
    
    long index = [self.viewModels indexOfObject:element];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(CKPickerTableView:didUnSelectRowAtIndexPath:)]) {
        [self.delegate CKPickerTableView:self
               didUnSelectRowAtIndexPath:indexPath];
    }
    
    _selectedCount--;
}

- (void)unselectCellOfElement:(PickerViewModel *)element {
    if (!element)
        return;
    
    long section = [element getSectionIndex];
    if (section >= self.sectionsArray.count)
        return;
    
    long index = [self.sectionsArray[section] indexOfObject:element];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                inSection:section];
    
    element.isChosen = !element.isChosen;
    
    [self.collectionView performBatchUpdates:^{
        CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                             withUpdatedItems:@{ indexPath : element }]
                                            build];
        
        [_dataSource applyChangeset:changeset
                               mode:CKUpdateModeSynchronous
                           userInfo:nil];
        
        _selectedCount--;
        
    } completion:^(BOOL finished) {
        [self layoutIfNeeded];
    }];
}

- (void)loadImageToCellComponent:(CKPickerTableCellComponent *)cellComponent
                         element:(PickerViewModel *)element {
    if (!cellComponent || !element)
        return;
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(loadImageToCellComponent:atIndexPath:)]) {
        long index = [self.viewModels indexOfObject:element];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index
                                                     inSection:0];
        [self.delegate loadImageToCellComponent:cellComponent
                                    atIndexPath:indexPath];
    }
}

#pragma mark - CKComponentProvider

static CKComponent *pickerTableComponentProvider(PickerViewModel *model, CKPickerTableView *context) {
    return [CKPickerTableCellComponent newWithPickerViewModel:model
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

@end
