//
//  CKViewController.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/23/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "CKViewController.h"
#import "CKPickerTableView.h"
#import "CKPickerCollectionView.h"
#import "CKPickerCollectionCellComponent.h"

#import "ContactBusiness.h"

#import "Contact.h"
#import "PickerViewModel.h"

#import "AppConsts.h"
#import "ImageCache.h"

static const int kCollectionViewHeight = 100;

@interface CKViewController () <CKPickerTableViewDelegate>

@property (weak, nonatomic) IBOutlet CKPickerTableView *tableView;
@property (weak, nonatomic) IBOutlet CKPickerCollectionView *collectionView;

@property (nonatomic, strong) ContactBusiness *contactBusiness;

@property (nonatomic, strong) NSMutableArray<Contact *> *contacts;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *sectionData;
@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *viewModels;

@end

@implementation CKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    
    _contactBusiness = [[ContactBusiness alloc] init];
    
    _contacts = [[NSMutableArray alloc] init];
    _viewModels = [[NSMutableArray alloc] init];
    _sectionData = [[NSMutableArray alloc] init];
    for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++) {
        [_sectionData addObject:[NSMutableArray new]];
    }
    
    [self checkPermissionAndLoadContacts];
}

#pragma mark - LoadContacts

- (void)checkPermissionAndLoadContacts {
    ContactAuthorState authorizationState = [self.contactBusiness permissionStateToAccessContactData];
    switch (authorizationState) {
        case ContactAuthorStateAuthorized: {
            [self loadContacts];
            break;
        }
        case ContactAuthorStateDenied: {
//            [self showNotPermissionView];
            break;
        }
        default: {
            [self.contactBusiness requestAccessWithCompletionHandle:^(BOOL granted) {
                if (granted) {
                    [self loadContacts];
                } else {
//                    [self showNotPermissionView];
                }
            }];
            break;
        }
    }
}

- (void)loadContacts {
    [self.contactBusiness loadContactsWithCompletion:^(NSArray<Contact *> *contacts, NSError *error) {
        if (!error) {
            if (contacts.count > 0) {
                [self initContactsData:contacts];
                self.viewModels = [self getPickerModelsArrayFromContacts:self.contacts];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView setViewModels:self.viewModels];
                    [self.tableView reloadData];
                });
            }
        }
    }];
}

- (void)initContactsData:(NSArray<Contact *> *)contacts {
    if (!contacts)
        return;
    
    self.contacts = [NSMutableArray arrayWithArray:contacts];
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

#pragma mark - CKPickerTableViewDelegate

- (void)CKPickerTableView:(CKPickerTableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long index = indexPath.row;
    if (index >= self.viewModels.count)
        return;
    
    PickerViewModel *model = self.viewModels[index];
    [self.collectionView addElement:model withImage:nil];
}

- (void)CKPickerTableView:(CKPickerTableView *)tableView
didUnSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long index = indexPath.row;
    if (index >= self.viewModels.count)
        return;
    
    PickerViewModel *model = self.viewModels[index];
    [self.collectionView removeElement:model];
}

- (void)loadImageToCellComponent:(CKPickerTableCellComponent *)cellComponent
                     atIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = (Contact *)self.contacts[indexPath.row];
    UIImage *imageFromCache = [[ImageCache instance] imageForKey:contact.identifier];
    if (imageFromCache) {
        [cellComponent setAvatar:imageFromCache];
    }
}


@end
