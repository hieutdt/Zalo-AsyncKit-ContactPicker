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

#import "ContactBusiness.h"

#import "Contact.h"
#import "PickerViewModel.h"

#import "AppConsts.h"

static const int kCollectionViewHeight = 100;

@interface CKViewController () <CKPickerTableViewDelegate>

@property (nonatomic, strong) CKPickerTableView *tableView;
@property (nonatomic, strong) CKPickerCollectionView *collectionView;
@property (nonatomic, strong) UIStackView *mainStack;

@property (nonatomic, strong) ContactBusiness *contactBusiness;

@property (nonatomic, strong) NSMutableArray<Contact *> *contacts;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *sectionData;
@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *viewModels;

@end

@implementation CKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBlueColor];
    
    _tableView = [[CKPickerTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kCollectionViewHeight)];
    _tableView.delegate = self;
    _collectionView = [[CKPickerCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kCollectionViewHeight)];
    
    _mainStack = [[UIStackView alloc] initWithFrame:self.view.bounds];
    _mainStack.axis = UILayoutConstraintAxisVertical;
    [_mainStack addArrangedSubview:_tableView];
    [_mainStack addArrangedSubview:_collectionView];
    [self.view addSubview:_mainStack];
    
    if (@available(iOS 11, *)) {
        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
        [_mainStack.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
        [_mainStack.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    }
    
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

- (void)CKPickerTableView:(CKPickerTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
}


@end
