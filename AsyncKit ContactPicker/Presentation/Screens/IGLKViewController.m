//
//  IGLKViewController.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "IGLKViewController.h"
#import "StateView.h"

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
@property (nonatomic, strong) StateView *stateNode;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIBarButtonItem *updateButtonItem;
@property (nonatomic, strong) UIBarButtonItem *cancelButtonItem;


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
        
        _stateNode = [[StateView alloc] init];
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
    
    [self.view addSubview:_stateNode.view];
    _stateNode.view.translatesAutoresizingMaskIntoConstraints = NO;
    [_stateNode.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_stateNode.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    if (@available(iOS 11, *)) {
        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
        [_stateNode.view.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
        [_stateNode.view.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    } else {
        [_stateNode.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
        [_stateNode.view.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:70].active = YES;
    }
    _stateNode.hidden = YES;
    
    [self checkPermissionAndLoadContacts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self customInitNavigationBar];
    [self updateNavigationBarWithAnimated:NO];
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
    [self.stateNode setImage:[UIImage imageNamed:@"mixi"]];
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
        [self updateNavigationBarWithAnimated:YES];
    }
}

- (void)pickerTableView:(IGLKPickerTableView *)tableView
   uncheckedCellOfModel:(PickerViewModel *)model {
    if (!model)
        return;
    
    if (tableView == self.tableView) {
        [self.collectionView removeElement:model];
        [self updateNavigationBarWithAnimated:YES];
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

- (void)collectionView:(IGLKPickerCollectionView *)collectionView
            removeItem:(PickerViewModel *)item {
    if (!item)
        return;
    if (collectionView == self.collectionView) {
        [self.tableView uncheckModel:item];
        [self updateNavigationBarWithAnimated:YES];
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

#pragma mark - CustomInitNavigationBar

- (void)customInitNavigationBar {
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];

    _titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Chọn bạn";
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor darkTextColor];

    _subTitleLabel = [[UILabel alloc] init];
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
    [self.tabBarController.navigationItem setLeftBarButtonItem:self.cancelButtonItem
                                                      animated:YES];
}

- (void)hideCancelPickNavigationButton {
    [self.tabBarController.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void)showUpdateContactNavigationButton {
    [self.tabBarController.navigationItem setRightBarButtonItem:self.updateButtonItem
                                                       animated:YES];
}

- (void)hideUpdateContactNavigationButton {
    [self.tabBarController.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)updateNavigationBarWithAnimated:(BOOL)animated {
    if ([self.tableView selectedCount] > 0) {
        [self showCancelPickNavigationButton];
    } else {
        [self hideCancelPickNavigationButton];
    }
    
    self.subTitleLabel.text = [NSString stringWithFormat:@"Đã chọn: %d/5", [self.tableView selectedCount]];
    if (animated) {
        self.subTitleLabel.transform = CGAffineTransformScale(self.subTitleLabel.transform, 1.2, 1.3);
        [UIView animateWithDuration:0.25 animations:^{
            self.subTitleLabel.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}


- (void)cancelPickContacts {
    [self.tableView unselectAllModels];
    [self.collectionView removeAllElements];
    [self updateNavigationBarWithAnimated:YES];
}

- (void)updateContactsTapped {
    
}


@end
