//
//  PickerCollectionNode.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/16/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerCollectionNode.h"
#import "PickerCollectionCellNode.h"
#import "AppConsts.h"

#define NEXT_BUTTON_HEIGHT 60

static NSString *kReuseIdentifier = @"PickerCollectionViewCell";

@interface PickerCollectionNode () <ASCollectionDelegate, ASCollectionDataSource, ASCollectionViewLayoutInspecting, PickerCollectionCellNodeDelegate>

@property (nonatomic, strong) ASCollectionNode *collectionNode;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) ASButtonNode *nextButton;

@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *models;
@property (nonatomic, strong) NSCache<NSString *, UIImage *> *imageCache;

@end

@implementation PickerCollectionNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        
        self.automaticallyManagesSubnodes = YES;
        
        _models = [[NSMutableArray alloc] init];
        _imageCache = [[NSCache alloc] init];
        
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(80, 100);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionNode = [[ASCollectionNode alloc] initWithCollectionViewLayout:_flowLayout];
        _collectionNode.delegate = self;
        _collectionNode.dataSource = self;
        _collectionNode.layoutInspector = self;
        _collectionNode.backgroundColor = [UIColor redColor];
        
        _nextButton = [[ASButtonNode alloc] init];
        [_nextButton setTitle:@">"
                     withFont:[UIFont systemFontOfSize:30]
                    withColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
        _nextButton.contentVerticalAlignment = ASVerticalAlignmentCenter;
        _nextButton.contentHorizontalAlignment = ASHorizontalAlignmentMiddle;
        [_nextButton setBackgroundColor:[UIColor blueColor]];
        _nextButton.cornerRadius = NEXT_BUTTON_HEIGHT / 2.f;
        [_nextButton addTarget:self
                        action:@selector(nextButtonTapped)
              forControlEvents:ASControlNodeEventTouchUpInside];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    _nextButton.style.preferredSize = CGSizeMake(NEXT_BUTTON_HEIGHT, NEXT_BUTTON_HEIGHT);
    
    CGSize maxConstrainedSize = constrainedSize.max;
    
    ASCenterLayoutSpec *centerNextButtonSpec = [ASCenterLayoutSpec
                                                centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringY
                                                sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                child:_nextButton];
    centerNextButtonSpec.style.layoutPosition = CGPointMake(maxConstrainedSize.width - 10 - NEXT_BUTTON_HEIGHT, 10);
    centerNextButtonSpec.style.preferredSize = CGSizeMake(NEXT_BUTTON_HEIGHT, AVATAR_IMAGE_HEIHGT + 20);
    
    _collectionNode.style.layoutPosition = CGPointMake(10, 10);
    _collectionNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width - 10 - NEXT_BUTTON_HEIGHT - 15, AVATAR_IMAGE_HEIHGT + 30);
    
    return [ASAbsoluteLayoutSpec absoluteLayoutSpecWithChildren:@[_collectionNode, centerNextButtonSpec]];
}

- (void)didLoad {
    [super didLoad];
}

#pragma mark - SetData

- (void)addElement:(PickerViewModel *)pickerModel withImage:( UIImage * _Nullable)image {
    if (self.models.count == MAX_PICK)
        return;
    
    if (!pickerModel)
        return;
    
    self.hidden = NO;
    
    [self.collectionNode performBatchUpdates:^{
        [self.models addObject:pickerModel];
        if (image) {
            [self.imageCache setObject:image forKey:pickerModel.identifier];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.models.count - 1
                                                    inSection:0];
        [self.collectionNode insertItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        [self scrollToBottom:self.collectionNode];
        [self layoutIfNeeded];
    }];
}

- (void)removeElement:(PickerViewModel *)pickerModel {
    if (!pickerModel)
        return;
    
    [self.collectionNode performBatchUpdates:^{
        NSUInteger indexInArray = [self.models indexOfObject:pickerModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexInArray inSection:0];
        
        [self.models removeObject:pickerModel];
        [self.imageCache removeObjectForKey:pickerModel.identifier];
        [self.collectionNode deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        self.hidden = (self.models.count == 0);
        [self layoutIfNeeded];
    }];
}

- (void)removeAllElements {
    [self.models removeAllObjects];
    self.hidden = YES;
    [self reloadData];
}

- (void)reloadData {
    [self.collectionNode reloadData];
}

#pragma mark - ASCollectionDataSource

- (NSInteger)numberOfSectionsInCollectionNode:(ASCollectionNode *)collectionNode {
    return 1;
}

- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode
     numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode
      nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.models.count)
        return nil;
    
    PickerViewModel *model = self.models[indexPath.row];
    
    __weak PickerCollectionNode *weakSelf = self;
    ASCellNode *(^cellNodeBlock)(void) = ^ASCellNode *() {
        PickerCollectionCellNode *cellNode = [[PickerCollectionCellNode alloc] init];
        [cellNode setUpPickerModelForCell:model];
        cellNode.delegate = weakSelf;
        return cellNode;
    };
    
    return cellNodeBlock;
}


#pragma mark - ASCollectionDelegate

- (ASSizeRange)collectionNode:(ASCollectionNode *)collectionNode
constrainedSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return ASSizeRangeMake(CGSizeMake(AVATAR_IMAGE_HEIHGT + 20, AVATAR_IMAGE_HEIHGT + 20));
}

#pragma mark - ASCollectionViewLayoutInspecting

- (ASSizeRange)collectionView:(ASCollectionView *)collectionView
constrainedSizeForNodeAtIndexPath:(NSIndexPath *)indexPath {
    return ASSizeRangeMake(CGSizeMake(AVATAR_IMAGE_HEIHGT + 20, AVATAR_IMAGE_HEIHGT + 20));
}

- (ASScrollDirection)scrollableDirections {
    return ASScrollDirectionHorizontalDirections;
}


#pragma mark - Action

- (void)nextButtonTapped {
    
}

- (void)scrollToBottom:(ASCollectionNode *)collectionNode {
    [collectionNode scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.models.count - 1 inSection:0]
                           atScrollPosition:UICollectionViewScrollPositionNone
                                   animated:true];
}

@end
