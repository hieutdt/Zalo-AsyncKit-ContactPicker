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
#import "UIImage+Addtions.h"

#import "AppConsts.h"

#define FONT_SIZE 18

static float avatarImageHeight;
static float checkerImageHeight;

@interface PickerTableCellNode ()

@property (nonatomic, strong) ASTextNode *nameLabel;
@property (nonatomic, strong) ASTextNode *shortNameLabel;
@property (nonatomic, strong) ASImageNode *avatarImageNode;
@property (nonatomic, strong) ASImageNode *checkerImageNode;
@property (nonatomic, strong) ASControlNode *controlNode;

@end

@implementation PickerTableCellNode

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        avatarImageHeight = [UIScreen mainScreen].bounds.size.width / 7.f;
        checkerImageHeight = avatarImageHeight / 2.f;
        
        self.automaticallyManagesSubnodes = YES;
        
        _nameLabel = [[ASTextNode alloc] init];
        _nameLabel.maximumNumberOfLines = 1;
        
        _shortNameLabel = [[ASTextNode alloc] init];
        
        _checkerImageNode = [[ASImageNode alloc] init];
        _checkerImageNode.contentMode = UIViewContentModeScaleToFill;
        _checkerImageNode.style.height = ASDimensionMake(checkerImageHeight);
        _checkerImageNode.style.width = ASDimensionMake(checkerImageHeight);
        
        _avatarImageNode = [[ASImageNode alloc] init];
        _avatarImageNode.contentMode = UIViewContentModeScaleToFill;
        _avatarImageNode.style.height = ASDimensionMake(avatarImageHeight);
        _avatarImageNode.style.width = ASDimensionMake(avatarImageHeight);
        _avatarImageNode.imageModificationBlock = ^UIImage *(UIImage * _Nonnull image) {
            CGSize avatarImageSize = CGSizeMake(avatarImageHeight, avatarImageHeight);
            return [image makeCircularImageWithSize:avatarImageSize];
        };
        
        _controlNode = [[ASControlNode alloc] init];
        [_controlNode addTarget:self
                         action:@selector(touchDown)
               forControlEvents:ASControlNodeEventTouchDown];
        [_controlNode addTarget:self
                         action:@selector(touchUpInside)
               forControlEvents:ASControlNodeEventTouchUpInside];
        [_controlNode addTarget:self
                         action:@selector(touchCancel)
               forControlEvents:ASControlNodeEventTouchUpOutside];
        [_controlNode addTarget:self
                         action:@selector(touchCancel)
               forControlEvents:ASControlNodeEventTouchCancel];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    _controlNode.style.preferredSize = maxConstrainedSize;
    
    ASCenterLayoutSpec *centerNameSpec = [ASCenterLayoutSpec
                                          centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringY
                                          sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                          child:_nameLabel];
    centerNameSpec.style.preferredSize = CGSizeMake(maxConstrainedSize.width, avatarImageHeight);
    
    _avatarImageNode.style.preferredSize = CGSizeMake(avatarImageHeight, avatarImageHeight);
    ASCenterLayoutSpec *centerShortNameSpec = [ASCenterLayoutSpec
                                               centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                               sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                               child:_shortNameLabel];
    centerShortNameSpec.style.preferredSize = CGSizeMake(avatarImageHeight, avatarImageHeight);
    
    ASOverlayLayoutSpec *overlayShortNameSpec = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_avatarImageNode
                                                                                        overlay:centerShortNameSpec];

    
    ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                                                           spacing:15
                                                                    justifyContent:ASStackLayoutJustifyContentStart
                                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                                          children:@[_checkerImageNode, overlayShortNameSpec, centerNameSpec]];
    
    ASCenterLayoutSpec *centerSpec = [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringY
                                                      sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                              child:stackSpec];
    
    return [ASOverlayLayoutSpec
            overlayLayoutSpecWithChild:[ASInsetLayoutSpec
                                        insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 15, 0, 0)
                                        child:centerSpec]
            overlay:_controlNode];
}


#pragma mark - Setters

- (void)setName:(NSString *)name {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:FONT_SIZE],
                                      NSParagraphStyleAttributeName : paragraphStyle
    };
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:name
                                                                 attributes:attributedText];
    self.nameLabel.attributedText = string;
}

- (void)setAvatar:(UIImage *)avatarImage {
    if (avatarImage) {
        [self.avatarImageNode setImage:avatarImage];
        self.shortNameLabel.hidden = YES;
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

#pragma mark - TouchEventHandle

- (void)touchDown {
    [self setBackgroundColor:[UIColor colorWithRed:235/255.f
                                             green:245/255.f
                                              blue:251/255.f
                                             alpha:1]];
}

- (void)touchUpInside {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPickerCellNode:)]) {
        [self.delegate didSelectPickerCellNode:self];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setBackgroundColor:[UIColor whiteColor]];
    }];
}

- (void)touchCancel {
    [UIView animateWithDuration:0.25 animations:^{
        [self setBackgroundColor:[UIColor whiteColor]];
    }];
}

@end
