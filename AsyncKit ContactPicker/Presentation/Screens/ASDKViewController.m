//
//  MainViewController.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ASDKViewController.h"
#import "PickerTableNode.h"
#import "PickerCollectionNode.h"
#import "StateView.h"

#import "ImageCache.h"

#import "Contact.h"
#import "ContactBusiness.h"

#define SEARCH_BAR_HEIHGT 50
#define COLLECTION_VIEW_HEIHGT 100

@interface ASDKViewController () <ContactDidChangedDelegate, PickerTableNodeDelegate, PickerCollectionNodeDelegate, UISearchBarDelegate>

@property (nonatomic, strong) ASDisplayNode *contentNode;
@property (nonatomic, strong) PickerTableNode *tableNode;
@property (nonatomic, strong) PickerCollectionNode *collectionNode;

@property (nonatomic, strong) StateView *stateNode;

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

@property (nonatomic, strong) NSMutableArray<Contact *> *searchContacts;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation ASDKViewController

#pragma mark - Lifecycle

- (instancetype)init {
    _contentNode = [[ASDisplayNode alloc] init];
    self = [super initWithNode:_contentNode];
    if (self) {
        _serialQueue = dispatch_queue_create("MainViewSerialQueue", DISPATCH_QUEUE_SERIAL);
        
        _tableNode = [[PickerTableNode alloc] init];
        _tableNode.delegate = self;
        
        _collectionNode = [[PickerCollectionNode alloc] init];
        _collectionNode.delegate = self;
        
        _stateNode = [[StateView alloc] init];
        
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"Search for contacts";
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.delegate = self;
        
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
    
    [_collectionNode.view.heightAnchor constraintEqualToConstant:80].active = YES;
    [_collectionNode.view.widthAnchor constraintEqualToConstant:self.view.bounds.size.width].active = YES;
    
    [_stackView addArrangedSubview:_tableNode.view];
    [_stackView addArrangedSubview:_collectionNode.view];
    
    [self.view addSubview:_searchBar];
    [self.view addSubview:_stackView];
    [self.view addSubnode:_stateNode];
    
    _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    _stateNode.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (@available(iOS 11, *)) {
        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
        [_searchBar.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
        [_stateNode.view.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
        [_stateNode.view.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    } else {
        [_searchBar.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:70].active = YES;
        [_stateNode.view.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:70].active = YES;
        [_stateNode.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    }
    
    [_searchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [_searchBar.heightAnchor constraintEqualToConstant:SEARCH_BAR_HEIHGT].active = YES;
    
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [_stackView.topAnchor constraintEqualToAnchor:_searchBar.bottomAnchor].active = YES;
    
    if (@available(iOS 11, *)) {
        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
        [_stackView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    } else {
        [_stackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    }
    
    [_stateNode.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_stateNode.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    
    self.collectionNode.hidden = YES;
    self.stateNode.hidden = YES;
    
    [self checkPermissionAndLoadContacts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self customInitNavigationBar];
    [self updateNavigationBarWithAnimated:NO];
}

#pragma mark - SetUpNavigationBar

- (void)customInitNavigationBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.titleLabel.text = @"Chọn bạn";
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor darkTextColor];

    self.subTitleLabel.text = @"Đã chọn: 0/5";
    self.subTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.subTitleLabel.textColor = [UIColor darkGrayColor];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.titleLabel, self.subTitleLabel]];
    stackView.distribution = UIStackViewDistributionEqualCentering;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.axis = UILayoutConstraintAxisVertical;
    
    self.tabBarController.navigationItem.titleView = stackView;
    
    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Huỷ"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(cancelPickContacts)];
    self.cancelButtonItem.tintColor = [UIColor blackColor];

    self.updateButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cập nhật"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(updateContactsTapped)];
    self.updateButtonItem.tintColor = [UIColor blackColor];
}

- (void)showCancelPickNavigationButton {
    [self.tabBarController.navigationItem setLeftBarButtonItem:self.cancelButtonItem animated:YES];
}

- (void)hideCancelPickNavigationButton {
    [self.tabBarController.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void)showUpdateContactNavigationButton {
    [self.tabBarController.navigationItem setRightBarButtonItem:self.updateButtonItem animated:YES];
}

- (void)hideUpdateContactNavigationButton {
    [self.tabBarController.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)updateNavigationBarWithAnimated:(BOOL)animated {
    if ([self.tableNode selectedCount] > 0) {
        [self showCancelPickNavigationButton];
    } else {
        [self hideCancelPickNavigationButton];
    }
    
    self.subTitleLabel.text = [NSString stringWithFormat:@"Đã chọn: %d/5", [self.tableNode selectedCount]];
    if (animated) {
        self.subTitleLabel.transform = CGAffineTransformScale(self.subTitleLabel.transform, 1.2, 1.3);
        [UIView animateWithDuration:0.25 animations:^{
            self.subTitleLabel.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

#pragma mark - NavigationBarAction

- (void)cancelPickContacts {
    [self.tableNode uncheckAllElements];
    [self.collectionNode removeAllElements];
    [self updateNavigationBarWithAnimated:NO];
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
            [self showNotPermissionView];
            break;
        }
        default: {
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
}

- (void)showNotPermissionView {
    [self.stateNode setImage:[UIImage imageNamed:@"no_permission"]];
    [self.stateNode setTitle:@"KHÔNG CÓ QUYỀN TRUY CẬP"];
    [self.stateNode setDescription:@"Ứng dụng không có quyền truy cập vào danh bạ. Đến Cài đặt để cấp quyền?"];
    [self.stateNode setButtonTitle:@"Đến Cài đặt"];
    [self.stateNode setButtonTappedAction:^{
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                         options:@{}
                               completionHandler:nil];
    }];
    
    self.stateNode.hidden = NO;
    self.stateNode.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.stateNode.alpha = 1;
    } completion:nil];
    
    self.stateNode.hidden = NO;
}

- (void)loadContacts {
    [self.contactBusiness loadContactsWithCompletion:^(NSArray<Contact *> *contacts, NSError *error) {
        if (!error) {
            if (contacts.count > 0) {
                [self initContactsData:contacts];
                self.pickerModels = [self getPickerModelsArrayFromContacts:self.contacts];
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
    
    // Test
//    for (int i = 0; i < 1000; i++) {
//        Contact *contact = [[Contact alloc] init];
//        contact.name = [NSString stringWithFormat:@"Test %d", i];
//        contact.identifier = [[NSUUID UUID] UUIDString];
//        contact.phoneNumber = @"";
//
//        [self.contacts addObject:contact];
//    }
    
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

#pragma mark - PickerTableNodeDelegate

- (void)pickerTableNode:(PickerTableNode *)tableNode checkedCellOfElement:(PickerViewModel *)element {
    UIImage *imageFromCache = [[ImageCache instance] imageForKey:element.identifier];
    if (!element)
        return;
    
    if (imageFromCache) {
        [self.collectionNode addElement:element
                              withImage:imageFromCache];
        [self updateNavigationBarWithAnimated:YES];
    } else {
        [self.contactBusiness loadContactImageByID:element.identifier
                                        completion:^(UIImage *image, NSError *error) {
            [[ImageCache instance] setImage:image
                                     forKey:element.identifier];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionNode addElement:element
                                      withImage:image];
                [self updateNavigationBarWithAnimated:YES];
            });
        }];
    }
}

- (void)pickerTableNode:(PickerTableNode *)tableNode uncheckedCellOfElement:(PickerViewModel *)element {
    if (tableNode == self.tableNode && element) {
        [self.collectionNode removeElement:element];
        [self updateNavigationBarWithAnimated:YES];
    }
}

- (void)pickerTableNode:(PickerTableNode *)tableNode loadImageToCellNode:(PickerTableCellNode *)cellNode
                                                             atIndexPath:(NSIndexPath *)indexPath {
    if (tableNode != self.tableNode)
        return;
    if (indexPath.section >= self.sectionData.count)
        return;
    if (indexPath.row >= self.sectionData[indexPath.section].count)
        return;
    
    Contact *contact = (Contact *)self.sectionData[indexPath.section][indexPath.row];
    
    UIImage *imageFromCache = [[ImageCache instance] imageForKey:contact.identifier];
    if (imageFromCache) {
        [cellNode setAvatar:imageFromCache];
        [cellNode setNeedsLayout];
    } else {
        [self.contactBusiness loadContactImageByID:contact.identifier
                                        completion:^(UIImage *image, NSError *error) {
            [[ImageCache instance] setImage:image forKey:contact.identifier];
            [cellNode setAvatar:image];
            [cellNode setNeedsLayout];
        }];
    }
}

#pragma mark - PickerCollectioNodeDelegate

- (void)collectionNode:(PickerCollectionNode *)collectionNode removeElement:(PickerViewModel *)element {
    if (!element)
        return;
    
    if (collectionNode == self.collectionNode) {
        [self.tableNode uncheckElement:element];
        [self updateNavigationBarWithAnimated:YES];
    }
}

- (void)nextButtonTappedFromPickerCollectionNode:(PickerCollectionNode *)collectionNode {
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.tableNode searchByString:searchText];
}

@end
