//
//  IGLKViewController.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "IGLKViewController.h"

#import "Contact.h"
#import "ContactBusiness.h"
#import "PickerViewModel.h"
#import "AppConsts.h"
#import "ImageCache.h"

#import "IGLKPickerTableView.h"
#import "IGLKPickerCollectionView.h"

@interface IGLKViewController () <IGLKPickerTableViewDelegate, IGLKPickerCollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray<Contact *> *contacts;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *sectionData;

@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *pickerModels;

@property (nonatomic, strong) ContactBusiness *contactBusiness;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet IGLKPickerTableView *tableView;
@property (nonatomic, weak) IBOutlet IGLKPickerCollectionView *collectionView;


@end

@implementation IGLKViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _contacts = [[NSMutableArray alloc] init];
        _pickerModels = [[NSMutableArray alloc] init];
        _sectionData = [[NSMutableArray alloc] init];
        for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++) {
            [_sectionData addObject:[NSMutableArray new]];
        }
        
        _contactBusiness = [[ContactBusiness alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    [_tableView setViewController:self];
    
    _collectionView.delegate = self;
    _collectionView.hidden = YES;
    
    _searchBar.placeholder = @"Search for contacts";
    _searchBar.delegate = self;
    
    [self checkPermissionAndLoadContacts];
}

#pragma mark - LoadContacts

- (void)checkPermissionAndLoadContacts {
    ContactAuthorState authorizationState = [self.contactBusiness permissionStateToAccessContactData];
    switch (authorizationState) {
        case ContactAuthorStateAuthorized:
            [self loadContacts];
            break;
        case ContactAuthorStateDenied:
            [self showNotPermissionView];
            break;
        default:
            [self.contactBusiness requestAccessWithCompletionHandle:^(BOOL granted) {
                if (granted) {
                    [self loadContacts];
                } else {
                    [self showNotPermissionView];
                }
            }];
            break;
    }
}

- (void)showNotPermissionView {
    
}

- (void)loadContacts {
    [self.contactBusiness loadContactsWithCompletion:^(NSArray<Contact *> *contacts, NSError *error) {
        if (!error) {
            if (contacts.count > 0) {
                [self initContactsData:contacts];
                self.pickerModels = [self getPickerModelsArrayFromContacts:self.contacts];
                [self.tableView setViewModels:self.pickerModels];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    }];
}

- (void)initContactsData:(NSArray<Contact *> *)contacts {
    if (!contacts)
        return;
    
    self.contacts = [NSMutableArray arrayWithArray:[self.contactBusiness sortedContacts:contacts ascending:YES]];
    self.sectionData = [self.contactBusiness sortedByAlphabetSectionsArrayFromContacts:self.contacts];
}

- (NSMutableArray<PickerViewModel *> *)getPickerModelsArrayFromContacts:(NSArray<Contact *> *)contacts {
    if (!contacts) {
        return nil;
    }
    
    NSMutableArray<PickerViewModel *> *pickerModels = [[NSMutableArray alloc] init];
    
    for (Contact *contact in contacts) {
        PickerViewModel *pickerModel = [[PickerViewModel alloc] init];
        pickerModel.identifier = contact.identifier;
        pickerModel.name = contact.name;
        pickerModel.isChosen = NO;
        
        [pickerModels addObject:pickerModel];
    }
    
    return pickerModels;
}

#pragma mark - IGLKPickerTableViewDelegate

- (void)pickerTableView:(IGLKPickerTableView *)tableView
     checkedCellOfModel:(PickerViewModel *)model {
    if (!model)
        return;
    
    if (tableView == self.tableView) {
        [self.collectionView addElement:model];
    }
}

- (void)pickerTableView:(IGLKPickerTableView *)tableView
   uncheckedCellOfModel:(PickerViewModel *)model {
    if (!model)
        return;
    
    if (tableView == self.tableView) {
        [self.collectionView removeElement:model];
    }
}

- (void)pickerTableView:(IGLKPickerTableView *)tableView
        loadImageToCell:(IGLKPickerTableCell *)cell
                ofModel:(nonnull PickerViewModel *)model {
    if (!cell)
        return;
    
    if (!model)
        return;
    
    if (tableView == self.tableView) {
        UIImage *imageFromCache = [[ImageCache instance] imageForKey:model.identifier];
        if (imageFromCache) {
            [self.tableView reloadModel:model];
        } else {
            [self.contactBusiness loadContactImageByID:model.identifier
                                            completion:^(UIImage *image, NSError *error) {
                if (image) {
                    [[ImageCache instance] setImage:image
                                             forKey:model.identifier];
                    [self.tableView reloadModel:model];
                }
            }];
        }
    }
}

#pragma mark - IGLKPickerCollectionViewDelegate

- (void)collectionView:(IGLKPickerCollectionView *)collectionView removeItem:(PickerViewModel *)item {
    if (!item)
        return;
    if (collectionView == self.collectionView) {
        [self.tableView uncheckModel:item];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self.tableView setViewModels:self.pickerModels];
        [self.tableView reloadData];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@", searchText];
        NSMutableArray<PickerViewModel *> *searchModels = [NSMutableArray arrayWithArray:[self.pickerModels filteredArrayUsingPredicate:predicate]];
        
        [self.tableView setViewModels:searchModels];
        [self.tableView reloadData];
    }
}

@end
