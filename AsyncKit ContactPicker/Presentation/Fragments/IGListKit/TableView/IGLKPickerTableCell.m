//
//  IGLKPickerTableCell.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "IGLKPickerTableCell.h"
#import "AppConsts.h"
#import "PickerViewModel.h"

@interface IGLKPickerTableCell ()

@property (nonatomic, strong) UIImageView *checkerImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation IGLKPickerTableCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    _checkerImageView = [[UIImageView alloc] init];
    _avatarImageView = [[UIImageView alloc] init];
    _nameLabel = [[UILabel alloc] init];
    
    _checkerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_checkerImageView];
    [self addSubview:_avatarImageView];
    [self addSubview:_nameLabel];
    
    [_checkerImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                    constant:5].active = YES;
    [_checkerImageView.trailingAnchor constraintEqualToAnchor:_avatarImageView.leadingAnchor
                                                     constant:-10].active = YES;
    [_checkerImageView.centerYAnchor constraintEqualToAnchor:_avatarImageView.centerYAnchor].active = YES;
    [_checkerImageView.heightAnchor constraintEqualToConstant:CHECKER_IMAGE_HEIGHT].active = YES;
    [_checkerImageView.widthAnchor constraintEqualToConstant:CHECKER_IMAGE_HEIGHT].active = YES;
    
    [_avatarImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10].active = YES;
    [_avatarImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10].active = YES;
    [_avatarImageView.heightAnchor constraintEqualToConstant:AVATAR_IMAGE_HEIHGT].active = YES;
    [_avatarImageView.widthAnchor constraintEqualToConstant:AVATAR_IMAGE_HEIHGT].active = YES;
    
    [_nameLabel.leadingAnchor constraintEqualToAnchor:_avatarImageView.trailingAnchor
                                             constant:10].active = YES;
    [_nameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10].active = YES;
    [_nameLabel.centerYAnchor constraintEqualToAnchor:_avatarImageView.centerYAnchor].active = YES;
}

- (void)setName:(NSString *)name {
    [_nameLabel setText:name];
}

#pragma mark - IGListBindable

- (void)bindViewModel:(id)viewModel {
    if (!viewModel)
        return;
    
    PickerViewModel *model = (PickerViewModel *)viewModel;
    
    [_nameLabel setText:model.name];
    switch (model.gradientColorCode) {
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
    
    if (model.isChosen) {
        [_checkerImageView setImage:[UIImage imageNamed:@"checked"]];
    } else {
        [_checkerImageView setImage:[UIImage imageNamed:@"uncheck"]];
    }
}

@end
