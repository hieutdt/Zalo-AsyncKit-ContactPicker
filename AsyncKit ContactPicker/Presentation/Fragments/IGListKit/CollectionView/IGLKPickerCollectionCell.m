//
//  IGLKPickerCollectionCell.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "IGLKPickerCollectionCell.h"

#import "AppConsts.h"
#import "StringHelper.h"

@interface IGLKPickerCollectionCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *shortNameLabel;
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, assign) PickerViewModel *viewModel;

@end

@implementation IGLKPickerCollectionCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    self.backgroundColor = [UIColor whiteColor];
    
    _avatarImageView = [[UIImageView alloc] init];
    _shortNameLabel = [[UILabel alloc] init];
    _removeButton = [[UIButton alloc] init];
    
    [self addSubview:_avatarImageView];
    [self addSubview:_shortNameLabel];
    [self addSubview:_removeButton];
    
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _shortNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _removeButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_avatarImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
    [_avatarImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [_avatarImageView.heightAnchor constraintEqualToConstant:AVATAR_COLLECTION_IMAGE_HEIGHT].active = YES;
    [_avatarImageView.widthAnchor constraintEqualToConstant:AVATAR_COLLECTION_IMAGE_HEIGHT].active = YES;
    _avatarImageView.layer.cornerRadius = AVATAR_COLLECTION_IMAGE_HEIGHT/2.f;
    _avatarImageView.layer.masksToBounds = YES;
    
    [_shortNameLabel.centerYAnchor constraintEqualToAnchor:_avatarImageView.centerYAnchor].active = YES;
    [_shortNameLabel.centerXAnchor constraintEqualToAnchor:_avatarImageView.centerXAnchor].active = YES;
    _shortNameLabel.font = [UIFont boldSystemFontOfSize:23];
    _shortNameLabel.textColor = [UIColor whiteColor];
    
    [_removeButton.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_removeButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_removeButton.heightAnchor constraintEqualToConstant:25].active = YES;
    [_removeButton.widthAnchor constraintEqualToConstant:25].active = YES;
    [_removeButton setTitle:@"X" forState:UIControlStateNormal];
    _removeButton.backgroundColor = [UIColor lightGrayColor];
    _removeButton.layer.cornerRadius = 25/2.f;
    _removeButton.layer.masksToBounds = YES;
    _removeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _removeButton.layer.borderWidth = 2;
    [_removeButton addTarget:self
                      action:@selector(removeButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(removeButtonTappedAtModel:)]) {
        [self.delegate removeButtonTappedAtModel:_viewModel];
    }
}

#pragma mark - IGListBindable

- (void)bindViewModel:(id)viewModel {
    if (!viewModel)
        return;
    
    _viewModel = (PickerViewModel *)viewModel;
    
    [_shortNameLabel setText:[StringHelper getShortName:_viewModel.name]];
    
    switch (_viewModel.gradientColorCode) {
        case GRADIENT_COLOR_BLUE:
            [_avatarImageView setImage:[UIImage imageNamed:@"gradientBlue"]];
            break;
        case GRADIENT_COLOR_RED:
            [_avatarImageView setImage:[UIImage imageNamed:@"gradientRed"]];
            break;
        case GRADIENT_COLOR_GREEN:
            [_avatarImageView setImage:[UIImage imageNamed:@"gradientGreen"]];
            break;
        case GRADIENT_COLOR_ORANGE:
            [_avatarImageView setImage:[UIImage imageNamed:@"gradientOrange"]];
            break;
    }
}

@end
