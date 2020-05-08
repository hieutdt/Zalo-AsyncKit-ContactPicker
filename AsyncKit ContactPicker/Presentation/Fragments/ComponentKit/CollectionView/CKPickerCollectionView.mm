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
#import "AppConsts.h"

static NSString * const kReuseIdentifier = @"componentKitPickerCollectionCell";
static const int kMaxPick = 5;

@interface CKPickerCollectionView () <CKComponentProvider, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIView *nextButtonContainer;
@property (nonatomic, strong) CKCollectionViewDataSource *dataSource;
@property (nonatomic, strong) CKComponentFlexibleSizeRangeProvider *sizeRangeProvider;

@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *viewModels;

@property (nonatomic, assign) float nextButtonHeight;

@end

@implementation CKPickerCollectionView

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
    self.layer.shadowRadius = 3;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.3;
    
    _nextButtonHeight = [UIScreen mainScreen].bounds.size.width / 7.f;
    
    _viewModels = [[NSMutableArray alloc] init];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.minimumLineSpacing = 10;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                         collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, _nextButtonHeight + 20);
    
    [self addSubview:_collectionView];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                  constant:5].active = YES;
    [_collectionView.heightAnchor constraintEqualToConstant:100].active = YES;
    [_collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    
    _nextButtonContainer = [[UIView alloc] init];
    _nextButtonContainer.backgroundColor = [UIColor whiteColor];
    _nextButtonContainer.alpha = 0.7;
    
    [self addSubview:_nextButtonContainer];
    _nextButtonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [_nextButtonContainer.heightAnchor constraintEqualToConstant:self.bounds.size.height].active = YES;
    [_nextButtonContainer.widthAnchor constraintEqualToConstant:_nextButtonHeight + 20].active = YES;
    [_nextButtonContainer.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    _nextButton = [[UIButton alloc] init];
    [_nextButton setTitle:@"→" forState:UIControlStateNormal];
    _nextButton.titleLabel.textColor = [UIColor whiteColor];
    _nextButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_nextButton setBackgroundColor:[UIColor colorWithRed:52/255.f
                                                    green:152/255.f
                                                     blue:219/255.f
                                                    alpha:1]];
    [_nextButton.titleLabel setFont:[UIFont boldSystemFontOfSize:30]];
    _nextButton.layer.cornerRadius = _nextButtonHeight / 2;
    
    [self addSubview:_nextButton];
    
    _nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_nextButton.widthAnchor constraintEqualToConstant:_nextButtonHeight].active = YES;
    [_nextButton.heightAnchor constraintEqualToConstant:_nextButtonHeight].active = YES;
    [_nextButton.centerYAnchor constraintEqualToAnchor:_nextButtonContainer.centerYAnchor].active = YES;
    [_nextButton.centerXAnchor constraintEqualToAnchor:_nextButtonContainer.centerXAnchor].active = YES;
    
    _sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider
                          providerWithFlexibility:CKComponentSizeRangeFlexibleWidthAndHeight];
    
    const CKSizeRange sizeRange = [_sizeRangeProvider sizeRangeForBoundingSize:self.bounds.size];
    
    CKDataSourceConfiguration *configuration = [[CKDataSourceConfiguration<PickerViewModel *, CKPickerCollectionView *> alloc]
                                                initWithComponentProviderFunc:pickerCollectionComponentProvider
                                                context:self
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
        [items setObject:models[i] forKey:[NSIndexPath indexPathForItem:self.viewModels.count + i - 1
                                                              inSection:0]];
    }
    
    CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                         withInsertedItems:items]
                                        build];
    
    [_dataSource applyChangeset:changeset mode:CKUpdateModeSynchronous userInfo:nil];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - PublicMethods

- (void)addElement:(PickerViewModel *)pickerModel
         withImage:(UIImage *)image {
    if (self.viewModels.count == kMaxPick)
        return;
    
    if (!pickerModel)
        return;
    
    if (self.hidden) {
        [self show];
    }
    
    [self.collectionView performBatchUpdates:^{
        [self.viewModels addObject:pickerModel];
        [self enqueue:@[pickerModel]];
        
    } completion:^(BOOL finished) {
        [self layoutIfNeeded];
    }];
}

- (void)removeElement:(PickerViewModel *)pickerModel {
    if (!pickerModel)
        return;
    
    [self.collectionView performBatchUpdates:^{
        long index = [self.viewModels indexOfObject:pickerModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index
                                                     inSection:0];
        
        [self.viewModels removeObject:pickerModel];
        if (self.viewModels.count == 0)
            [self hide];
        
        // Delete in datasource
        CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                             withRemovedItems:[NSSet setWithObject:indexPath]]
                                            build];
        [_dataSource applyChangeset:changeset
                               mode:CKUpdateModeSynchronous
                           userInfo:nil];
        
    } completion:^(BOOL finished) {
        [self layoutIfNeeded];
    }];
}

- (void)removeAllElements {
    NSMutableSet *set = [[NSMutableSet alloc] init];
    for (int i = 0; i < self.viewModels.count; i++) {
        [set addObject:[NSIndexPath indexPathForItem:i
                                           inSection:0]];
    }
    
    CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                         withRemovedItems:set]
                                        build];
    [_dataSource applyChangeset:changeset
                           mode:CKUpdateModeSynchronous
                       userInfo:nil];
    
    [self hide];
}

#pragma mark - CKComponentProvider

static CKComponent *pickerCollectionComponentProvider(PickerViewModel *model, CKPickerCollectionView *context) {
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

- (void)show {
    self.hidden = NO;
    self.alpha = 0;
    self.transform = CGAffineTransformTranslate(self.transform, 0, self.frame.size.height);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformTranslate(self.transform, 0, -self.frame.size.height);
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)hide {
    self.alpha = 1;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.hidden = YES;
    }];
}

@end
