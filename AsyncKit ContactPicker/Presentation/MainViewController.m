//
//  MainViewController.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MainViewController.h"
#import "PickerTableNode.h"

#import "Contact.h"
#import "ContactBusiness.h"

@interface MainViewController () <ContactDidChangedDelegate>

@property (nonatomic, strong) ASDisplayNode *contentNode;
@property (nonatomic, strong) PickerTableNode *tableNode;

@property (nonatomic, strong) NSMutableArray<Contact *> *contacts;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *sectionData;

@property (nonatomic, strong) NSMutableArray<PickerViewModel *> *pickerModels;

@property (nonatomic, strong) ContactBusiness *contactBusiness;

@end

@implementation MainViewController

#pragma mark - Lifecycle

- (instancetype)init {
    _contentNode = [[ASDisplayNode alloc] init];
    self = [super initWithNode:_contentNode];
    if (self) {
        __weak MainViewController *weakSelf = self;
        
        _tableNode = [[PickerTableNode alloc] init];
        
        _pickerModels = [[NSMutableArray alloc] init];
        _contacts = [[NSMutableArray alloc] init];
        _sectionData = [[NSMutableArray alloc] init];
        for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++) {
            [_sectionData addObject:[[NSMutableArray<Contact *> alloc] init]];
        }
        
        _contactBusiness = [[ContactBusiness alloc] init];
        [_contactBusiness resigterContactDidChangedDelegate:self];
        
        self.contentNode.backgroundColor = [UIColor whiteColor];
        [self.contentNode addSubnode:self.tableNode];
        self.contentNode.layoutSpecBlock = ^ASLayoutSpec *(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            ASInsetLayoutSpec *insetTable = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero
                                                                                   child:weakSelf.tableNode];
            return insetTable;
        };
    }
    return self;
}

- (void)dealloc {
    [self.contactBusiness removeContactDidChangedDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
                self.pickerModels = [self getPickerModelsArrayFromContacts];
                [self.tableNode setViewModels:self.pickerModels];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableNode reloadData];
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

- (NSMutableArray<PickerViewModel *> *)getPickerModelsArrayFromContacts {
    if (!self.contacts) {
        return nil;
    }
    
    NSMutableArray<PickerViewModel *> *pickerModels = [[NSMutableArray alloc] init];
    
    for (Contact *contact in self.contacts) {
        PickerViewModel *pickerModel = [[PickerViewModel alloc] init];
        pickerModel.identifier = contact.identifier;
        pickerModel.name = contact.name;
        pickerModel.isChosen = NO;
        
        [pickerModels addObject:pickerModel];
    }
    
    return pickerModels;
}

@end
