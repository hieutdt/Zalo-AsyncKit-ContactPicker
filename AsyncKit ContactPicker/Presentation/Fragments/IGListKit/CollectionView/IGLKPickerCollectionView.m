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

@interface IGLKPickerCollectionView () <IGListAdapterDataSource, IGLKPickerCollectionSectionControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *nextButton;

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
    self.layer.shadowRadius = 3;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.3;
    
    _viewModels = [[NSMutableArray alloc] init];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                         collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:_collectionView];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5].active = YES;
    [_collectionView.heightAnchor constraintEqualToConstant:AVATAR_COLLECTION_IMAGE_HEIGHT + 20].active = YES;
    
    IGListAdapterUpdater *updater = [[IGListAdapterUpdater alloc] init];
    _adapter = [[IGListAdapter alloc] initWithUpdater:updater
                                       viewController:nil];
    _adapter.dataSource = self;
    _adapter.collectionView = _collectionView;
    
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
    _nextButton.layer.cornerRadius = NEXT_BUTTON_HEIGHT / 2;

    [self addSubview:_nextButton];
        
    _nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_nextButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5].active = YES;
    [_nextButton.centerYAnchor constraintEqualToAnchor:_collectionView.centerYAnchor].active = YES;
    [_nextButton.heightAnchor constraintEqualToConstant:NEXT_BUTTON_HEIGHT].active = YES;
    [_nextButton.widthAnchor constraintEqualToConstant:NEXT_BUTTON_HEIGHT].active = YES;
    [_nextButton.leadingAnchor constraintEqualToAnchor:_collectionView.trailingAnchor constant:5].active = YES;
}

#pragma mark - PublicMethods

- (void)reloadData {
    [_adapter reloadDataWithCompletion:nil];
}

- (void)addElement:(PickerViewModel *)element {
    if (!element)
        return;
    
    if (self.hidden) {
        [self show];
    }
    
    [self.viewModels addObject:element];
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        [self scrollToBottom:self.collectionView];
    }];
}

- (void)removeElement:(PickerViewModel *)element {
    if (!element)
        return;
    
    [self.viewModels removeObject:element];
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        if (finished) {
            if (self.viewModels.count == 0)
                [self hide];
        }
    }];
}

- (void)setViewController:(UIViewController *)vc {
    if (vc) {
        [_adapter setViewController:vc];
    }
}

- (void)removeAllElements {
    [self.viewModels removeAllObjects];
    [self reloadData];
    [self hide];
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.viewModels;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter
              sectionControllerForObject:(id)object {
    IGLKPickerCollectionSectionController *sectionController = [[IGLKPickerCollectionSectionController alloc] init];
    sectionController.delegate = self;
    return sectionController;
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

#pragma mark - IGLKPickerCollectionSectionControllerDelegate

- (void)sectionController:(IGLKPickerCollectionSectionController *)sectionController
               removeItem:(PickerViewModel *)model {
    if (!sectionController || !model)
        return;
    
    [self.viewModels removeObject:model];
    [self.adapter performUpdatesAnimated:YES
                              completion:^(BOOL finished) {
        if (finished) {
            if (self.viewModels.count == 0)
                [self hide];
        }
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:removeItem:)]) {
        [self.delegate collectionView:self
                           removeItem:model];
    }
}

#pragma mark - Action

- (void)scrollToBottom:(UICollectionView *)collectionView {
    [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0
                                                                inSection:collectionView.numberOfSections - 1]
                           atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                   animated:YES];
}

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
