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
#import "StringHelper.h"
#import "ImageCache.h"

@interface IGLKPickerTableCell ()

@property (nonatomic, strong) UIImageView *checkerImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *shortNameLabel;

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
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat avatarImageHeight = [UIScreen mainScreen].bounds.size.width / 7.f;
    CGFloat checkerImageHeight = avatarImageHeight / 2.f;
    
    _checkerImageView = [[UIImageView alloc] init];
    _avatarImageView = [[UIImageView alloc] init];
    _nameLabel = [[UILabel alloc] init];
    _shortNameLabel = [[UILabel alloc] init];
    
    _checkerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _shortNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_checkerImageView];
    [self addSubview:_avatarImageView];
    [self addSubview:_nameLabel];
    [self addSubview:_shortNameLabel];
    
    [_checkerImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                    constant:15].active = YES;
    [_checkerImageView.trailingAnchor constraintEqualToAnchor:_avatarImageView.leadingAnchor
                                                     constant:-15].active = YES;
    [_checkerImageView.centerYAnchor constraintEqualToAnchor:_avatarImageView.centerYAnchor].active = YES;
    [_checkerImageView.heightAnchor constraintEqualToConstant:checkerImageHeight].active = YES;
    [_checkerImageView.widthAnchor constraintEqualToConstant:checkerImageHeight].active = YES;
    
    [_avatarImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10].active = YES;
    [_avatarImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10].active = YES;
    [_avatarImageView.heightAnchor constraintEqualToConstant:avatarImageHeight].active = YES;
    [_avatarImageView.widthAnchor constraintEqualToConstant:avatarImageHeight].active = YES;
    _avatarImageView.layer.cornerRadius = avatarImageHeight / 2.f;
    _avatarImageView.layer.masksToBounds = YES;
    
    [_nameLabel.leadingAnchor constraintEqualToAnchor:_avatarImageView.trailingAnchor
                                             constant:15].active = YES;
    [_nameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10].active = YES;
    [_nameLabel.centerYAnchor constraintEqualToAnchor:_avatarImageView.centerYAnchor].active = YES;
    
    [_shortNameLabel.centerXAnchor constraintEqualToAnchor:_avatarImageView.centerXAnchor].active = YES;
    [_shortNameLabel.centerYAnchor constraintEqualToAnchor:_avatarImageView.centerYAnchor].active = YES;
    _shortNameLabel.textColor = [UIColor whiteColor];
    _shortNameLabel.font = [UIFont boldSystemFontOfSize:23];
    
    UIView *selectedBackground = [[UIView alloc] initWithFrame:self.bounds];
    [selectedBackground setBackgroundColor:[UIColor colorWithRed:235/255.f
                                                           green:245/255.f
                                                            blue:251/255.f
                                                           alpha:1]];
    [self setSelectedBackgroundView:selectedBackground];
}


#pragma mark - IGListBindable

- (void)bindViewModel:(id)viewModel {
    if (!viewModel)
        return;
    
    PickerViewModel *model = (PickerViewModel *)viewModel;
    
    [_nameLabel setText:model.name];
    [_shortNameLabel setText:[StringHelper getShortName:model.name]];
    
    UIImage *avatarImage = [[ImageCache instance] imageForKey:model.identifier];
    if (avatarImage) {
        [self.avatarImageView setImage:avatarImage];
        self.shortNameLabel.hidden = YES;
    } else {
        self.shortNameLabel.hidden = NO;
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
    }
    
    if (model.isChosen) {
        [_checkerImageView setImage:[UIImage imageNamed:@"checked"]];
    } else {
        [_checkerImageView setImage:[UIImage imageNamed:@"uncheck"]];
    }
}

@end
