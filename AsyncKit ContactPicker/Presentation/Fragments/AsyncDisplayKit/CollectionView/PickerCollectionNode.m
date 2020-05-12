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

static NSString *kReuseIdentifier = @"PickerCollectionViewCell";

@interface PickerCollectionNode () <ASCollectionDelegate, ASCollectionDataSource, ASCollectionViewLayoutInspecting, PickerCollectionCellNodeDelegate>

@property (nonatomic, strong) ASCollectionNode *collectionNode;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) ASButtonNode *nextButton;
@property (nonatomic, strong) ASDisplayNode *nextButtonContainer;

@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *models;
@property (nonatomic, strong) NSCache<NSString *, UIImage *> *imageCache;

@property (nonatomic, assign) float avatarCollectionImageHeight;

@end

@implementation PickerCollectionNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.automaticallyManagesSubnodes = YES;
        
        self.shadowRadius = 3;
        self.shadowOffset = CGSizeZero;
        self.shadowColor = [UIColor blackColor].CGColor;
        self.shadowOpacity = 0.3;
        
        _avatarCollectionImageHeight = [UIScreen mainScreen].bounds.size.width / 7.f;
        
        _models = [[NSMutableArray alloc] init];
        _imageCache = [[NSCache alloc] init];
        
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(_avatarCollectionImageHeight, _avatarCollectionImageHeight);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 10;
        
        _collectionNode = [[ASCollectionNode alloc] initWithCollectionViewLayout:_flowLayout];
        _collectionNode.delegate = self;
        _collectionNode.dataSource = self;
        _collectionNode.layoutInspector = self;
        _collectionNode.backgroundColor = [UIColor whiteColor];
        _collectionNode.showsHorizontalScrollIndicator = NO;
        
        _nextButtonContainer = [[ASDisplayNode alloc] init];
        _nextButtonContainer.backgroundColor = [UIColor whiteColor];
        _nextButtonContainer.alpha = 0.8;
        
        _nextButton = [[ASButtonNode alloc] init];
        [_nextButton setTitle:@"→"
                     withFont:[UIFont boldSystemFontOfSize:30]
                    withColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
        _nextButton.contentVerticalAlignment = ASVerticalAlignmentCenter;
        _nextButton.contentHorizontalAlignment = ASHorizontalAlignmentMiddle;
        [_nextButton setBackgroundColor:[UIColor colorWithRed:52/255.f
                                                        green:152/255.f
                                                         blue:219/255.f
                                                        alpha:1]];
        _nextButton.cornerRadius = _avatarCollectionImageHeight / 2.f;
        [_nextButton addTarget:self
                        action:@selector(nextButtonTapped)
              forControlEvents:ASControlNodeEventTouchUpInside];
        _nextButton.shadowOffset = CGSizeMake(-1, -1);
        _nextButton.shadowRadius = 1;
        _nextButton.shadowColor = [UIColor blackColor].CGColor;
        _nextButton.shadowOpacity = 0.3;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    _nextButton.style.preferredSize = CGSizeMake(_avatarCollectionImageHeight, _avatarCollectionImageHeight);
    _nextButtonContainer.style.preferredSize = CGSizeMake(_avatarCollectionImageHeight + 20, self.view.bounds.size.height);
    _collectionNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width,
                                                     _avatarCollectionImageHeight + 30);
    _collectionNode.contentInset = UIEdgeInsetsMake(0, 15, 0, _nextButtonContainer.style.preferredSize.width);
    
    ASOverlayLayoutSpec *overlayNextButton = [ASOverlayLayoutSpec
                                              overlayLayoutSpecWithChild:_nextButtonContainer
                                              overlay:[ASCenterLayoutSpec
                                                       centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                                       sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                       child:_nextButton]];
    
    ASStackLayoutSpec *mainStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                                                           spacing:-_nextButtonContainer.style.preferredSize.width
                                                                    justifyContent:ASStackLayoutJustifyContentStart
                                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                                          children:@[_collectionNode, overlayNextButton]];
    
    ASCenterLayoutSpec *centerSpec = [ASCenterLayoutSpec
                                      centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringY
                                      sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                      child:mainStack];
    
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero
                                                  child:centerSpec];
}

- (void)didLoad {
    [super didLoad];
}

#pragma mark - SetData

- (void)addElement:(PickerViewModel *)pickerModel withImage:(UIImage * _Nullable)image {
    if (self.models.count == MAX_PICK)
        return;
    
    if (!pickerModel)
        return;
    
    if (self.hidden)
        [self show];
    
    [self.collectionNode performBatchUpdates:^{
        [self.models addObject:pickerModel];
        if (image) {
            [self.imageCache setObject:image
                                forKey:pickerModel.identifier];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.models.count - 1
                                                    inSection:0];
        [self.collectionNode insertItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
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
        if (self.models.count == 0) {
            [self hide];
        }
        [self layoutIfNeeded];
    }];
}

- (void)removeAllElements {
    [self.models removeAllObjects];
    [self hide];
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
        UIImage *avatar = [self.imageCache objectForKey:model.identifier];
        if (avatar) {
            [cellNode setUpImageForCell:avatar];
        }
        
        return cellNode;
    };
    
    return cellNodeBlock;
}


#pragma mark - ASCollectionDelegate

- (ASSizeRange)collectionNode:(ASCollectionNode *)collectionNode
constrainedSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return ASSizeRangeMake(CGSizeMake(_avatarCollectionImageHeight, _avatarCollectionImageHeight));
}

#pragma mark - ASCollectionViewLayoutInspecting

- (ASSizeRange)collectionView:(ASCollectionView *)collectionView
constrainedSizeForNodeAtIndexPath:(NSIndexPath *)indexPath {
    return ASSizeRangeMake(CGSizeMake(_avatarCollectionImageHeight, _avatarCollectionImageHeight));
}

- (ASScrollDirection)scrollableDirections {
    return ASScrollDirectionHorizontalDirections;
}

#pragma mark - PickerCollectionCellNodeDelegateProtocol

- (void)collectionCellNode:(PickerCollectionCellNode *)node
removeButtonTappedAtElement:(PickerViewModel *)element {
#if DEBUG
    assert(element);
#endif
    
    if (!element)
        return;
    
    [self removeElement:element];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionNode:removeElement:)]) {
        [self.delegate collectionNode:self removeElement:element];
    }
}


#pragma mark - Action

- (void)nextButtonTapped {
    
}

- (void)show {
    self.hidden = NO;
    self.alpha = 0;
    self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, self.view.frame.size.height);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
        self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, -self.view.frame.size.height);
    } completion:^(BOOL finished) {
        self.view.transform = CGAffineTransformIdentity;
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
