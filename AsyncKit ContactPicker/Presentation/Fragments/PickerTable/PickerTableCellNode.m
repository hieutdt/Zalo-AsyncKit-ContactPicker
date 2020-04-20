//
//  PickerTableCellNode.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerTableCellNode.h"

#import "ColorHelper.h"
#import "StringHelper.h"

#import "AppConsts.h"

#define FONT_SIZE 18

@interface PickerTableCellNode ()

@property (nonatomic, strong) ASTextNode *nameLabel;
@property (nonatomic, strong) ASTextNode *shortNameLabel;
@property (nonatomic, strong) ASImageNode *avatarImageNode;
@property (nonatomic, strong) ASImageNode *checkerImageNode;

@end

@implementation PickerTableCellNode

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _nameLabel = [[ASTextNode alloc] init];
        _nameLabel.maximumNumberOfLines = 1;
        
        _shortNameLabel = [[ASTextNode alloc] init];
        
        _checkerImageNode = [[ASImageNode alloc] init];
        _checkerImageNode.contentMode = UIViewContentModeScaleToFill;
        _checkerImageNode.style.height = ASDimensionMake(CHECKER_IMAGE_HEIGHT);
        _checkerImageNode.style.width = ASDimensionMake(CHECKER_IMAGE_HEIGHT);
        
        _avatarImageNode = [[ASImageNode alloc] init];
        _avatarImageNode.contentMode = UIViewContentModeScaleToFill;
        _avatarImageNode.style.height = ASDimensionMake(AVATAR_IMAGE_HEIHGT);
        _avatarImageNode.style.width = ASDimensionMake(AVATAR_IMAGE_HEIHGT);
        _avatarImageNode.cornerRoundingType = ASCornerRoundingTypeDefaultSlowCALayer;
        _avatarImageNode.cornerRadius = AVATAR_IMAGE_HEIHGT / 2.f;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    ASCenterLayoutSpec *centerNameSpec = [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringY
                                                                            sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                                                            child:_nameLabel];
    
    centerNameSpec.style.layoutPosition = CGPointMake(15 + AVATAR_IMAGE_HEIHGT + 20, 15);
    centerNameSpec.style.preferredSize = CGSizeMake(maxConstrainedSize.width, AVATAR_IMAGE_HEIHGT);
    
    ASCenterLayoutSpec *centerShortNameSpec = [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                                                                         sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                                                                 child:_shortNameLabel];
    
    centerShortNameSpec.style.layoutPosition = CGPointMake(15, 15);
    centerShortNameSpec.style.preferredSize = CGSizeMake(AVATAR_IMAGE_HEIHGT, AVATAR_IMAGE_HEIHGT);
    
    ASCenterLayoutSpec *checkIconSpec = [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                                                                   sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                                                           child:_checkerImageNode];
    
    checkIconSpec.style.layoutPosition = CGPointMake(maxConstrainedSize.width - CHECKER_IMAGE_HEIGHT - 10, 15);
    checkIconSpec.style.preferredSize = CGSizeMake(CHECKER_IMAGE_HEIGHT, AVATAR_IMAGE_HEIHGT);
    
    _avatarImageNode.style.layoutPosition = CGPointMake(15, 15);
    _avatarImageNode.style.preferredSize = CGSizeMake(AVATAR_IMAGE_HEIHGT, AVATAR_IMAGE_HEIHGT);
    
    return [ASAbsoluteLayoutSpec absoluteLayoutSpecWithChildren:@[centerNameSpec, checkIconSpec,_avatarImageNode, centerShortNameSpec]];
}


#pragma mark - Setters

- (void)setName:(NSString *)name {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:FONT_SIZE],
                                      NSParagraphStyleAttributeName : paragraphStyle };
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:name
                                                                 attributes:attributedText];
    self.nameLabel.attributedText = string;
}

- (void)setAvatar:(UIImage *)avatarImage {
    if (avatarImage) {
        self.avatarImageNode.image = [UIImage imageNamed:@"checked"];
        self.avatarImageNode.backgroundColor = [UIColor redColor];
    }
}

- (void)setChecked:(BOOL)isChecked {
    if (isChecked) {
        self.checkerImageNode.image = [UIImage imageNamed:@"checked"];
    } else {
        self.checkerImageNode.image = [UIImage imageNamed:@"uncheck"];
    }
}

- (void)setGradientColorBackground:(int)colorCode {
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:20],
                                      NSForegroundColorAttributeName : [UIColor whiteColor] };
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[StringHelper getShortName:self.nameLabel.attributedText.string]
                                                                 attributes:attributedText];
    self.shortNameLabel.attributedText = string;
    self.shortNameLabel.hidden = NO;
    
    switch (colorCode) {
        case GRADIENT_COLOR_RED: {
            self.avatarImageNode.image = [UIImage imageNamed:@"gradientRed"];
            break;
        }
        case GRADIENT_COLOR_BLUE: {
            self.avatarImageNode.image = [UIImage imageNamed:@"gradientBlue"];
            break;
        }
        case GRADIENT_COLOR_GREEN: {
            self.avatarImageNode.image = [UIImage imageNamed:@"gradientGreen"];
            break;
        }
        case GRADIENT_COLOR_ORANGE: {
            self.avatarImageNode.image = [UIImage imageNamed:@"gradientOrange"];
            break;
        }
        default:
            break;
    }
}

@end