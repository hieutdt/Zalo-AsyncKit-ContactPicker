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
#import "ImageCache.h"
#import "UIImage+Addtions.h"

@interface IGLKPickerCollectionCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *shortNameLabel;
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, assign) PickerViewModel *viewModel;
@property (nonatomic, assign) float avatarImageHeight;

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
    
    _avatarImageHeight = [UIScreen mainScreen].bounds.size.width / 7.f;
    
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
    [_avatarImageView.heightAnchor constraintEqualToConstant:_avatarImageHeight].active = YES;
    [_avatarImageView.widthAnchor constraintEqualToConstant:_avatarImageHeight].active = YES;
    
    [_shortNameLabel.centerYAnchor constraintEqualToAnchor:_avatarImageView.centerYAnchor].active = YES;
    [_shortNameLabel.centerXAnchor constraintEqualToAnchor:_avatarImageView.centerXAnchor].active = YES;
    _shortNameLabel.font = [UIFont boldSystemFontOfSize:23];
    _shortNameLabel.textColor = [UIColor whiteColor];
    
    [_removeButton.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_removeButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_removeButton.heightAnchor constraintEqualToConstant:20].active = YES;
    [_removeButton.widthAnchor constraintEqualToConstant:20].active = YES;
    [_removeButton setTitle:@"X" forState:UIControlStateNormal];
    [_removeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    _removeButton.backgroundColor = [UIColor lightGrayColor];
    _removeButton.layer.cornerRadius = 20/2.f;
    _removeButton.layer.masksToBounds = YES;
    _removeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _removeButton.layer.borderWidth = 3;
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
    
    UIImage *avatar = [[ImageCache instance] imageForKey:_viewModel.identifier];
    if (avatar) {
        self.shortNameLabel.hidden = YES;
    } else {
        self.shortNameLabel.hidden = NO;
        switch (_viewModel.gradientColorCode) {
            case GRADIENT_COLOR_BLUE:
                avatar = [UIImage imageNamed:@"gradientBlue"];
                break;
            case GRADIENT_COLOR_RED:
                avatar = [UIImage imageNamed:@"gradientRed"];
                break;
            case GRADIENT_COLOR_GREEN:
                avatar = [UIImage imageNamed:@"gradientGreen"];
                break;
            case GRADIENT_COLOR_ORANGE:
                avatar = [UIImage imageNamed:@"gradientOrange"];
                break;
        }
    }
    
    avatar = [avatar makeCircularImageWithSize:CGSizeMake(_avatarImageHeight, _avatarImageHeight)];
    [_avatarImageView setImage:avatar];
}

@end
