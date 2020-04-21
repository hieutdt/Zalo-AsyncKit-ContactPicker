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

@interface PickerTableNode () <ASTableDelegate, ASTableDataSource>

@property (nonatomic, strong) ASTableNode *tableNode;

@property (strong, nonatomic) NSMutableArray<PickerViewModel *> *pickerModels;
@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *sectionsArray;

@property (nonatomic, assign) int selectedCount;

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
        _sectionsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++) {
            [_sectionsArray addObject:[NSMutableArray new]];
        }
        
        _selectedCount = 0;
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
    self.pickerModels = [NSMutableArray arrayWithArray:pickerModel];
    [self fitPickerModelsData:self.pickerModels
                   toSections:self.sectionsArray];
}

- (void)removeElement:(PickerViewModel *)element {
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
        [self.tableNode reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (int)selectedCount {
    return _selectedCount;
}

#pragma mark - SetData

- (void)fitPickerModelsData:(NSMutableArray<PickerViewModel*> *)models
                 toSections:(NSMutableArray<NSMutableArray*> *)sectionsArray {
#if DEBUG
    assert(sectionsArray);
    assert(sectionsArray.count == ALPHABET_SECTIONS_NUMBER);
#endif
    
    if (!models || models.count == 0)
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

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    PickerViewModel *model = self.sectionsArray[indexPath.section][indexPath.row];
    
    ASCellNode *(^ASCellNodeBlock)(void) = ^ASCellNode *() {
        PickerTableCellNode *cellNode = [[PickerTableCellNode alloc] init];
        [cellNode setName:model.name];
        [cellNode setChecked:model.isChosen];
        [cellNode setGradientColorBackground:model.gradientColorCode];
        [cellNode setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerTableNode:loadImageToCellNode:atIndexPath:)]) {
            [self.delegate pickerTableNode:self loadImageToCellNode:cellNode atIndexPath:indexPath];
        }
        
        return cellNode;
    };
    
    return ASCellNodeBlock;
}

#pragma mark - ASTableDelegate

- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.sectionsArray.count) {
        return;
    } else if (indexPath.row >= self.sectionsArray[indexPath.section].count) {
        return;
    }
    
    PickerTableCellNode *cell = [tableNode nodeForRowAtIndexPath:indexPath];
    PickerViewModel *model = self.sectionsArray[indexPath.section][indexPath.row];
    
    if (!model)
        return;
    
    if (model.isChosen) {
        self.selectedCount--;
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerTableNode:uncheckedCellOfElement:)]) {
            [self.delegate pickerTableNode:self uncheckedCellOfElement:model];
        }
    } else if (self.selectedCount < 5) {
        self.selectedCount++;
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerTableNode:checkedCellOfElement:)]) {
            [self.delegate pickerTableNode:self checkedCellOfElement:model];
        }
    } else {
        return;
    }
    
    model.isChosen = !model.isChosen;
    [cell setChecked:model.isChosen];
}

- (ASSizeRange)tableNode:(ASTableNode *)tableNode constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ASSizeRangeMake(CGSizeMake(self.tableNode.frame.size.width, AVATAR_IMAGE_HEIHGT + 30));
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

@end
