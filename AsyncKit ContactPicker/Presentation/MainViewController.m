//
//  MainViewController.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MainViewController.h"
#import "PickerTableNode.h"
#import "PickerCollectionNode.h"

#import "Contact.h"
#import "ContactBusiness.h"

#define SEARCH_BAR_HEIHGT 50
#define COLLECTION_VIEW_HEIHGT 100

@interface MainViewController () <ContactDidChangedDelegate, PickerTableNodeDelegate, PickerCollectionNodeDelegate>

@property (nonatomic, strong) ASDisplayNode *contentNode;
@property (nonatomic, strong) PickerTableNode *tableNode;
@property (nonatomic, strong) PickerCollectionNode *collectionNode;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIBarButtonItem *updateButtonItem;
@property (nonatomic, strong) UIBarButtonItem *cancelButtonItem;

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
        _tableNode = [[PickerTableNode alloc] init];
        _tableNode.delegate = self;
        
        _collectionNode = [[PickerCollectionNode alloc] init];
        _collectionNode.delegate = self;
        
        _searchBar = [[UISearchBar alloc] init];
        
        _stackView = [[UIStackView alloc] init];
        _stackView.axis = UILayoutConstraintAxisVertical;
        
        _titleLabel = [[UILabel alloc] init];
        _subTitleLabel = [[UILabel alloc] init];
        
        _pickerModels = [[NSMutableArray alloc] init];
        _contacts = [[NSMutableArray alloc] init];
        _sectionData = [[NSMutableArray alloc] init];
        for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++) {
            [_sectionData addObject:[[NSMutableArray<Contact *> alloc] init]];
        }
        
        _contactBusiness = [[ContactBusiness alloc] init];
        [_contactBusiness resigterContactDidChangedDelegate:self];
        
        self.contentNode.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)dealloc {
    [self.contactBusiness removeContactDidChangedDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_collectionNode.view.heightAnchor constraintEqualToConstant:100].active = YES;
    [_collectionNode.view.widthAnchor constraintEqualToConstant:self.view.bounds.size.width].active = YES;
    
    [_stackView addArrangedSubview:_tableNode.view];
    [_stackView addArrangedSubview:_collectionNode.view];
    
    [self.view addSubview:_searchBar];
    [self.view addSubview:_stackView];
    
    _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [_searchBar.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:65].active = YES;
    [_searchBar.heightAnchor constraintEqualToConstant:SEARCH_BAR_HEIHGT].active = YES;
    
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [_stackView.topAnchor constraintEqualToAnchor:_searchBar.bottomAnchor].active = YES;
    [_stackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [self customInitNavigationBar];
    
    [self checkPermissionAndLoadContacts];
}

#pragma mark - SetUpNavigationBar

- (void)customInitNavigationBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.titleLabel.text = @"Contacts list";
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    self.titleLabel.textColor = [UIColor darkTextColor];

    self.subTitleLabel.text = @"Selected: 0/5";
    self.subTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.subTitleLabel.textColor = [UIColor lightGrayColor];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.titleLabel, self.subTitleLabel]];
    stackView.distribution = UIStackViewDistributionEqualCentering;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.axis = UILayoutConstraintAxisVertical;

    self.navigationItem.titleView = stackView;
    
    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(cancelPickContacts)];
    self.cancelButtonItem.tintColor = [UIColor blackColor];

    self.updateButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Update"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(updateContactsTapped)];
    self.updateButtonItem.tintColor = [UIColor blackColor];
    
    self.subTitleLabel.hidden = YES;
}

- (void)showCancelPickNavigationButton {
    [self.navigationItem setLeftBarButtonItem:self.cancelButtonItem animated:YES];
}

- (void)hideCancelPickNavigationButton {
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void)showUpdateContactNavigationButton {
    [self.navigationItem setRightBarButtonItem:self.updateButtonItem animated:YES];
}

- (void)hideUpdateContactNavigationButton {
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)updateNavigationBar {
    if ([self.tableNode selectedCount] > 0) {
        self.subTitleLabel.hidden = NO;
        [self showCancelPickNavigationButton];
    } else {
        self.subTitleLabel.hidden = YES;
        [self hideCancelPickNavigationButton];
    }
    
    self.subTitleLabel.text = [NSString stringWithFormat:@"Selected: %d/5", [self.tableNode selectedCount]];
}

#pragma mark - NavigationBarAction

- (void)cancelPickContacts {
    
}

- (void)updateContactsTapped {
    
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

#pragma mark - PickerTableNodeDelegate

- (void)pickerTableNode:(PickerTableNode *)tableNode checkedCellOfElement:(PickerViewModel *)element {
    if (tableNode == self.tableNode && element) {
        [self.collectionNode addElement:element withImage:nil];
        [self updateNavigationBar];
    }
}

- (void)pickerTableNode:(PickerTableNode *)tableNode uncheckedCellOfElement:(PickerViewModel *)element {
    if (tableNode == self.tableNode && element) {
        [self.collectionNode removeElement:element];
        [self updateNavigationBar];
    }
}

#pragma mark - PickerCollectioNodeDelegate

- (void)collectionNode:(PickerCollectionNode *)collectionNode removeElement:(PickerViewModel *)element {
    if (!element)
        return;
    
    if (collectionNode == self.collectionNode) {
        [self.tableNode removeElement:element];
        [self updateNavigationBar];
    }
}

- (void)nextButtonTappedFromPickerCollectionNode:(PickerCollectionNode *)collectionNode {
    
}

@end
