//
//  PickerTableNode.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerTableNode.h"
#import "PickerTableCellNode.h"

#import "PickerViewModel.h"
#import "AppConsts.h"

@interface PickerTableNode () <ASTableDelegate, ASTableDataSource, PickerTableCellNodeDelegate>

@property (nonatomic, strong) ASTableNode *tableNode;

@property (strong, nonatomic) NSMutableArray<PickerViewModel *> *pickerModels;
@property (strong, nonatomic) NSMutableArray<PickerViewModel *> *searchPickerModels;
@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *sectionsArray;

@property (nonatomic, assign) int selectedCount;
@property (nonatomic, assign) BOOL searching;

@end

@implementation PickerTableNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _tableNode = [[ASTableNode alloc] initWithStyle:UITableViewStylePlain];
        _tableNode.dataSource = self;
        _tableNode.delegate = self;
        
        _pickerModels = [[NSMutableArray alloc] init];
        _searchPickerModels = [[NSMutableArray alloc] init];
        _sectionsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++) {
            [_sectionsArray addObject:[NSMutableArray new]];
        }
        
        _selectedCount = 0;
        _searching = NO;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero child:_tableNode];
}

- (void)didLoad {
    [super didLoad];
    _tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - PublicMethods

- (void)setViewModels:(NSArray<PickerViewModel *> *)pickerModel {
    [self.pickerModels removeAllObjects];
    self.pickerModels = [NSMutableArray arrayWithArray:pickerModel];
    [self fitPickerModelsData:self.pickerModels
                   toSections:self.sectionsArray];
}

- (void)uncheckElement:(PickerViewModel *)element {
    if (self.selectedCount > 0) {
        self.selectedCount--;
        element.isChosen = NO;
        
        int section = [element getSectionIndex];
        if (section >= self.sectionsArray.count) {
            [self reloadData];
            return;
        }
        
        unsigned long row = [self.sectionsArray[section] indexOfObject:element];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        // Only reload a row of that element
        [UIView performWithoutAnimation:^{
            [self.tableNode reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}

- (void)uncheckAllElements {
    self.selectedCount = 0;
    for (int i = 0; i < self.pickerModels.count; i++) {
        self.pickerModels[i].isChosen = NO;
    }
    
    [self reloadData];
}

- (int)selectedCount {
    return _selectedCount;
}

- (void)searchByString:(NSString *)searchString {
    if (!searchString) {
        self.searching = NO;
    } else if (searchString.length == 0) {
        self.searching = NO;
    } else {
        [_searchPickerModels removeAllObjects];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@", searchString];
        _searchPickerModels = [NSMutableArray arrayWithArray:[self.pickerModels filteredArrayUsingPredicate:predicate]];
        self.searching = YES;
    }
    
    if (self.searching) {
        [self fitPickerModelsData:self.searchPickerModels
                       toSections:self.sectionsArray];
    } else {
        [self fitPickerModelsData:self.pickerModels
                       toSections:self.sectionsArray];
    }
    
    [self reloadData];
}

#pragma mark - SetData

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

- (void)reloadData {
    [self.tableNode reloadData];
}


#pragma mark - ASTableDataSource

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return ALPHABET_SECTIONS_NUMBER;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    if (self.sectionsArray.count == 0)
        return 0;
    
    if (self.sectionsArray[section])
        return self.sectionsArray[section].count;
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    char sectionNameChar = section + FIRST_ALPHABET_ASCII_CODE;
    
    if (section == ALPHABET_SECTIONS_NUMBER - 1)
        return @"#";
    
    return [NSString stringWithFormat:@"%c", sectionNameChar].uppercaseString;
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode
  nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    PickerViewModel *model = self.sectionsArray[indexPath.section][indexPath.row];
    
    ASCellNode *(^ASCellNodeBlock)(void) = ^ASCellNode *() {
        PickerTableCellNode *cellNode = [[PickerTableCellNode alloc] init];
        [cellNode setName:model.name];
        [cellNode setChecked:model.isChosen];
        [cellNode setGradientColorBackground:model.gradientColorCode];
        [cellNode setSelectionStyle:UITableViewCellSelectionStyleNone];
        cellNode.delegate = self;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerTableNode:loadImageToCellNode:atIndexPath:)]) {
            [self.delegate pickerTableNode:self
                       loadImageToCellNode:cellNode
                               atIndexPath:indexPath];
        }
        
        return cellNode;
    };
    
    return ASCellNodeBlock;
}

#pragma mark - ASTableDelegate

// We handle this event manualy by PickerTableCellNodeDelegate, this method can't be called
- (void)tableNode:(ASTableNode *)tableNode
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (ASSizeRange)tableNode:(ASTableNode *)tableNode constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    float avatarImageHeight = [UIScreen mainScreen].bounds.size.width / 7.f;
    return ASSizeRangeMake(CGSizeMake(self.tableNode.frame.size.width, avatarImageHeight + 20));
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return SECTION_HEADER_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view
                                                      forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
}

- (void)tableNode:(ASTableNode *)tableNode
didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    PickerTableCellNode *cell = [tableNode nodeForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.25 animations:^{
        [cell setBackgroundColor:[UIColor colorWithRed:235/255.f
                                                 green:245/255.f
                                                  blue:251/255.f
                                                 alpha:1]];
    }];
}

- (void)tableNode:(ASTableNode *)tableNode
didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    PickerTableCellNode *cell = [tableNode nodeForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - PickerTableCellNodeDelegate

- (void)didSelectPickerCellNode:(PickerTableCellNode *)node {
    NSIndexPath *indexPath = [self.tableNode indexPathForNode:node];
    if (indexPath.section >= self.sectionsArray.count) {
        return;
    } else if (indexPath.row >= self.sectionsArray[indexPath.section].count) {
        return;
    }
    
    PickerViewModel *model = self.sectionsArray[indexPath.section][indexPath.row];
    
    if (!model)
        return;
    
    if (model.isChosen) {
        self.selectedCount--;
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerTableNode:uncheckedCellOfElement:)]) {
            [self.delegate pickerTableNode:self uncheckedCellOfElement:model];
        }
    } else if (self.selectedCount < MAX_PICK) {
        self.selectedCount++;
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerTableNode:checkedCellOfElement:)]) {
            [self.delegate pickerTableNode:self checkedCellOfElement:model];
        }
    } else {
        return;
    }
    
    model.isChosen = !model.isChosen;
    [node setChecked:model.isChosen];
}

@end
