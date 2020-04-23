//
//  CKPickerTableCell.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/23/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "CKPickerTableCell.h"
#import <ComponentKit/ComponentKit.h>

#import "AppConsts.h"

@interface CKPickerTableCell ()

@property (nonatomic, strong) CKImageComponent *checkerImage;
@property (nonatomic, strong) CKImageComponent *avatarImage;
@property (nonatomic, strong) CKLabelComponent *nameLabel;
@property (nonatomic, strong) CKFlexboxComponent *flexboxComponent;

@end

@implementation CKPickerTableCell

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

- (void)customInit {
    _checkerImage = [CKImageComponent newWithImage:[UIImage imageNamed:@""] attributes:{
        { @selector(setBackgroundColor:), [UIColor whiteColor] },
        { @selector(setSize:), CGSizeMake(25, 25) }
    } size:{}];
    
    _avatarImage = [CKImageComponent newWithImage:[UIImage imageNamed:@""] attributes:{
        { @selector(setBackgroundColor:), [UIColor whiteColor] },
        { @selector(setSize:), CGSizeMake(AVATAR_IMAGE_HEIHGT, AVATAR_IMAGE_HEIHGT) }
    } size:{}];
    
    _nameLabel = [CKLabelComponent newWithLabelAttributes:{
        
    } viewAttributes:{
        
    } size:{}];
    
}


@end
